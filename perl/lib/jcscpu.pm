package jcscpu ;

use strict ;
use Breadboard ;


$jcscpu::VERSION = '1.0' ;


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
    warn "$line" ;
    next unless $line =~ /^([01]{8})\b/ ;
    my $inst = $1 ;
    $BB->setRAM(sprintf("%08b", $addr++), $inst) ;
}


1 ;
