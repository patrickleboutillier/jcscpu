use strict ;
use FindBin ;
use lib "$FindBin::Bin" ;
use jcsasm ;

sub TTY() {
    return 0 ;
} 

sub RNG() {
    return 1 ;
} 

sub ROM() {
    return 2 ;
} 

sub ROM_SIZE() {
    return 2 ;
}

eval join("", (scalar(@ARGV) ? <> : <STDIN>)) ;
die "$@\n" if $@ ;
