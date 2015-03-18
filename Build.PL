use strict;
use warnings;

use Module::Build;

my %module_build_args = (
    'build_requires' => {
        'Module::Build' => 0,
        'Test::More' => 0
    },
    'configure_requires' => {
        'Module::Build' => 0,
    },
    'dist_abstract' => 'NCIP version 1 responder framework',
    'dist_author' => [ 'Paul Hoffman <paul@flo.org>' ],
    'dist_name' => 'Biblio-NCIP1',
    'license' => 'perl',
    'module_name' => 'Biblio::NCIP1',
    'recommends' => {},
    'recursive_test_files' => 1,
    'requires' => {
        'Carp' => 0,
        'Net::Server' => 0,
        'Package::Constants' => 0,
        'XML::Simple' => 0,
    },
    'script_files' => [ qw(bin/ncipctl bin/ncipd) ],
);

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
