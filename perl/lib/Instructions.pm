package INSTRUCTIONS ;

use strict ;

$INSTRUCTIONS::INSTS{'ALU'} = sub {
    my $BB = shift ;

    my $aa1 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(3), $BB->get("IR.bus")->wire(0), $aa1) ;
    $BB->get("REGB.ena.eor")->add($aa1) ;
    $BB->get("TMP.set.eor")->add($aa1) ;

    my $aa2 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(4), $BB->get("IR.bus")->wire(0), $aa2) ;
    $BB->get("REGA.ena.eor")->add($aa2) ;
    $BB->get("ALU.ci.ena.eor")->add($aa2) ; # Errata #2
    $BB->get("ACC.set.eor")->add($aa2) ;
    $BB->get("FLAGS.set.eor")->add($aa2) ;

    my $wnotcmp = new WIRE() ;
    my $aa3 = new WIRE() ;
    new ANDn(3, BUS->wrap($BB->get("STP.bus")->wire(5), $BB->get("IR.bus")->wire(0), $wnotcmp), $aa3) ;
    $BB->get("ACC.ena.eor")->add($aa3) ;
    $BB->get("REGB.set.eor")->add($aa3) ;

    # Operation selector
    my $w = new WIRE() ;
    my $notcmp = new NOT($w, $wnotcmp) ;
    my $cmpbus = BUS->wrap(map { $BB->get("IR.bus")->wire($_) } (1,2,3)) ;
    my $cmp = new ANDn(3, $cmpbus, $w) ;

    for (my $j = 0 ; $j < 3 ; $j++){
        new ANDn(3, BUS->wrap($BB->get("STP.bus")->wire(4), $BB->get("IR.bus")->wire(0), $cmpbus->wire($j)), $BB->get("ALU.op")->wire($j)) ;
    }
} ;


$INSTRUCTIONS::INSTS{'LDST'} = sub {
    my $BB = shift ;

    my $l1 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(3), $BB->get("INST.bus")->wire(0), $l1) ;
    $BB->get("REGA.ena.eor")->add($l1) ;
    $BB->get("RAM.MAR.set.eor")->add($l1) ;

    my $l2 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(4), $BB->get("INST.bus")->wire(0), $l2) ;
    $BB->get("RAM.ena.eor")->add($l2) ;
    $BB->get("REGB.set.eor")->add($l2) ;

    my $s1 = new WIRE() ;
    $s1->prehook(sub { warn "LDST s1 @_" }) ;
    new AND($BB->get("STP.bus")->wire(3), $BB->get("INST.bus")->wire(1), $s1) ;
    $BB->get("REGA.ena.eor")->add($s1) ;
    $BB->get("RAM.MAR.set.eor")->add($s1) ;

    my $s2 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(4), $BB->get("INST.bus")->wire(1), $s2) ;
    $BB->get("REGB.ena.eor")->add($s2) ;
    $BB->get("RAM.set.eor")->add($s2) ;
} ;


$INSTRUCTIONS::INSTS{'DATA'} = sub {
    my $BB = shift ;

    my $d1 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(3), $BB->get("INST.bus")->wire(2), $d1) ;
    $BB->get("BUS1.bit1.eor")->add($d1) ;
    $BB->get("IAR.ena.eor")->add($d1) ;
    $BB->get("RAM.MAR.set.eor")->add($d1) ;
    $BB->get("ACC.set.eor")->add($d1) ;

    my $d2 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(4), $BB->get("INST.bus")->wire(2), $d2) ;
    $BB->get("RAM.ena.eor")->add($d2) ;
    $BB->get("REGB.set.eor")->add($d2) ;

    my $d3 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(5), $BB->get("INST.bus")->wire(2), $d3) ;
    $BB->get("ACC.ena.eor")->add($d3) ;
    $BB->get("IAR.set.eor")->add($d3) ;
} ;


$INSTRUCTIONS::INSTS{'JUMP'} = sub {
    my $BB = shift ;

    # JUMPR
    my $jr1 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(3), $BB->get("INST.bus")->wire(3), $jr1) ;
    $BB->get("REGB.ena.eor")->add($jr1) ;
    $BB->get("IAR.set.eor")->add($jr1) ;

    # JUMP
    my $j1 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(3), $BB->get("INST.bus")->wire(4), $j1) ;
    $BB->get("IAR.ena.eor")->add($j1) ;
    $BB->get("RAM.MAR.set.eor")->add($j1) ;

    my $j2 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(4), $BB->get("INST.bus")->wire(4), $j2) ;
    $BB->get("RAM.ena.eor")->add($j2) ;
    $BB->get("IAR.set.eor")->add($j2) ;

    # JUMPIF
    my $ji1 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(3), $BB->get("INST.bus")->wire(5), $ji1) ;
    $BB->get("BUS1.bit1.eor")->add($ji1) ;
    $BB->get("IAR.ena.eor")->add($ji1) ;
    $BB->get("RAM.MAR.set.eor")->add($ji1) ;
    $BB->get("ACC.set.eor")->add($ji1) ;

    my $ji2 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(4), $BB->get("INST.bus")->wire(5), $ji2) ;
    $BB->get("ACC.ena.eor")->add($ji2) ;
    $BB->get("IAR.set.eor")->add($ji2) ;

    my $ji3 = new WIRE() ;
    my $flago = new WIRE() ;
    new ANDn(3, BUS->wrap($BB->get("STP.bus")->wire(5), $BB->get("INST.bus")->wire(5), $flago), $ji3) ;
    $BB->get("RAM.ena.eor")->add($ji3) ;
    $BB->get("IAR.set.eor")->add($ji3) ;

    my $fbus = new BUS(4) ;
    for (my $j = 0 ; $j < 4 ; $j++){
        new AND($BB->get("FLAGS")->os()->wire($j), $BB->get("IR.bus")->wire($j + 4), $fbus->wire($j)) ;
    }
    new ORn(4, $fbus, $flago) ;
} ;


$INSTRUCTIONS::INSTS{'CLF'} = sub {
    my $BB = shift ;

    # CLF
    my $cl1 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(3), $BB->get("INST.bus")->wire(6), $cl1) ;
    $BB->get("BUS1.bit1.eor")->add($cl1) ;
    $BB->get("FLAGS.set.eor")->add($cl1) ;
} ;


$INSTRUCTIONS::INSTS{'IO'} = sub {
    my $BB = shift ;

    # IO
    my $io1 = new WIRE() ;
    new ANDn(3, BUS->wrap($BB->get("STP.bus")->wire(3), $BB->get("INST.bus")->wire(7), $BB->get("IR.bus")->wire(4)), $io1) ;
    $BB->get("REGB.ena.eor")->add($io1) ;

    my $ion4 = new WIRE() ;
    new NOT($BB->get("IR.bus")->wire(4), $ion4) ;
    my $io2 = new WIRE() ;
    new ANDn(3, BUS->wrap($BB->get("STP.bus")->wire(4), $BB->get("INST.bus")->wire(7), $ion4), $io2) ;   
    $BB->get("REGB.set.eor")->add($io2) ;

    new AND($BB->get("CLK.clks"), $io1, $BB->get("IO.clks")) ;
    new AND($BB->get("CLK.clke"), $io2, $BB->get("IO.clke")) ;
    new CONN($BB->get("IR.bus")->wire(4), $BB->get("IO.io")) ;
    new CONN($BB->get("IR.bus")->wire(5), $BB->get("IO.da")) ;
} ;