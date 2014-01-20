package Biblio::NCIP1::Request;

use strict;
use warnings;

use Biblio::NCIP1::Constants qw(:all);

use XML::Simple;

use constant PROC_ERROR_SCHEME_FORMAT => 'http://www.niso.org/ncip/v1_0/schemes/processingerrortype/%sprocessingerror.scm';

my %options = (
    'KeepRoot' => 1,
);

sub new {
    my $cls = shift;
    my $xml = XMLin(shift(), %options);
    my $msg = $xml->{'NCIPMessage'} || die "not an NCIP message";
    my $version = delete $msg->{'version'};
    my ($msgtype, $body, @etc) = %$msg;
    die if @etc;
    my $subcls = $cls . '::' . $msgtype;
    eval "use $subcls";
    $subcls = $cls if @$;
    my $self = bless { version => $version, msgtype => $msgtype }, $subcls;
    $self->parse_header(delete $body->{InitiationHeader});
    $self->parse_message($body);
    return $self;
}

sub version { $_[0]->{version} }
sub msgtype { $_[0]->{msgtype} }

sub parse_header {
    my ($self, $hdr) = @_;
    return if !defined $hdr;
    my $from = $hdr->{FromAgencyId}{UniqueAgencyId};
    my $to   = $hdr->{ToAgencyId}{UniqueAgencyId};
    $self->{from} = {
        'scheme' => $from->{Scheme},
        'value'  => $from->{Value},
    } if defined $from;
    if (defined $to) {
        my $recipient = $self->{recipient} = $to->{Value};
        $self->{to} = {
            'scheme' => $to->{Scheme},
            'value'  => $recipient,
        };
    }
}

sub response {
    my ($self, $ok, $result) = @_;
    my $version = $self->version;
    my $doctype = $self->doctype;
    my $header = qq{<?xml version="1.0" encoding="utf-8"?>\n};
    $header   .= $doctype . "\n" if defined $doctype;
    $header   .= qq{<NCIPMessage version="$version">\n};
    my $footer = qq{</NCIPMessage>\n};
    my %body;
    my ($from, $to) = @$self{qw(from to)};
    if ($from && $to) {
        $body{ResponseHeader}{FromAgencyId}{UniqueAgencyId} = {
            Scheme => $to->{scheme},
            Value  => $to->{value},
        };
        $body{ResponseHeader}{ToAgencyId}{UniqueAgencyId} = {
            Scheme => $from->{scheme},
            Value  => $from->{value},
        };
    }
    if ($ok) {
        $self->build_response($result, \%body);
    }
    else {
        $self->build_problem_response($result, \%body);
    }
    my $msgtype = $self->msgtype;
    my %root = ( "${msgtype}Response" => \%body );
    my $root = XMLout(\%root, 'KeepRoot' => 1, 'NoAttr' => 1, 'KeyAttr' => []);
    chomp($header, $root, $footer);
    return $ok, join("\n", $header, $root, $footer, '');
}

sub doctype {
    my ($self) = @_;
    return NCIP1_DOCTYPE if $self->{version} eq NCIP1_DTD;
    return '';
}

sub build_problem_response {
    my ($self, $result, $body) = @_;
    my $msg = $result->{message};
    my $errtype = $result->{errtype};
    $body->{Problem} = $self->procerr($msg, $errtype);
}

sub processing_error_scheme {
    my ($self, $errtype) = @_;
    sprintf PROC_ERROR_SCHEME_FORMAT, lc($errtype || $self->msgtype);
}

sub procerr {
    my ($self, $msg, $errtype) = @_;
    return {
        ProcessingError => {
            ProcessingErrorType => {
                Scheme => $self->processing_error_scheme($errtype),
                Value  => $msg,
            },
            ProcessingErrorElement => {
                ElementName => $self->msgtype,
            },
        },
    };
}

sub not_implemented {
    my ($self, $body) = @_;
    $body->{Problem} = {
        ProcessingError => {
            ProcessingErrorType => {
                Value => 'not implemented',
            },
            ProcessingErrorElement => {
                ElementName => $self->msgtype,
            },
        },
    };
}

sub parse_message { }

sub build_response {
    my ($self, $result, $body) = @_;
    $self->not_implemented($body);
}

# --- Convenience methods

