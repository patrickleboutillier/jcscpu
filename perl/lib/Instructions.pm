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
    $BB->get("ACC.set.eor")->add($aa2) ;

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

    my $aluope = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(4), $BB->get("IR.bus")->wire(0), $aluope) ;
    $BB->get("ALU.op.ena.eor")->add($aluope) ;
} ;


$INSTRUCTIONS::INSTS{'LDST'} = sub {
    my $BB = shift ;

    my $l1 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(3), $BB->get("INST.dec")->o(0), $l1) ;
    $BB->get("REGA.ena.eor")->add($l1) ;
    $BB->get("RAM.MAR.set.eor")->add($l1) ;

    my $l2 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(4), $BB->get("INST.dec")->o(0), $l2) ;
    $BB->get("RAM.ena.eor")->add($l2) ;
    $BB->get("REGB.set.eor")->add($l2) ;

    my $s1 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(3), $BB->get("INST.dec")->o(1), $s1) ;
    $BB->get("REGA.ena.eor")->add($s1) ;
    $BB->get("RAM.MAR.set.eor")->add($s1) ;

    my $s2 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(4), $BB->get("INST.dec")->o(1), $s2) ;
    $BB->get("REGB.ena.eor")->add($s2) ;
    $BB->get("RAM.set.eor")->add($s2) ;
} ;


$INSTRUCTIONS::INSTS{'DATA'} = sub {
    my $BB = shift ;

    my $d1 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(3), $BB->get("INST.dec")->o(2), $d1) ;
    $BB->get("BUS1.bit1.eor")->add($d1) ;
    $BB->get("IAR.ena.eor")->add($d1) ;
    $BB->get("RAM.MAR.set.eor")->add($d1) ;
    $BB->get("ACC.set.eor")->add($d1) ;

    my $d2 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(4), $BB->get("INST.dec")->o(2), $d2) ;
    $BB->get("RAM.ena.eor")->add($d2) ;
    $BB->get("REGB.set.eor")->add($d2) ;

    my $d3 = new WIRE() ;
    new AND($BB->get("STP.bus")->wire(5), $BB->get("INST.dec")->o(2), $d3) ;
    $BB->get("ACC.ena.eor")->add($d3) ;
    $BB->get("IAR.set.eor")->add($d3) ;
} ;