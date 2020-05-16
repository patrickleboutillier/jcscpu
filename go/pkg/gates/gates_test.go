package gates

import (
	"fmt"
	"math/rand"
	"testing"
)

var max_n_tests int = 8

func TestNAND(t *testing.T) {
	var tests = []struct {
		a, b, c bool
	}{
		{false, false, true},
		{false, true, true},
		{true, false, true},
		{true, true, false},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewNAND(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			if wc.GetPower() != tt.c {
				t.Errorf("got %t, expected %t", wc.GetPower(), tt.c)
			}
		})
	}
}

func TestNOT(t *testing.T) {
	var tests = []struct {
		a, b bool
	}{
		{false, true},
		{true, false},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			NewNOT(wa, wb)
			wa.SetPower(tt.a)
			if wb.GetPower() != tt.b {
				t.Errorf("got %t, expected %t", wb.GetPower(), tt.b)
			}
		})
	}
}

func TestCONN(t *testing.T) {
	var tests = []struct {
		a, b bool
	}{
		{false, false},
		{true, true},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			NewCONN(wa, wb)
			wa.SetPower(tt.a)
			if wb.GetPower() != tt.b {
				t.Errorf("got %t, expected %t", wb.GetPower(), tt.b)
			}
		})
	}
}

func TestAND(t *testing.T) {
	var tests = []struct {
		a, b, c bool
	}{
		{false, false, false},
		{false, true, false},
		{true, false, false},
		{true, true, true},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewAND(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			if wc.GetPower() != tt.c {
				t.Errorf("got %t, expected %t", wc.GetPower(), tt.c)
			}
		})
	}
}

func TestOR(t *testing.T) {
	var tests = []struct {
		a, b, c bool
	}{
		{false, false, false},
		{false, true, true},
		{true, false, true},
		{true, true, true},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewOR(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			if wc.GetPower() != tt.c {
				t.Errorf("got %t, expected %t", wc.GetPower(), tt.c)
			}
		})
	}
}

func TestXOR(t *testing.T) {
	var tests = []struct {
		a, b, c bool
	}{
		{false, false, false},
		{false, true, true},
		{true, false, true},
		{true, true, false},
	}

	for _, tt := range tests {
		testname := fmt.Sprintf("%t,%t", tt.a, tt.b)
		t.Run(testname, func(t *testing.T) {
			wa := NewWire()
			wb := NewWire()
			wc := NewWire()
			NewXOR(wa, wb, wc)
			wa.SetPower(tt.a)
			wb.SetPower(tt.b)
			if wc.GetPower() != tt.c {
				t.Errorf("got %t, expected %t", wc.GetPower(), tt.c)
			}
		})
	}
}

func TestANDn(t *testing.T) {
	for n := 2; n <= max_n_tests; n++ {
		bis := NewBusN(n)
		wo := NewWire()
		NewANDn(n, bis, wo)

		max := 1 << n
		for j := 0; j < max; j++ {
			x := j
			for _, r := range [2]bool{false, true} {
				if r {
					x = rand.Intn(max)
				}

				testname := fmt.Sprintf("%d,%t,%d", n, r, x)
				t.Run(testname, func(t *testing.T) {
					bis.SetPowerInt(x)
					res := (x == (max - 1))
					if wo.GetPower() != res {
						t.Errorf("AND%d(%d)=%t", n, x, res)
					}
				})
			}
		}
	}
}

func TestORn(t *testing.T) {
	for n := 2; n <= max_n_tests; n++ {
		bis := NewBusN(n)
		wo := NewWire()
		NewORn(n, bis, wo)

		max := 1 << n
		for j := 0; j < max; j++ {
			x := j
			for _, r := range [2]bool{false, true} {
				if r {
					x = rand.Intn(max)
				}

				testname := fmt.Sprintf("%d,%t,%d", n, r, x)
				t.Run(testname, func(t *testing.T) {
					bis.SetPowerInt(x)
					res := (x != 0)
					if wo.GetPower() != res {
						t.Errorf("OR%d(%d)=%t", n, x, res)
					}
				})
			}
		}
	}
}

func tpanic(t *testing.T, f func()) {
	defer func() {
		if r := recover(); r == nil {
			t.Errorf("Not panicking!")
		}
	}()
	f()
}

func TestGateErrors(t *testing.T) {
	/*
		eval {
			new ANDn(1, new BUS(), new WIRE()) ;
		} ;
		like($@, qr/Invalid ANDn number of inputs/, "Invalid ANDn number of inputs <=2") ;
		my $a = new ANDn(4, , new BUS(), new WIRE()) ;
		$a->i(0) ;
		is($a->n(), 4, "Size of ANDn") ;
		eval { $a->i(-1) } ;
		like($@, qr/Invalid input index/, "Invalid input index <0") ;
		eval { $a->i(6) } ;
		like($@, qr/Invalid input index/, "Invalid input index >n") ;

		eval {
			new ORn(1, new BUS(), new WIRE()) ;
		} ;
		like($@, qr/Invalid ORn number of inputs/, "Invalid ORn number of inputs <=2") ;
		my $o = new ORn(4, new BUS(), new WIRE()) ;
		$o->i(0) ;
		is($o->n(), 4, "Size of ORn") ;
		eval { $o->i(-1) ;} ;
		like($@, qr/Invalid input index/, "Invalid input index <0") ;
		eval { $o->i(6) ;} ;
		like($@, qr/Invalid input index/, "Invalid input index >n") ;
	*/

	f := func() {
		o := NewORe(NewWire())
		for j := 0; j < 6; j++ {
			o.AddWire(NewWire())
		}
		o.AddWire(NewWire())
	}
	tpanic(t, f)
}

