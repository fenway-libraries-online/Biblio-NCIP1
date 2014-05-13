package Biblio::NCIP1::Responder;

use strict;
use warnings;

use Biblio::NCIP1::Common;
use Biblio::NCIP1::Request;
use Biblio::NCIP1::Config;
use Biblio::NCIP1::Constants qw(:errors);

sub new {
    my $cls = shift;
    my $self = bless { @_ }, $cls;
    my $config = $self->{'config'} ||= {};
    my $config_file = $self->{'config_file'};
    if ($config_file) {
        %$config = (
            %$config,
            %{ Biblio::NCIP1::Config->parse($config_file) },
        );
    }
    return $self;
    $DB::single = 0 if keys %DB::;
}

sub startup {
    my ($self) = @_;
    my $config_file = $self->{'config_file'};
    print STDERR "** responder NCIP target: $ENV{NCIP1_TARGET}\n";
    print STDERR "** responder config file: $config_file\n";
}

sub teardown {
    my ($self) = @_;
}

sub parse {
    my ($self, $xml) = @_;
    return if !defined $xml;
    return Biblio::NCIP1::Request->new($xml);
}

sub handle_ncip_request {
    my ($self, $xml) = @_;
    my ($req, $ok, $result);
    eval {
        $req = $self->parse($xml);
        my $type = $req->msgtype;
        my $backend = $self->{backend};
        my $method = $backend->can($type)
            || die ERR_UNSUPPORTED_SERVICE;
        $DB::single = 1 if keys %DB::;  # WAS: if $self->{'debug'}{'request'};
        print STDERR "** $_\n" for split /\n/, Data::Dumper->Dump([\%ENV, \%INC], [qw(ENV INC)]);
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
    }
    ($ok, $xml) = $req->response($ok, $result);
    return ($xml);
}

1;

