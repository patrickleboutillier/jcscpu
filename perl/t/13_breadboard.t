use strict ;
use Test::More ;
use Breadboard ;

plan(tests => 2) ;

my $BB = new BREADBOARD() ;

eval {
    $BB->put("RAM", 1) ;
} ;
like($@, qr/already registered/) ;
eval {
    $BB->get("RAM2") ;
} ;
like($@, qr/not registered/) ;

