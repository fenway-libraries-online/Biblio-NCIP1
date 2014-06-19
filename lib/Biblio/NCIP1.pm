package Biblio::NCIP1;

use strict;
use warnings;

use Biblio::NCIP1::Common;
use Biblio::NCIP1::Config;
use Biblio::NCIP1::Responder;

use vars qw($VERSION);

$VERSION = '0.04';

sub new {
    my $cls = shift;
    my $self = bless { @_ }, $cls;
    my $root = $self->{'root'} ||= $ENV{'NCIP1_ROOT'} || '/usr/local/ncip1';
    my $target = $self->{'target'} ||= $ENV{'NCIP_TARGET'};
    my $config = $self->{'config'} = Biblio::NCIP1::Config->parse("$root/conf/$target/ncip1.conf");
    my $backend_pkg = $self->use_package($config->{'backend'}{'package'} || die "NCIP1 backend not configured");
    my $backend = $self->{'backend'} = $backend_pkg->new(
        'config' => $config->{'backend'},
    );
    my $responder_pkg = $self->use_package($config->{'responder'}{'package'} ||= 'Biblio::NCIP1::Responder');
    my $responder = $self->{'responder'} = Biblio::NCIP1::Responder->new(
        'backend' => $backend,
        'config' => $config->{'responder'} || {},
        'debug' => $self->{'debug'} || {},
    );
    return $self;
}

sub use_package {
    my ($self, $pkg) = @_;
    eval "use $pkg";
    die $@ if $@;
    return $pkg;
}

sub run_once {
    my ($self, $fh) = @_;
    my $backend = $self->{'backend'};
    my $responder = $self->{'responder'};
    $_->startup for $backend, $responder;
    my $xml = $self->read_request($fh);
    my $err;
    if (defined $xml) {
        ($xml, $err) = $responder->handle_ncip_request($xml);
        die "Fatal error: $err" if $err;
        print $xml;
    }
    $_->teardown for $responder, $backend;
}

sub read_request {
    my ($self, $fh) = @_;
    my ($xml, $err);
    {
        local $/;
        $xml = <$fh>;
    }
    return $xml;
}

sub start {
    my ($self, %config) = @_;
    my $pid = fork();
    die "Can't fork: $!" if !defined $pid;
    return $self if $pid != 0;
    # Now we're in the child process
    $self->run;
}

sub run {
    my ($self) = @_;
    my $config = $self->{'config'};
    my $server_config = $config->{'server'};
    my $server_pkg = $self->use_package($server_config->{'package'} ||= 'Biblio::NCIP1::Server');
    my $backend = $self->{'backend'};
    my $responder = $self->{'responder'};
    my $server = $self->{'server'} = $server_pkg->new(
        'config' => { %$server_config, %$config },
    );
    $_->startup for $backend, $responder, $server;
    $server->responder($responder);
    $server->run;
    $_->teardown for $server, $responder, $backend;
}

sub stop {
    my ($self) = @_;
    my $config = $self->{'config'};
    my $server_config = $config->{'server'};
    my $server_pid = $self->find_server($server_config);
    die "Server is not running" if !$server_pid;
    kill 'TERM', $server_pid;
}

sub find_server {
    my ($self, $config) = @_;
    my $pid_file = $config->{'pid_file'} || return;
    open my $fh, '<', $pid_file or die "Can't open PID file: $!";
    my $pid = <$fh>;
    chomp $pid;
    close $fh;
    return $pid if $pid =~ /^\d+$/;
    die "PID file not valid";
}

1;
