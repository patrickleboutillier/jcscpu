package gate

import (
	"testing"
)

func TestPower(t *testing.T) {
	w := NewWire()
	if w.GetPower() {
		t.Errorf("power should be initialized at false")
	}
	w.SetPower(true)
	if !w.GetPower() {
		t.Errorf("power should have been set to true")
	}
	w.SetPower(false)
	if w.GetPower() {
		t.Errorf("power should have been set to false")
	}
}

func TestPrehooks(t *testing.T) {
	n := 0
	w := NewWire()
	w.AddPrehook(func(v bool) { n++ })
	w.SetPower(false)
	if n != 1 {
		t.Errorf("prehook not called")
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
