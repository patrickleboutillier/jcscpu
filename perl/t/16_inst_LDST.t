use strict ;
use Test::More ;
use Breadboard ;
use Data::Dumper ;


my $nb_test_per_op = 16 ;
plan(tests => $nb_test_per_op*2*2) ;

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => ['LDST'],
) ;

map { make_load_test() } (1..$nb_test_per_op) ;
map { make_store_test() } (1..$nb_test_per_op) ;


# Testing of LOAD/STORE instructions.
# Generate a random addr, 2 registers and data
sub make_load_test {
    my $a = int(rand(254)) + 1 ;
    my $addr = sprintf("%08b", $a) ;
    my $iaddr = sprintf("%08b", $a - 1) ;
    my $ra = int rand(4) ;
    my $rb = int rand(4) ;
    my $data = sprintf("%08b", int rand(255)) ;
    my $linst = "0000" . sprintf("%02b%02b", $ra, $rb) ;

    $BB->setREG("R$ra", $addr) ;
    $BB->setRAM($addr, $data) ; 
    $BB->setRAM($iaddr, $linst) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->step() ; 
    is($BB->get("R$rb")->power(), $data, "$data copied from RAM\@$addr (R$ra) to R$rb") ;
    is($BB->get("IAR")->power(), $addr, "IAR has advanced to $addr") ;
}


sub make_store_test {
    my $a = int(rand(254)) + 1 ;
    my $addr = sprintf("%08b", $a) ;
    my $iaddr = sprintf("%08b", $a - 1) ;
    my $ra = int rand(4) ;
    my $rb = int rand(4) ;
    my $data = sprintf("%08b", int rand(255)) ;
    my $linst = "0001" . sprintf("%02b%2b", $ra, $rb) ;

    $BB->setREG("R$ra", $addr) ;
    $BB->setREG("R$rb", $data) ;
    $BB->setRAM($iaddr, $linst) ; 
    $BB->setREG("IAR", $iaddr) ;
    $BB->step() ;
    is($BB->get("R$rb")->power(), $data, "$data stored from R$rb to RAM\@$addr") ;
    is($BB->get("IAR")->power(), $addr, "IAR has advanced to $addr") ;
}


__DATA__


sub do_test_case {
    my $op = shift ;
    
    my $tc = gen_test_case() ;
    $tc->{op} = $op ;


    $tc->{rb} = int rand(4) ;   
    if ($tc->{ra} == $tc->{rb}){
        $tc->{b} = $tc->{a} ;
        $tc->{binb} = sprintf("%08b", $tc->{b}) ;
    }
    # Create our instruction    
    $tc->{inst} = "1" . sprintf("%03b%02b%02b", $tc->{op}, $tc->{ra}, $tc->{rb}) ;

    my $res = alu($tc) ;
    my $vres = valu($tc, 1) ;

    my $desc = Dumper($tc) ;
    $desc =~ s/\n\s*//gs ;
    is_deeply($res, $vres, "inst:$tc->{inst}, $desc") or die() ;
}


sub alu {
    my $tc = shift ;

    my %res = %{$tc} ;

    delete $res{ci} ; # No flags

    # Generate a random RAM address
    my $addr = sprintf("%08b", int rand(255)) ;

    $BB->setREG("R$res{ra}", $res{bina}) ;
    $BB->setREG("R$res{rb}", $res{binb}) ;
    $BB->setRAM($addr, $res{inst}) ; 
    $BB->setREG("IAR", $addr) ;
    $BB->step() ;
    #warn Dumper($tc) ;
    #warn $BB->show() ;
    #for (my $j = 0 ; $j < 12 ; $j++){
    #    $BB->qtick() ;
    #    warn $BB->show() ;
    #}

    $res{out} = oct("0b" . $BB->get("R$res{rb}")->power()) if ($res{op} < 7) ;   

    if (defined($res{out})){
        $res{binout} = sprintf("%08b", $res{out}) ; 
    }

    return \%res ;
}