use strict ;

use Breadboard ;


my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => 'all',
    'devs' => 'all',
) ;

$BB->initRAM("BOOT.txt") ;
# $BB->get("RAM")->dump() ;

$BB->get("CLK")->start() ;