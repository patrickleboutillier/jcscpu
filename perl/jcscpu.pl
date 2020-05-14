use strict ;

use Breadboard ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => 'all',
    'devs' => 'all',
) ;

my $insts = $BB->readINSTSl([(scalar(@ARGV) ? <> : <STDIN>)]) ;
die("No valid instructions provided!\n") unless scalar(@{$insts}) ;
$BB->initRAMl($insts) ;
$BB->get("CLK")->start() ;