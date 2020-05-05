use strict ;
use Test::More ;
use Data::Dumper ;
use ALU ;

push @INC, './t' ;
require 'test_alu.pm' ;


my $nb_test_per_op = 128 ;
my @ops = (0,1,2,3,4,5,6,7) ;
plan(tests => $nb_test_per_op*(scalar(@ops)+1)) ;


my $bas = new BUS() ; 
my $bbs = new BUS() ;
my $wci = new WIRE() ;
my $bops = new BUS(3) ;
my $wope = new WIRE() ;
my $bcs = new BUS() ; 
my $wco = new WIRE() ;
my $weqo = new WIRE() ;
my $walo = new WIRE() ;
my $wz = new WIRE() ;
my $ALU = new ALU($bas, $bbs, $wci, $bops, $wope, $bcs, $wco, $weqo, $walo, $wz) ;
$ALU->show() ;
$ALU->show(0) ;

foreach my $op (@ops){
    for (my $j = 0 ; $j < $nb_test_per_op ; $j++){
        do_test_case($op) ;
    }
}

# Random ops
@ops = map { int rand(8) } (0 .. ($nb_test_per_op-1)) ;
foreach my $op (@ops){
    do_test_case($op) ;
}


sub do_test_case {
    my $op = shift ;
    
    my $tc = gen_test_case() ;
    $tc->{op} = $op ;

    my $res = alu($tc) ; 
    my $vres = valu($tc) ;

    my $desc = Dumper($tc) ;
    $desc =~ s/\n\s*//gs ;
    is_deeply($res, $vres, $desc) ;
}


sub alu {
    my $tc = shift ;

    my %res = %{$tc} ;

    # Place values on bus
    $bas->power(sprintf("%08b", $res{a})) ;
    $bbs->power(sprintf("%08b", $res{b})) ;
    $wci->power($res{ci}) ;
    # warn $ALU->show($res{op}) ;

    $bops->power(sprintf("%03b", $res{op})) ;
    $wope->power(1) ;
    # warn $ALU->show($res{op}) ;

    $res{out} = oct("0b" . $bcs->power()) if ($res{op} < 7) ;   
    $res{co} = $wco->power() if ($res{op} < 3) ;

    if (defined($res{out})){
        $res{binout} = sprintf("%08b", $res{out}) ; 
        $res{z} = $wz->power() ;
        $res{eqo} = $weqo->power() ;
        $res{alo} = $walo->power() ;
    }
    $wope->power(0) ;

    return \%res ;
}