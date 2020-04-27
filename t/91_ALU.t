use strict ;
use Test::More ;
use ALU ;
use Data::Dumper ;
use Algorithm::Combinatorics qw(tuples_with_repetition) ;
use List::Util qw(shuffle) ;

plan(tests => 1) ;

my $bas = new BUS() ; 
my $bbs = new BUS() ;
my $wci = new WIRE() ;
my $bops = new BUS(3) ;
my $bcs = new BUS() ; 
my $wco = new WIRE() ;
my $weqo = new WIRE() ;
my $walo = new WIRE() ;
my $wz = new WIRE() ;
my $ALU = new ALU($bas, $bbs, $wci, $bops, $bcs, $wco, $weqo, $walo, $wz, "Arithmetic and Login Unit") ;
ok(1) ;
