package Biblio::NCIP1::Responder;

use strict;
use warnings;

use Biblio::NCIP1::Common;
use Biblio::NCIP1::Request;
use Biblio::NCIP1::Config;
use Biblio::NCIP1::Constants qw(:errors);
use Data::Dumper;

sub new {
    my $cls = shift;
    my $self = bless { @_ }, $cls;
    my $config = $self->{'config'} ||= {};
    my $conf_file = $self->{'conf_file'};
    if ($conf_file) {
        %$config = (
            %$config,
            %{ Biblio::NCIP1::Config->parse($conf_file) },
        );
    }
    return $self;
    $DB::single = 0 if keys %DB::;
}

sub startup {
    my ($self) = @_;
    my $conf_file = $self->{'conf_file'};
    print STDERR "** responder NCIP target: $ENV{NCIP_TARGET}\n";
    print STDERR "** responder config file: $conf_file\n" if defined $conf_file;
}

sub teardown {
    my ($self) = @_;
}

sub parse {
    my ($self, $xml) = @_;
    return if !defined $xml;
    # Sanitize XML
    $xml =~ s/[&]#x(0?[0-8bcef]|1[0-9a-f]);/?/ig;
    return Biblio::NCIP1::Request->new($xml);
}

sub handle_ncip_request {
    my ($self, $xml) = @_;
    my ($req, $ok, $result);
    eval {
        $req = $self->parse($xml)
            || die ERR_INVALID_MESSAGE_SYNTAX_ERROR;
        my $type = $req->msgtype;
        my $backend = $self->{backend};
        my $method = $backend->can($type)
            || die ERR_UNSUPPORTED_SERVICE;
        $DB::single = 1 if keys %DB::;
        if ($self->{debug}{request}) {
            print STDERR "** $_\n" for split /\n/, Data::Dumper->Dump([\%ENV, \%INC], [qw(ENV INC)]);
        }
        $result = $method->($backend, $req);
        $ok = defined $result;
    };
    if (!$ok) {
        if (!ref $@) {
            chomp $@;
            $result = { 'message' => $@ };
        }
        elsif (ref($@) eq 'HASH') {
            $result = $@;
        }
        if (!defined $req) {
            return <<'EOS';
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE NCIPMessage PUBLIC "-//NISO//NCIP DTD Version 1//EN" "http://www.niso.org/ncip/v1_0/imp1/dtd/ncip_v1_0.dtd">
<NCIPMessage version="http://www.niso.org/ncip/v1_0/imp1/dtd/ncip_v1_0.dtd"/>
EOS
        }
    }
    ($ok, $xml) = $req->response($ok, $result);
    return ($xml);
}

1;

