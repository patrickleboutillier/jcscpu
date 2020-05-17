package parts

import (
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/go/internal/testmore"
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

/*
use strict
use Test::More
use Register
use Data::Dumper


// Basic test for Register circuit.
bin = NewBUS()
bout = NewBUS()
ws = NewWire()
we = NewWire()
R = NewRegister(bin, ws, we, bout)
R.show()

// Let input from the input bus into the register and turn on the enabler
ws.GetPower(1)
we.GetPower(1)
if bout.GetPower() != "00000000" {
	t.Errorf("R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, initial state, output should be 0")
}
ws.GetPower(0)
bin.GetWire(0).GetPower(1)
if bout.GetPower() != "00000000" {
	t.Errorf("R(i:10000000,s:0,e:1)=o:00000000, s=off, e=on, since s=off, output should be 0")
}
ws.GetPower(1)
if bout.GetPower() != "10000000" {
	t.Errorf("R(i:10000000,s:1,e:1)=o:10000000, s=on, e=on, both s and e on, i should flow to o")
}
ws.GetPower(0)
we.GetPower(0)
if bout.GetPower() != "00000000" {
	t.Errorf("R(i:10000000,s:0,e:0)=o:00000000, s=on, e=off, no output since e=off")
}
bin.GetWire(0).GetPower(0)
ws.GetPower(1)
we.GetPower(1)
if bout.GetPower() != "00000000" {
	t.Errorf("R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, i flows, so 0")
}


// Some BUS coverage tests
eval {
    bin.GetWire(-1)
}
like(@, qr/Invalid wire index/, "Invalid wire index <0")
eval {
    bin.GetWire(10)
}
like(@, qr/Invalid wire index/, "Invalid wire index >7")
eval {
    bin.GetPower("1100")
}
like(@, qr/Invalid bus GetPower string/, "Invalid bus GetPower string <8")


// Tests using a REGISTRY with input and output on the same BUS.
bio = NewBUS()
ws = NewWire()
we = NewWire()
R = NewRegister(bio, ws, we, bio)

// Let input from the input bus into the register and turn on the enabler
ws.GetPower(1)
we.GetPower(1)
if bio.GetPower() != "00000000" {
	t.Errorf("R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, initial state, output should be 0")
}
ws.GetPower(0)
we.GetPower(0)
// Setup up the bus with our desired data, and let in into the registry.
bio.GetPower("10101010")
if bio.GetPower() != "10101010" {
	t.Errorf("Data setup")
}
ws.GetPower(1)
ws.GetPower(0)
// Reset bus
bio.GetPower("00000000")
if bio.GetPower() != "00000000" {
	t.Errorf("Bus reset")
}
we.GetPower(1)
if bio.GetPower() != "10101010" {
	t.Errorf("Data restored")
}
*/

func TestRegisterMultiple(t *testing.T) {
	// Multiple registers.
	bio := g.NewBus()
	ws1 := g.NewWire()
	we1 := g.NewWire()
	ws2 := g.NewWire()
	we2 := g.NewWire()
	ws3 := g.NewWire()
	we3 := g.NewWire()
	NewRegister(bio, ws1, we1, bio, "R1")
	NewRegister(bio, ws2, we2, bio, "R2")
	NewRegister(bio, ws3, we3, bio, "R3")

	// Put something on the bus.
	bio.SetPower("00001111")
	tm.IsString(t, bio.GetPower(), "00001111", "Data setup")
	// Let it go into R1
	ws1.SetPower(true)
	ws1.SetPower(false)
	// Check it is into R1
	we1.SetPower(true)
	tm.IsString(t, bio.GetPower(), "00001111", "From R1")
	we1.SetPower(false)
	// Copy into R3
	we1.SetPower(true)
	ws3.SetPower(true)
	ws3.SetPower(false)
	// Reset bus
	bio.SetPower("00000000")
	tm.IsString(t, bio.GetPower(), "00000000", "Reset")
	we3.SetPower(true)
	tm.IsString(t, bio.GetPower(), "00001111", "From R3")
	we3.SetPower(false)
	// Copy to R2
	we3.SetPower(true)
	ws2.SetPower(true)
	ws2.SetPower(false)
	// Reset bus
	bio.SetPower("00000000")
	tm.IsString(t, bio.GetPower(), "00000000", "Reset")
	we2.SetPower(true)
	tm.IsString(t, bio.GetPower(), "00001111", "From R2")
	we3.SetPower(false)
}
