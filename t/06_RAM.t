use strict ;
use Test::More ;
use RAM ;
use Data::Dumper ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;

plan(tests => 1) ;

my $RAM = new RAM("System memory") ;
ok(1) ;