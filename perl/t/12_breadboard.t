use strict ;
use Test::More ;
use Breadboard ;

plan(tests => 3) ;

my $BB = new BREADBOARD() ;

eval {
    $BB->put("RAM", 1) ;
} ;
like($@, qr/already registered/) ;
eval {
    $BB->get("RAM2") ;
} ;
like($@, qr/not registered/) ;

my $a = $BB->get(qw/R0 R1/) ;
my @a = $BB->get(qw/R0 R1/) ;
is_deeply($a, \@a) ;