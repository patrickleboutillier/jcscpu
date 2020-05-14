use strict ;
use jcshll ;
use Devices ;

eval join("", (scalar(@ARGV) ? <> : <STDIN>)) ;
die "$@\n" if $@ ;
