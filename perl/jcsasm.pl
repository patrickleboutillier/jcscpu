use strict ;
use jcsasm ;
use Devices ;

eval join("", (scalar(@ARGV) ? <> : <STDIN>)) ;
die "$@\n" if $@ ;
