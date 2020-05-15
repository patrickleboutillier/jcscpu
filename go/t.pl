use strict ;
use Time::HiRes qw(time) ;

my $n = 0 ;

sub f {
	$n++ ;
}

my $start = time() ;

while ($n < 10000000) {
	f() ;
}

my $end = time() ;
my $elapsed = $end - $start ;
printf("Elapsed: %d %lf ms", $n, $elapsed * 1000) ;