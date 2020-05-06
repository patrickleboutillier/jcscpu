use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;


my $nb_test_per_op = 8 ;
plan(tests => $nb_test_per_op*6) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => ['IO'],
) ;

map { make_io_test($_) } ((1..($nb_test_per_op/2)), (1..($nb_test_per_op/2))) ;
map { make_io_test() } (1..$nb_test_per_op) ;

my $outpower = undef ;
my $gendata = undef ;

sub make_io_test {
    my $n = shift || int rand(256) ;

    $outpower = undef ;
    $gendata = undef ;

    # Register the device
    if (! $BB->get("IO.adapter")->registered($n)){
        my $outdata = new WIRE() ;
        $outdata->posthook(sub {
            if ($_[0]){
                # Data was made available to our device on the DATA.bus.
                # Let's grab it and put it in a local var.  
                $outpower = $BB->get("DATA.bus")->power() ;
            }
        }) ;

        my $indata = new WIRE() ;
        $indata->prehook(sub {
            if ($_[0]){
                # Simulate data being placed on the bus by the device
                if (! defined($gendata)){
                    $gendata = sprintf("%08b", int rand(256)) ;
                    $BB->get("DATA.bus")->power($gendata) ;
                }
            }
        }) ;

        $BB->get("IO.adapter")->register($n,
            $outdata,
            $indata,
            "dummy-$n",
        ) ;
    }

    # Generate a random register
    my $rb = int rand(4) ;
    my $iaddr = sprintf("%08b", int rand(256)) ;
    my $data = sprintf("%08b", int rand(256)) ;

    # First, activate the device (11)
    my $iinst = sprintf("011111%02b", $rb) ;
    #warn "inst: $iinst" ;
    $BB->setREG("R$rb", sprintf("%08b", $n)) ;
    $BB->setRAM($iaddr, $iinst) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->step() ;
    is($BB->get("IO.adapter")->active($n), 1, "Adapter is active") ;
    #warn $BB->show() ;

    # Then, send data to the device (10)
    my $iinst = sprintf("011110%02b", $rb) ;
    #warn "inst: $iinst, data=$data" ;
    $BB->setREG("R$rb", $data) ;
    $BB->setRAM($iaddr, $iinst) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->step() ;
    is($outpower, $data, "Data $data is was grabbed from the bus by device $n") ;
    #warn $BB->show() ;

    # Then, ask for data from the device (00)
    my $iinst = sprintf("011100%02b", $rb) ;
    # warn "inst: $iinst" ;
    $BB->setRAM($iaddr, $iinst) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->step() ;
    # warn $BB->show() ;

    is($BB->get("R$rb")->power(), $gendata, "Data $data is was grabbed from the bus by device $n") ;
    #warn $BB->show() ;
}




