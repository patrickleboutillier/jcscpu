use strict ;
use Test::More ;
use Breadboard ;

plan(tests => 6) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => 'all',
) ;
pass("Breadboard loaded") ;

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

$BB->qtick() ;
eval {
    $BB->tick() ;
} ;
like($@, qr/Can't tick mid-cycle/, "Badly timed tick") ;
eval {
    $BB->step() ;
} ;
like($@, qr/Can't step mid-instruction/, "Badly timed step") ;