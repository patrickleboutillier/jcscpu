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
}