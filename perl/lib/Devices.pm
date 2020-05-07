package DEVICES ;

use strict ;
use IO::Handle ;
use Carp ;


$DEVICES::TTY_OUTPUT = \*STDOUT ;
sub TTY { return 1 } ;
$DEVICES::DEVS{'TTY'} = sub {
    my $BB = shift ;

    my $outdata = new WIRE() ;
    $outdata->posthook(sub {
        return unless $_[0] ;
        my $byte = $BB->get("DATA.bus")->power() ;
        my $dec = oct("0b$byte") ;
        my $char = chr($dec) ;
        print $DEVICES::TTY_OUTPUT "$char" ;
        $DEVICES::TTY_OUTPUT->flush() ;
    }) ;
    $BB->get("IO.adapter")->register(TTY(),
        $outdata,
        undef,
        "TTY",
    ) ;
} ;


$DEVICES::ROM_FILE = "ROM.txt" ;
sub ROM { return 0 } ;
my @ROM = () ;
my $ROM_ADDR = 0 ;
$DEVICES::DEVS{'ROM'} = sub {
    my $BB = shift ;

    # This file should be the output of a jcsasm program
    open(ROM, "<$DEVICES::ROM_FILE") or croak("Can't open ROM file '$DEVICES::ROM_FILE': $!") ;
    while (<ROM>){
        my $line = $_ ;
        chomp($line) ;
        next unless $line =~ /^([01]{8})\b/ ;
        push @ROM, $1 ;
    }

    my $outdata = new WIRE() ;
    $outdata->posthook(sub {
        return unless $_[0] ;
        $ROM_ADDR = oct("0b" . $BB->get("DATA.bus")->power()) ;
    }) ;
    my $indata = new WIRE() ;
    $indata->posthook(sub {
        return unless $_[0] ;
        $BB->get("DATA.bus")->power($ROM[$ROM_ADDR]) ;
    }) ;
    $BB->get("IO.adapter")->register(ROM(),
        undef,
        $indata,
        "ROM",
    ) ;
} ;