sub bibitem {
    my ($self, $body) = @_;
    my (%bibitem);
    my $bib  = $body->{UniqueBibliographicId};
    my $item = $body->{UniqueItemId};
    if ($item) {
        my $agency = $self->agency($item);
        if ($agency) {
            my $val = $item->{ItemIdentifierValue};
            my $key = 'barcode';  # XXX Really??
            $bibitem{$key} = $val if $val;
            $bibitem{key} = $key;
        }
        $bibitem{type} = REQ_BIBITEM_IS_ITEM;
    }
    elsif ($bib) {
        my $bibid  = $bib->{BibliographicRecordId};
        my $itemid = $bib->{BibliographicItemId};
        if ($bibid) {
            $bibitem{type} = REQ_BIBITEM_IS_BIB;
            my $key = $bibid->{BibliographicRecordIdentifierCode};
            my $val = $bibid->{BibliographicRecordIdentifier} || return;
            if (defined $key) {
                $key = $key->{Value} if ref $key;  # e.g., isbn
            }
            else {
                $key = 'id';
            }
            $bibitem{key} = $key = lc $key;
            $bibitem{$key} = $val;
            $bibitem{agency} = $self->agency($bibid->{UniqueAgencyId});
        }
        elsif ($itemid) {
            $bibitem{type} = REQ_BIBITEM_IS_ITEM;
            my $key = $itemid->{BibliographicItemIdentifierCode};
            my $val = $itemid->{BibliographicItemIdentifier} || return;
            $key = $key->{Value} if ref $key;  # e.g., isbn
            $bibitem{key} = $key = lc $key;
            $bibitem{$key} = $val;
        }
    }
    else {
        return;
    }
    return \%bibitem;
}

sub agency {
    my ($self, $data) = @_;
    return {} if !defined $data;
    my %agency;
    my $agency = $data->{UniqueAgencyId};
    if ($agency) {
        %agency = (
            'scheme' => $agency->{Scheme},
            'value'  => $agency->{Value},
        );
    }
    return \%agency;
}

sub request {
    # ILL request number
    my ($self, $body) = @_;
    my $reqid = $body->{UniqueRequestId};
    my %request;
    if ($reqid) {
        my $agency = $self->agency($reqid);
        $request{agency} = $agency if $agency;
        my $n = $reqid->{RequestIdentifierValue};
        $request{id} = $n if defined $n;
    }
    return \%request;
}

sub requested_action_type {
    my ($self, $body) = @_;
    my $rat = $body->{RequestedActionType};
}

sub item {
    my ($self, $body) = @_;
    my $iid = $body->{UniqueItemId};
    my %item;
    if ($iid) {
        my $agency = $self->agency($iid);
        $item{agency} = $agency if $agency;
        my $val = $iid->{ItemIdentifierValue};
        $item{barcode} = $val if $val;
    }
    return \%item;
}

sub user {
    my ($self, $body) = @_;
    my $uid  = $body->{UniqueUserId};
    my $auth = $body->{AuthenticationInput};
    my %user;
    if ($uid) {
        my $agency = $self->agency($uid);
        $user{agency} = $agency if $agency;
        my $val = $uid->{UserIdentifierValue};
        $user{id} = $val if $val;
    }
    elsif ($auth) {
        $auth = [ $auth ] if ref($auth) eq 'HASH';
        foreach (@$auth) {
            my $data = $_->{AuthenticationInputData};
            my $type = $_->{AuthenticationInputType}{Value};
            next if !defined $type;
            if ($type =~ /^barcode/i) {
                $user{barcode} = $data;
            }
            elsif ($type =~ /^pin/i) {
                $user{pin} = $data;
            }
        }
    }
    return \%user;
}

sub request_scope_type {
    my ($self, $body) = @_;
    my $t = $body->{RequestScopeType}{Value} || return REQ_SCOPE_VALUE_BIB_ITEM;
    return $t =~ /bibliographic item/i ? REQ_SCOPE_VALUE_BIB_ITEM : REQ_SCOPE_VALUE_ITEM;
}

sub request_type {
    my ($self, $body) = @_;
    my $t = $body->{RequestType}{Value} || return REQ_TYPE_VALUE_LOAN;
    return REQ_TYPE_VALUE_LOAN if $t =~ /loan/i;
    return REQ_TYPE_VALUE_HOLD if $t =~ /hold/i;
    return $t;
}

sub bib_description {
    my ($self, $body) = @_;
    my $desc = $body->{BibliographicDescription};
    my %desc;
    $desc{author} = $desc->{Author};
    $desc{title}  = $desc->{Title};
    $desc{place_of_publication} = $desc->{PlaceOfPublication};
    return \%desc;
}

sub item_description {
    my ($self, $body) = @_;
}

1;

