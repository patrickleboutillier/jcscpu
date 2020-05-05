package BREADBOARD ;

use strict ;
use RAM ;
use ALU ;
use BUS1 ;
use Clock ;
use Stepper ;
use Instructions ;
use Carp ;


# The BREADBOARD comes loaded with the following components:
# - ALU, RAM and BUS
# - All registers (except IAR and IR registers)
#
# Using the options hash, you can specify more componnents be added:
#  instproc: Add IAR, IR and elactic ORs to create the Enables and Sets sides of the board for everything   


sub new {
    my $class = shift ;
    my %opts = @_ ;

    my $this = {
        opts => \%opts,
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
        "TMP.e" => WIRE->on(), # TMP.e is always on
        "TMP.bus" => new BUS(),
        "BUS1.bit1" => new WIRE(),
        "BUS1.bus" => new BUS(),
    ) ;
    $this->put(
        'R0' => new REGISTER($this->get(qw/DATA.bus R0.s R0.e DATA.bus/), "R0"),
        'R1' => new REGISTER($this->get(qw/DATA.bus R1.s R1.e DATA.bus/), "R1"), 
        'R2' => new REGISTER($this->get(qw/DATA.bus R2.s R2.e DATA.bus/), "R2"), 
        'R3' => new REGISTER($this->get(qw/DATA.bus R3.s R3.e DATA.bus/), "R3"), 
        'TMP' => new REGISTER($this->get(qw/DATA.bus TMP.s TMP.e TMP.bus/), "TMP"), 
        'BUS1' => new BUS1($this->get(qw/TMP.bus BUS1.bit1 BUS1.bus/)),
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
        "FLAGS.e" => WIRE->on(), # FLAGS.e is always on
        "FLAGS.s" => new WIRE(),
    ) ;
    $this->put(
        "ACC" => new REGISTER($this->get(qw/ALU.bus ACC.s ACC.e DATA.bus/), "ACC"), 
        "ALU" => new ALU($this->get(qw/DATA.bus BUS1.bus ALU.ci ALU.op ALU.op.e ALU.bus ALU.co ALU.eqo ALU.alo ALU.z/)), 
    ) ;
    $this->put(
        "FLAGS" => new REGISTER(
            BUS->wrap(
                $this->get("ALU")->co(), $this->get("ALU")->alo(), $this->get("ALU")->eqo(), $this->get("ALU")->z(),
                map { WIRE->off() } (0..3)
            ),
            $this->get(qw/FLAGS.s FLAGS.e/),
            # We DO NOT hook up the ALU carry in just yet, we will do that when we setup ALU instructions processing
            BUS->wrap(
                map { new WIRE() } (0..3),
                map { WIRE->off() } (0..3),
            ), "FLAGS"),
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

    if ($opts{'instproc'}){
        $this->instproc() ;
    }
    if ($opts{'instimpl'}){
        $this->instimpl() ;
    }
    if ($opts{'insts'}){
        require Instructions ;
        my $insts = $opts{'insts'} ;
        my @insts = ($insts =~ /^all$/i ? sort keys %INSTRUCTIONS::INSTS : @{$opts{'insts'}}) ;
        foreach my $i (@insts){
            $INSTRUCTIONS::INSTS{$i}->($this) ;
        }
    }

    return $this ;
}


sub instproc {
    my $this = shift ;
 
    # Add instruction related registers
    $this->put(
        "IAR.s" => new WIRE(),
        "IAR.e" => new WIRE(),
        "IR.s" => new WIRE(),
        "IR.e" => WIRE->on(), # IR.e is always on
        "IR.bus" => new BUS(),
        "IO.clk.e" => new WIRE(),
        "IO.clk.s" => new WIRE(),
    ) ;
    $this->put(
        "IAR" => new REGISTER($this->get(qw/DATA.bus IAR.s IAR.e DATA.bus/), "IAR"),
        "IR" => new REGISTER($this->get(qw/DATA.bus IR.s IR.e IR.bus/), "IR"),
    ) ;

    # ALL ENABLES
    for my $e (qw/IAR RAM ACC ALU.op IO.clk/){
        my $w = new WIRE() ;
        new AND($this->get("CLK.clke"), $w, $this->get("$e.e")) ;
        $this->put("$e.ena.eor" => new ORe($w)) ; 
    }
    $this->put("BUS1.bit1.eor" => new ORe($this->get("BUS1.bit1"))) ;

    # ALL SETS
    for my $s (qw/IR RAM.MAR IAR ACC RAM TMP FLAGS IO.clk/){
        my $w = new WIRE() ;
        new AND($this->get("CLK.clks"), $w, $this->get("$s.s")) ;
        $this->put("$s.set.eor" => new ORe($w)) ; 
    }

    # Hook up the circuit used to process the first 3 steps of each cycle (see page 108 in book), i.e 
    # - Load IAR to MAR and increment IAR in AC
    # - Load the instruction from RAM into IR
    # - Increment the IAR from ACC
    $this->get("BUS1.bit1.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("IAR.ena.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("RAM.MAR.set.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("ACC.set.eor")->add($this->get("STP.bus")->wire(0)) ;
    $this->get("ALU.op.ena.eor")->add($this->get("STP.bus")->wire(0)) ;

    $this->get("RAM.ena.eor")->add($this->get("STP.bus")->wire(1)) ; 
    $this->get("IR.set.eor")->add($this->get("STP.bus")->wire(1)) ; 
    
    $this->get("ACC.ena.eor")->add($this->get("STP.bus")->wire(2)) ; 
    $this->get("IAR.set.eor")->add($this->get("STP.bus")->wire(2)) ; 
}


sub instimpl {
    my $this = shift ;

    # Then, we set up the parts that are required to actually implement instructions, i.e.
    # - Connect the decoders for the enable and set operations on R0-R3 
    $this->put(
        "REGA.e" => new WIRE(),
        "REGB.e" => new WIRE(),
        "REGB.s" => new WIRE(),
    ) ;
    $this->put(
        "REGA.ena.eor" => new ORe($this->get("REGA.e")),
        "REGB.ena.eor" => new ORe($this->get("REGB.e")),
        "REGB.set.eor" => new ORe($this->get("REGB.s")),
    ) ;

    # s side
    my @sdeco = () ;
    for my $s (qw/R0 R1 R2 R3/){
        my $w = new WIRE() ;
        new ANDn(3, BUS->wrap($this->get("CLK.clks"), $this->get("REGB.s"), $w), $this->get("$s.s")) ;
        push @sdeco, $w ;
    }
    $this->put("REGB.s.dec" => new DECODER(2, BUS->wrap($this->get("IR")->os()->wire(6), $this->get("IR")->os()->wire(7)), BUS->wrap(@sdeco))) ;
    
    # e side
    my @edecoa = () ;
    my @edecob = () ;
    for my $s (qw/R0 R1 R2 R3/){
        my $wora = new WIRE() ;
        my $worb = new WIRE() ;
        new OR($wora, $worb, $this->get("$s.e")) ;

        my $wa = new WIRE() ;
        new ANDn(3, BUS->wrap($this->get("CLK.clke"), $this->get("REGA.e"), $wa), $wora) ;
        push @edecoa, $wa ;
        my $wb = new WIRE() ;
        new ANDn(3, BUS->wrap($this->get("CLK.clke"), $this->get("REGB.e"), $wb), $worb) ;
        push @edecob, $wb ;
    }
    $this->put("REGA.e.dec" => new DECODER(2, BUS->wrap($this->get("IR")->os()->wire(4), $this->get("IR")->os()->wire(5)), BUS->wrap(@edecoa))) ;
    $this->put("REGB.e.dec" => new DECODER(2, BUS->wrap($this->get("IR")->os()->wire(6), $this->get("IR")->os()->wire(7)), BUS->wrap(@edecob))) ;

    # Finally, install the instruction decoder
    $this->put('INST.bus' => new BUS()) ;
    my $notalu = new WIRE() ;
    new NOT($this->get("IR")->os()->wire(0), $notalu) ;
    my $idec = new DECODER(3, BUS->wrap(map { $this->get("IR")->os()->wire($_) } (1,2,3)), new BUS()) ;
    for (my $j = 0 ; $j < 8 ; $j++){
        new AND($notalu, $idec->os()->wire($j), $this->get("INST.bus")->wire($j)) ; 
    }
    $this->put('INST.dec' => $idec) ;

    # Now, setting up instruction circuits involves:
    # - Hook up to the propoer wire of INST.bus 
    # - Wire up the logical circuit and attach it to proper step wires
    # - Use the "elastic" OR gates (xxx.eor) to enable and set 
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
    $str .= join("  ", map { $this->get($_)->show() } qw/TMP BUS1 ACC FLAGS R0 R1 R2 R3/) . "\n" ;
    $str .= $this->get("ALU")->show(oct('0b' . $this->get("ALU.op")->power())) ;
    $str .= $this->get("RAM")->show() ;
    if ($this->{opts}->{instproc}){
        $str .= "CU:\n" ;
        $str .= "  " . $this->get("IAR")->show() . "  " .  $this->get("IR")->show() ;
        $str .= "  INST.bus:" . $this->get("INST.bus")->power() ;
        $str .= "  REGA.e:" . $this->get("REGA.e")->power() . '/' . $this->get("REGA.e.dec")->os()->power() ;
        $str .= "  REGB.e:" . $this->get("REGB.e")->power() . '/' . $this->get("REGB.e.dec")->os()->power() ;
        $str .= "  REGB.s:" . $this->get("REGB.s")->power() . '/' . $this->get("REGB.s.dec")->os()->power() ;
    }
    $str .= "\n" ;

    return $str ;
}


#
# Convenience methods
#


sub setRAM {
    my $this = shift ;
    my $addr = shift ;
    my $data = shift ;

    $this->get("DATA.bus")->power($addr) ;
    $this->get("RAM.MAR.s")->power(1) ;
    $this->get("RAM.MAR.s")->power(0) ;
    $this->get("DATA.bus")->power($data) ;
    $this->get("RAM.s")->power(1) ;
    $this->get("RAM.s")->power(0) ;
}


sub setREG {
    my $this = shift ;
    my $reg = shift ;
    my $data = shift ;

    $this->get("DATA.bus")->power($data) ;
    $this->get("$reg.s")->power(1) ;
    $this->get("$reg.s")->power(0) ;
}


sub qtick {
    my $this = shift ;

    return $this->get("CLK")->qtick() ;
}


sub tick {
    my $this = shift ;

    return $this->get("CLK")->tick(@_) ;
}


sub step {
    my $this = shift ;

    my $cur = $this->get("STP")->step() ;
    croak("Can't step mid-instruction (step: $cur)!") unless (($cur == 0)||($cur == 6)) ;
    map { $this->get("CLK")->tick() } (0..5) ;
}


1 ;