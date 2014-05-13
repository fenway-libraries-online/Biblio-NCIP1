package Biblio::NCIP1::Server;

use strict;
use warnings;

use Biblio::NCIP1::Common;
use Net::Server;

use base qw(Net::Server);

sub startup {
    my ($self) = @_;
    my $config_file = $self->{'config_file'};
    print STDERR "** backend config file: $config_file\n";
}

sub teardown { }

sub process_request {
    my $self = shift;
    $self->log_begin();
    my ($xml, $err) = read_ncip_request();
    if (defined $xml && length $xml) {
        $self->log_message('REQUEST' => $xml);
        $self->log_note('WORKING');
        my $responder = $self->responder;
        ($xml, $err) = $responder->handle_ncip_request($xml);
    }
    else {
        $self->log_note('NO REQUEST');
    }
    if ($err) {
        $self->log_message('ERROR' => $err);
    }
    if (defined $xml) {
        print $xml;
        $self->log_message('RESPONSE' => $xml);
    }
    $self->log_end();
}

sub responder {
    my $self = shift;
    return @_ ? $self->{responder} = shift : $self->{responder};
}

# sub post_configure_hook {
#     $ncip_config = Biblio::NCIP1::Config->parse('conf/vger8/ncip.conf');
#     $sip_config  = Biblio::NCIP1::Config->parse('conf/vger8/sip.conf');
#     $loc_config  = Biblio::NCIP1::Config->parse('conf/vger8/locations.conf');
#     $responder   = Biblio::NCIP1::Server->new(
#         %$ncip_config,
#         'backend' => Biblio::NCIP1::Backend::Vger8->new(
#             'config' => {
#                 'sip' => $sip_config,
#                 'locations' => $loc_config,
#             },
#         ),
#     );
#     ### # DON'T ignore SIGTERM -- the Voyager backup script triggers it
#     ### $SIG{TERM} = 'IGNORE';
# }

sub read_ncip_request {
    my ($timeout) = @_;
    $timeout ||= 10;
    my $xml;
    my $ok = eval {
        local $SIG{'ALRM'} = sub { die "Request timed out\n" };
        my $previous_alarm = alarm($timeout);
        $xml = '';
        while (<STDIN>) {
            s/\r$//;
            $xml .= $_;
            last if m{</NCIPMessage>};
        }
        alarm($previous_alarm);
        1;
    };
    my $err = $@;
    return (undef, $err || 'Unknown error') if !$ok;
    return ($xml, undef);
}

sub log_begin {
    my ($self) = @_;
    my $t = localtime;
    my $ip = $self->{server}{peeraddr};
    print STDERR "(( $t $ip\n";
}

sub log_note {
    my ($self, $note) = @_;
    print STDERR "::: $note\n";
}

sub log_message {
    my ($self, $head, $msg) = @_;
    print STDERR "+-- $head\n";
    if (defined $msg) {
        print STDERR '|   ', $_, "\n" for split /\n/, $msg;
    }
}

sub log_end {
    my ($self) = @_;
    my $t = localtime;
    my $ip = $self->{server}{peeraddr};
    print STDERR ")) $t $ip\n\n";
}

1;
