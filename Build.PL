use strict;
use warnings;
use Module::Build;
 
use 5.008;
 
my $builder = Module::Build->new(
    module_name         => 'jcscpu',
    license             => 'perl',
    dist_abstract       => 'Implementation of the JSC Computer',
    build_requires      => {
        'Devel::Cover' => 0,
        'Algorithm::Combinatorics' => 0
    },
);
 
$builder->create_build_script();