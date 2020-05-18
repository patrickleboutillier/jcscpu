package parts

import (
	"fmt"
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/go/internal/testmore"
	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
)

func TestRegisterBasic(t *testing.T) {
	// Basic test for Register circuit.
	bin := g.NewBus()
	bout := g.NewBus()
	ws := g.NewWire()
	we := g.NewWire()
	R := NewRegister(bin, ws, we, bout, "R")

	// Let input from the input bus into the register and turn on the enabler
	ws.SetPower(true)
	we.SetPower(true)
	tm.Is(t, bout.GetPower(), 0b00000000, "R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, initial state, output should be 0")
	ws.SetPower(false)
	bin.GetBit(7).SetPower(true)
	tm.Is(t, bout.GetPower(), 0b00000000, "R(i:10000000,s:0,e:1)=o:00000000, s=off, e=on, since s=off, output should be 0")
	ws.SetPower(true)
	tm.Is(t, bout.GetPower(), 0b10000000, "R(i:10000000,s:1,e:1)=o:10000000, s=on, e=on, both s and e on, i should flow to o")
	ws.SetPower(false)
	we.SetPower(false)
	tm.Is(t, bout.GetPower(), 0b00000000, "R(i:10000000,s:0,e:0)=o:00000000, s=on, e=off, no output since e=off")
	bin.GetBit(7).SetPower(false)
	ws.SetPower(true)
	we.SetPower(true)
	tm.Is(t, bout.GetPower(), 0b00000000, "R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, i flows, so 0")

	tm.Is(t, R.GetPower(), 0b00000000, "R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, i flows, so 0")
	tm.Is(t, R.String(), fmt.Sprintf("R:1/%s/1", R.bus.String()), "Show R")
}

func TestRegisterIO(t *testing.T) {
	// Tests using a REGISTRY with input and output on the same BUS.
	bio := g.NewBus()
	ws := g.NewWire()
	we := g.NewWire()
	NewRegister(bio, ws, we, bio, "R")

	// Let input from the input bus into the register and turn on the enabler
	ws.SetPower(true)
	we.SetPower(true)
	tm.Is(t, bio.GetPower(), 0b00000000, "R(i:00000000,s:1,e:1)=o:00000000, s=on, e=on, initial state, output should be 0")
	ws.SetPower(false)
	we.SetPower(false)
	// Setup up the bus with our desired data, and let in into the registry.
	bio.SetPower(0b10101010)
	tm.Is(t, bio.GetPower(), 0b10101010, "Data setup")
	ws.SetPower(true)
	ws.SetPower(false)
	// Reset bus
	bio.SetPower(0b00000000)
	tm.Is(t, bio.GetPower(), 0b00000000, "Bus reset")
	we.SetPower(true)
	tm.Is(t, bio.GetPower(), 0b10101010, "Data restored")
}

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
	bio.SetPower(0b00001111)
	tm.Is(t, bio.GetPower(), 0b00001111, "Data setup")
	// Let it go into R1
	ws1.SetPower(true)
	ws1.SetPower(false)
	// Check it is into R1
	we1.SetPower(true)
	tm.Is(t, bio.GetPower(), 0b00001111, "From R1")
	we1.SetPower(false)
	// Copy into R3
	we1.SetPower(true)
	ws3.SetPower(true)
	ws3.SetPower(false)
	// Reset bus
	bio.SetPower(0b00000000)
	tm.Is(t, bio.GetPower(), 0b00000000, "Reset")
	we3.SetPower(true)
	tm.Is(t, bio.GetPower(), 0b00001111, "From R3")
	we3.SetPower(false)
	// Copy to R2
	we3.SetPower(true)
	ws2.SetPower(true)
	ws2.SetPower(false)
	// Reset bus
	bio.SetPower(0b00000000)
	tm.Is(t, bio.GetPower(), 0b00000000, "Reset")
	we2.SetPower(true)
	tm.Is(t, bio.GetPower(), 0b00001111, "From R2")
	we3.SetPower(false)
}
