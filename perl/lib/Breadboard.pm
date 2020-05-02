package BREADBOARD ;

use strict ;
use RAM ;
use ALU ;
use Clock ;
use Stepper ;
use Carp ;


# The BREADBOARD comes loaded with the following components:
# - ALU, RAM and BUS
# - All registers (including IAR and IR registers)
#
# Using the options hash, you can specify more componnents be added:
#  enaset: Add elactic ORs to create the Enables and Sets sides of the board for everything except (R0-R3)   


sub new {
    my $class = shift ;
    my %opts = @_ ;

    my $this = {
        started => 0,
    } ;
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
    $this->put("RAM.MAR" => $this->get("RAM")->MAR()) ;

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
        "IAR.s" => new WIRE(),
        "IAR.e" => new WIRE(),
        "IR.s" => new WIRE(),
        "IR.e" => new WIRE(1, 1), # IR.e is always on
        "IR.bus" => new BUS(),
    ) ;
    $this->put(
        'R0' => new REGISTER($this->get(qw/DATA.bus R0.s R0.e DATA.bus/), "R0"),
        'R1' => new REGISTER($this->get(qw/DATA.bus R1.s R1.e DATA.bus/), "R1"), 
        'R2' => new REGISTER($this->get(qw/DATA.bus R2.s R2.e DATA.bus/), "R2"), 
        'R3' => new REGISTER($this->get(qw/DATA.bus R3.s R3.e DATA.bus/), "R3"), 
        'TMP' => new REGISTER($this->get(qw/DATA.bus TMP.s TMP.e TMP.bus/), "TMP"), 
        "TMP.bus.bit1" => $this->get(qw/TMP.bus/)->wire(7),
        "IAR" => new REGISTER($this->get(qw/DATA.bus IAR.s IAR.e DATA.bus/), "IAR"),
        "IR" => new REGISTER($this->get(qw/DATA.bus IR.s IR.e IR.bus/), "IR"),
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
        "STP.bus" => new BUS(7),
    ) ;
    $this->put(
        "CLK"  => new CLOCK($this->get(qw/CLK.clk CLK.clke CLK.clks/)),
        "STP"  => new STEPPER($this->get(qw/CLK.clk STP.bus/)),
    ) ;

    if ($opts{'enaset'}){
        $this->enaset() ;
    }
    if ($opts{'instruct'}){
        $this->instruct() ;
    }

    return $this ;
}


sub enaset {
    my $this = shift ;

    # ALL ENABLES
    for my $e (qw/IAR RAM ACC ALU.op/){
        my $w = new WIRE() ;
        new AND($this->get("CLK.clke"), $w, $this->get("$e.e")) ;
        $this->put("$e.ena.eor" => new ORe($w)) ; 
    }
    $this->put("TMP.bit1.eor" => new ORe($this->get("TMP.bus.bit1"))) ;

    # ALL SETS
    for my $s (qw/IR RAM.MAR IAR ACC RAM TMP/){
        my $w = new WIRE() ;
        new AND($this->get("CLK.clks"), $w, $this->get("$s.s")) ;
        $this->put("$s.set.eor" => new ORe($w)) ; 
    }
}


sub instruct {
    my $this = shift ;
 
    # Hook up the circuit used to process the first 3 steps of each cycle (see page 108 in book), i.e 
    # - Load IAR to MAR and increment IAR in AC
    # - Load the instruction from RAM into IR
    # - Increment the IAR from ACC
    $this->get("TMP.bit1.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("IAR.ena.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("RAM.MAR.set.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("ACC.set.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("ALU.op.ena.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("RAM.ena.eor")->add($this->get("STP.bus")->wire(1)) ; 
    $this->get("IR.set.eor")->add($this->get("STP.bus")->wire(1)) ; 
    $this->get("ACC.ena.eor")->add($this->get("STP.bus")->wire(2)) ; 
    $this->get("IAR.set.eor")->add($this->get("STP.bus")->wire(2)) ; 
}


sub put {
    my $this = shift ;
    my %objs = @_ ;

    croak("Can't add components to the breadboard once it's started!") if $this->{started} ;

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
    $str .= "CU:\n" ;
    $str .= "  " . $this->get("IAR")->show() . "  " .  $this->get("IR")->show() . "\n" ;

    return $str ;
}


1 ;