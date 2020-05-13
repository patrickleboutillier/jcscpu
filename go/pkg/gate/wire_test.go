package gate

import (
	"testing"
)

func TestPower(t *testing.T) {
	w := NewWire()
	if GetPower(w) {
		t.Errorf("power should be initialized at false")
	}
	SetPower(w, true)
	if !GetPower(w) {
		t.Errorf("power should have been set to true")
	}
	SetPower(w, false)
	if GetPower(w) {
		t.Errorf("power should have been set to false")
	}
}

/*

# Coverage for WIRE
my $w = new WIRE() ;
$w->prehook(sub { ok(1, "Hook called") }) ;
$w->prehook() ;
$w->power(1) ;
$w->terminal() ;
$w->power(0) ;
is($w->power(), 1, "Terminal froze the wire") ;

*/
