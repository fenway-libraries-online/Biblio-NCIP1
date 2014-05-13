package Biblio::NCIP1::Config;

use strict;
use warnings;

sub parse {
    my ($cls, $file) = @_;
    open my $fh, '<', $file or die "Can't open file $file for reading: $!";
    my %config;
    my $section;
    local $_ = "\n";
    while (<$fh>) {
        chomp;
        if (/^\s*(?:#.*)?$/) {
            # Skip comments and blank lines
        }
        elsif (/^\[(.+)\]\s*$/) {
            $section = $config{$1} ||= {};
        }
        elsif (/^\s*(\S+) *= *(.*)/) {
            if ($section) {
                $section->{$1} = $2;
            }
            else {
                $config{$1} = $2;
            }
        }
    }
    close $fh;
    my $include = delete $config{'include'};
    if ($include) {
        my $dir = dirname($file);
        foreach my $key (sort keys %$include) {
            my $include_file = $include->{$key};
            $include_file = "$dir/$include_file" if $include_file !~ m{^/};
            my $include_config = $cls->parse($include_file);
            $config{$key} = $include_config;
        }
    }
    return \%config;
}

sub dirname {
    my ($str) = @_;
    return $str if $str =~ s{/[^/]+$}{};
    return '.';
}

1;
