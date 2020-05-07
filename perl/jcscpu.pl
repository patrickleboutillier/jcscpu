use strict ;

use Breadboard ;


my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => 'all',
    'devs' => 'all',
) ;


# This file should be the output of a jcsasm program
open(BOOT, "<BOOT.txt") or croak("Can't open BOOT file 'BOOT.txt': $!") ;
my $addr = 0 ;
while (<BOOT>){
    my $line = $_ ;
    chomp($line) ;
    $line =~ s/[^[:print:]]//g ; 
    next unless $line =~ /^([01]{8})\b/ ;
    my $inst = $1 ;
    $BB->setRAM(sprintf("%08b", $addr++), $inst) ;
}
$BB->get("RAM")->dump(20) ;

$BB->get("CLK")->start() ;

$BB->inst(7) ;
while (1){
    #warn $BB->show() ;
    $BB->inst() ;
    #warn $BB->show() ;
    # $BB->get("RAM")->dump(20) ;
    $BB->inst(6) ;
}
exit ;

my $inst = 0 ;
while (1){
    if ($inst == 73){
        $BB->get("RAM")->dump(20) ;
        exit ;
    }
    map {
        $BB->step() ;
    } (0..2) ;   
    warn "INSTRUCTION " . $inst++ . ": " . $BB->get("IR")->power() . ", addr:" . $BB->get("IAR")->power() ;
    map {
        $BB->step() ;
    } (0..2) ;  
}


$BB->get("CLK")->start() ;



__DATA__
# Activate ROM
00100000 # DATA  R0, 00000000 (0)
00000000 # ...   0
01111100 # OUTA  R0
# R0 is our 1, R3 is our 0, R1 is our ROM address, R2 is our ROM data
00100000 # DATA  R0, 00000001 (1)
00000001 # ...   1
00100011 # DATA  R3, 00000000 (0)
00000000 # ...   0
00100001 # DATA  R1, 00000000 (0)
00000000 # ...   0
# Label 'Ask for address in R1' at position 9
01111001 # OUTD  R1
# # Receive data in R2 and copy it to RAM at address that is in R1
01110010 # IND   R2
00011001 # ST    R2, R1
# IF R2 == 0 jump to byte 0 in RAM
11111011 # CMP   R2, R3
01010010 # JE    00000000 (0)
00000000 # ...   0
# # Increment R1 and loop back
10000001 # ADD   R0, R1
01000000 # JMP   00001001 (9)
00001001 # ...   9