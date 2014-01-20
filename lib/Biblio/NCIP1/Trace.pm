package Biblio::NCIP1::Trace;

# From Devel::Trace by Mark-Jason Dominus <mjd-perl-trace@plover.com>

use strict;
use warnings;

use Carp;

use vars qw($TRACE $TRACE_FH $TRACE_IN %TRACE_FILE %TRACE_PKG);

$TRACE = 0;
$TRACE_FH = \*STDERR;
$TRACE_IN = '';
%TRACE_FILE = ();
%TRACE_PKG = ();

sub DB::DB {
    return unless $TRACE;
    my ($pkg, $file, $line) = caller;
    next if keys %TRACE_FILE && !exists $TRACE_FILE{$file};
    next if keys %TRACE_PKG  && !exists $TRACE_PKG{$pkg};
    my $code = \@{'::_<'.$file};
    if ($file ne $TRACE_IN) {
        print $TRACE_FH "## file $file\n";
        $TRACE_IN = $file;
    }
    printf $TRACE_FH ">> %4d %s", $file, $code->[$line];
}

sub trace(@) {
    return $TRACE if @_ == 0;
    my $arg = shift;
    if (@_ == 0) {
        if (ref($arg)) {
            $TRACE_FH = $arg;
        }
        elsif ($arg =~ /^(off|0)$/i) {
            undef $TRACE;
        }
        elsif ($arg =~ /^(on|1)$/i) {
            $TRACE = 1;
            $TRACE_FH ||= \*STDERR;
        }
        elsif ($arg eq 'close') {
            undef $TRACE_FH;
            undef $TRACE;
        }
        else {
            my ($pkg, $file, $line) = caller;
            if ($arg eq 'file') {
                $TRACE_FILE{$file} = 1;
            }
            elsif ($arg eq 'package') {
                $TRACE_PKG{$pkg} = 1;
            }
        }
        return;
    }
    my %arg = @_;
    $TRACE_FH = $arg{to} if exists $arg{to};
    $TRACE_FILE{$arg{file}} = 1 if exists $arg{file};
    $TRACE_PKG{$arg{pkg}} = 1 if exists $arg{pkg};
}

sub import {
    my $pkg = shift;
    my $caller = caller;
    *{$caller . '::trace'} = \&{$pkg . '::trace'};
}
