use strict ;
use Test::More ;
use ALU ;
use Data::Dumper ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(shuffle) ;

plan(tests => 1) ;

my $ALU = new ALU("Arithmetic and Login Unit") ;
ok(1) ;