/*
# ADD
my $wa = new WIRE() ;
my $wb = new WIRE() ;
my $wci = new WIRE() ;
my $wsum = new WIRE() ;
my $wco = new WIRE() ;
my $a = new ADD($wa, $wb, $wci, $wsum, $wco) ;

$wa->power(0) ;
$wb->power(0) ;
$wci->power(0) ;
is($wsum->power(), 0, "ADD(0,0,0)=(0,0)") ;
is($wco->power(),  0, "ADD(0,0,0)=(0,0)") ;
$wa->power(1) ;
$wb->power(0) ;
$wci->power(0) ;
is($wsum->power(), 1, "ADD(1,0,0)=(1,0)") ;
is($wco->power(),  0, "ADD(1,0,0)=(1,0)") ;
$wa->power(0) ;
$wb->power(1) ;
$wci->power(0) ;
is($wsum->power(), 1, "ADD(0,1,0)=(1,0)") ;
is($wco->power(),  0, "ADD(0,1,0)=(1,0)") ;
$wa->power(1) ;
$wb->power(1) ;
$wci->power(0) ;
is($wsum->power(), 0, "ADD(1,1,0)=(0,1)") ;
is($wco->power(),  1, "ADD(1,1,0)=(0,1)") ;

$wa->power(0) ;
$wb->power(0) ;
$wci->power(1) ;
is($wsum->power(), 1, "ADD(0,0,1)=(1,0)") ;
is($wco->power(),  0, "ADD(0,0,1)=(1,0)") ;
$wa->power(1) ;
$wb->power(0) ;
$wci->power(1) ;
is($wsum->power(), 0, "ADD(1,0,1)=(0,1)") ;
is($wco->power(),  1, "ADD(1,0,1)=(0,1)") ;
$wa->power(0) ;
$wb->power(1) ;
$wci->power(1) ;
is($wsum->power(), 0, "ADD(0,1,1)=(0,1)") ;
is($wco->power(),  1, "ADD(0,1,1)=(0,1)") ;
$wa->power(1) ;
$wb->power(1) ;
$wci->power(1) ;
is($wsum->power(), 1, "ADD(1,1,1)=(1,1)") ;
is($wco->power(),  1, "ADD(1,1,1)=(1,1)") ;


# Basic tests for CMP gate.
my $wa = new WIRE() ;
my $wb = new WIRE() ;
my $weqi = new WIRE() ;
my $wali = new WIRE() ;
my $wc = new WIRE() ;
my $weqo = new WIRE() ;
my $walo = new WIRE() ;
my $c = new CMP($wa, $wb, $weqi, $wali, $wc, $weqo, $walo) ;

$weqi->power(0) ;
$wali->power(0) ;
$wa->power(0) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,0,0], "CMP(a:0,b:0,eqi:0,ali:0)=(c:0,eqo:0,alo:0)") ;
$wa->power(0) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,0], "CMP(a:0,b:1,eqi:0,ali:0)=(c:1,eqo:0,alo:0)") ;
$wa->power(1) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,0], "CMP(a:1,b:0,eqi:0,ali:0)=(c:1,eqo:0,alo:0)") ;
$wa->power(1) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,0,0], "CMP(a:1,b:1,eqi:0,ali:0)=(c:0,eqo:0,alo:0)") ;

$weqi->power(0) ;
$wali->power(1) ;
$wa->power(0) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,0,1], "CMP(a:0,b:0,eqi:0,ali:1)=(c:0,eqo:0,alo:1)") ;
$wa->power(0) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,1], "CMP(a:0,b:1,eqi:0,ali:1)=(c:1,eqo:0,alo:1)") ;
$wa->power(1) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,1], "CMP(a:1,b:0,eqi:0,ali:1)=(c:1,eqo:0,alo:1)") ;
$wa->power(1) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,0,1], "CMP(a:1,b:1,eqi:0,ali:1)=(c:0,eqo:0,alo:1)") ;

$weqi->power(1) ;
$wali->power(0) ;
$wa->power(0) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,1,0], "CMP(a:0,b:0,eqi:1,ali:0)=(c:0,eqo:1,alo:0)") ;
$wa->power(0) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,0], "CMP(a:0,b:1,eqi:1,ali:0)=(c:1,eqo:0,alo:0)") ;
$wa->power(1) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,1], "CMP(a:1,b:0,eqi:1,ali:0)=(c:1,eqo:0,alo:1)") ;
$wa->power(1) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,1,0], "CMP(a:1,b:1,eqi:1,ali:0)=(c:0,eqo:1,alo:0)") ;


$weqi->power(1) ;
$wali->power(1) ;
$wa->power(0) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,1,1], "CMP(a:0,b:0,eqi:1,ali:1)=(c:0,eqo:1,alo:1)") ;
$wa->power(0) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,1], "CMP(a:0,b:1,eqi:1,ali:1)=(c:1,eqo:0,alo:1)") ;
$wa->power(1) ;
$wb->power(0) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [1,0,1], "CMP(a:1,b:0,eqi:1,ali:1)=(c:1,eqo:0,alo:1)") ;
$wa->power(1) ;
$wb->power(1) ;
is_deeply([$wc->power(),$weqo->power(),$walo->power()], [0,1,1], "CMP(a:1,b:1,eqi:1,ali:1)=(c:0,eqo:1,alo:1)") ;






*/
