package HARNESS ;

use strict ;
use RAM ;
use ALU ;
use Clock ;
use Stepper ;
use Carp ;


# The HARNESS is just an assembly of everything except instructions circuits.


sub new {
    my $class = shift ;

    my $this = {} ;
    bless $this, $class ;

    # RAM
    $this->put(
        "DATA.bus" => new BUS(), 
        "RAM.MAR.s" => new WIRE(),
        "RAM.s" => new WIRE(),
        "RAM.e" => new WIRE()
    ) ;
    $this->put( 
        "RAM" => new RAM($this->get(qw/DATA.bus RAM.MAR.s DATA.bus RAM.s RAM.e/)),
    ) ;

    # REGISTERS
    $this->put(
        "R0.s" => new WIRE(),
        "R0.e" => new WIRE(),
        "R1.s" => new WIRE(),
        "R1.e" => new WIRE(),
        "R2.s" => new WIRE(),
        "R2.e" => new WIRE(),
        "R3.s" => new WIRE(),
        "R3.e" => new WIRE(),
        "TMP.s" => new WIRE(),
        "TMP.e" => new WIRE(1, 1), # TMP.e is always on
        "TMP.bus" => new BUS(), 
    ) ;
    $this->put(
        'R0' => new REGISTER($this->get(qw/DATA.bus R0.s R0.e DATA.bus/), "R0"),
        'R1' => new REGISTER($this->get(qw/DATA.bus R1.s R1.e DATA.bus/), "R1"), 
        'R2' => new REGISTER($this->get(qw/DATA.bus R2.s R2.e DATA.bus/), "R2"), 
        'R3' => new REGISTER($this->get(qw/DATA.bus R3.s R3.e DATA.bus/), "R3"), 
        'TMP' => new REGISTER($this->get(qw/DATA.bus TMP.s TMP.e TMP.bus/), "TMP"), 
        "TMP.bus.bit1" => $this->get(qw/TMP.bus/)->wire(7),
    ) ;

    # ALU
    $this->put(
        "ACC.s" => new WIRE(),
        "ACC.e" => new WIRE(),
        "ALU.bus" => new BUS(), 
        "ALU.ci"  => new WIRE(),
        "ALU.op" => new BUS(3),
        "ALU.op.e" => new WIRE(),
        "ALU.co" => new WIRE(),
        "ALU.eqo" => new WIRE(),
        "ALU.alo" => new WIRE(),
        "ALU.z" => new WIRE(),
    ) ;
    $this->put(
        "ACC" => new REGISTER($this->get(qw/ALU.bus ACC.s ACC.e DATA.bus/), "ACC"), 
        "ALU" => new ALU($this->get(qw/DATA.bus TMP.bus ALU.ci ALU.op ALU.op.e ALU.bus ALU.co ALU.eqo ALU.alo ALU.z/)), 
    ) ;


    # CLOCK & STEPPER
    $this->put(
        "CLK.clk" => new WIRE(),
        "CLK.clke" => new WIRE(),
        "CLK.clks" => new WIRE(), 
        "STP.rst" => new WIRE(),
        "STP.bus" => new BUS(7),
    ) ;
    # Connect step 7 wire to rst.
    new CONN($this->get("STP.bus")->wire(6), $this->get("STP.rst")) ;
    $this->put(
        "CLK"  => new CLOCK($this->get(qw/CLK.clk CLK.clke CLK.clks/)),
        "STP"  => new STEPPER($this->get(qw/CLK.clk STP.rst STP.bus/)),
    ) ;

    return $this ;
}


sub put {
    my $this = shift ;
    my %objs = @_ ;

    foreach my $k (keys %objs){
        croak("Component '$k' already registered with Harness!") if (exists $this->{$k}) ;
        $this->{$k} = $objs{$k}  ;  
    }
}


sub get {
    my $this = shift ;
    my @keys = @_ ;

    my @ret = () ;
    foreach my $k (@keys){
        croak("Component '$k' not registered with Harness!") if (! exists $this->{$k}) ;
        push @ret, $this->{$k} ;  
    }

    return (wantarray ? @ret : (scalar(@ret) == 1 ? $ret[0] : \@ret)) ;
}


sub show {
    my $this = shift ;

    my $str = "" ;
    $str .= $this->get("CLK")->show() ;
    $str .= $this->get("STP")->show() ;
    $str .= "BUS:" . $this->get("DATA.bus")->show() . "  " ;
    $str .= join("  ", map { $this->get($_)->show() } qw/TMP ACC R0 R1 R2 R3/) . "\n" ;
    $str .= $this->get("ALU")->show(oct('0b' . $this->get("ALU.op")->power())) ;
    $str .= $this->get("RAM")->show() ;

    return $str ;
}


1 ;