package board

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
	p "github.com/patrickleboutillier/jcscpu/pkg/parts"
)

func InstProc(this *Breadboard) {
	// Add instruction related registers
	this.putWire("IAR.s", g.NewWire())
	this.putWire("IAR.e", g.NewWire())
	this.putWire("IR.s", g.NewWire())
	this.putWire("IR.e", g.WireOn()) // IR.e is always on
	this.putBus("IR.bus", g.NewBusN(8))

	this.putReg("IAR", p.NewRegister(this.GetBus("DATA.bus"), this.GetWire("IAR.s"), this.GetWire("IAR.e"), this.GetBus("DATA.bus"), "IAR"))
	// IR uses only the first 8 bits of the DATA.bus
	dbs := g.WrapBus(this.GetBus("DATA.bus").GetWires()[this.GetBus("DATA.bus").GetSize()-8:])
	this.putReg("IR", p.NewRegister(dbs, this.GetWire("IR.s"), this.GetWire("IR.e"), this.GetBus("IR.bus"), "IR"))

	// ALL ENABLES
	for _, e := range []string{"IAR", "RAM", "ACC"} {
		w := g.NewWire()
		g.NewAND(this.GetWire("CLK.clke"), w, this.GetWire(fmt.Sprintf("%s.e", e)))
		this.putORe(fmt.Sprintf("%s.ena.eor", e), g.NewORe(w))
	}
	this.putORe("BUS1.bit1.eor", g.NewORe(this.GetWire("BUS1.bit1")))

	// ALL SETS
	for _, s := range []string{"IR", "RAM.MAR", "IAR", "ACC", "RAM", "TMP", "FLAGS"} {
		w := g.NewWire()
		g.NewAND(this.GetWire("CLK.clks"), w, this.GetWire(fmt.Sprintf("%s.s", s)))
		this.putORe(fmt.Sprintf("%s.set.eor", s), g.NewORe(w))
	}

	// Hook up the circuit used to process the first 3 steps of each cycle (see page 108 in book), i.e
	// - Load IAR to MAR and increment IAR in AC
	// - Load the instruction from RAM into IR
	// - Increment the IAR from ACC
	this.GetORe("BUS1.bit1.eor").AddWire(this.GetBus("STP.bus").GetWire(0))
	this.GetORe("IAR.ena.eor").AddWire(this.GetBus("STP.bus").GetWire(0))
	this.GetORe("RAM.MAR.set.eor").AddWire(this.GetBus("STP.bus").GetWire(0))
	this.GetORe("ACC.set.eor").AddWire(this.GetBus("STP.bus").GetWire(0))

	this.GetORe("RAM.ena.eor").AddWire(this.GetBus("STP.bus").GetWire(1))
	this.GetORe("IR.set.eor").AddWire(this.GetBus("STP.bus").GetWire(1))

	this.GetORe("ACC.ena.eor").AddWire(this.GetBus("STP.bus").GetWire(2))
	this.GetORe("IAR.set.eor").AddWire(this.GetBus("STP.bus").GetWire(2))
}

func InstImpl(this *Breadboard) {
	// Then, we set up the parts that are required to actually implement instructions, i.e.
	// - Connect the decoders for the enable and set operations on R0-R3

	this.putWire("REGA.e", g.NewWire())
	this.putWire("REGB.e", g.NewWire())
	this.putWire("REGB.s", g.NewWire())

	this.putORe("REGA.ena.eor", g.NewORe(this.GetWire("REGA.e")))
	this.putORe("REGB.ena.eor", g.NewORe(this.GetWire("REGB.e")))
	this.putORe("REGB.set.eor", g.NewORe(this.GetWire("REGB.s")))

	// s side
	sdeco := make([]*g.Wire, 4, 4)
	for i, s := range []string{"R0", "R1", "R2", "R3"} {
		w := g.NewWire()
		g.NewANDn(g.WrapBusV(this.GetWire("CLK.clks"), this.GetWire("REGB.s"), w), this.GetWire(fmt.Sprintf("%s.s", s)))
		sdeco[i] = w
	}
	sdecbus := g.WrapBus(sdeco)
	this.putBus("REGB.s.dec.bus", sdecbus)
	p.NewDecoder(g.WrapBusV(this.GetBus("IR.bus").GetWire(6), this.GetBus("IR.bus").GetWire(7)), sdecbus)

	// e side
	edecoa := make([]*g.Wire, 4, 4)
	edecob := make([]*g.Wire, 4, 4)
	for i, e := range []string{"R0", "R1", "R2", "R3"} {
		wora := g.NewWire()
		worb := g.NewWire()
		g.NewOR(wora, worb, this.GetWire(fmt.Sprintf("%s.e", e)))

		wa := g.NewWire()
		g.NewANDn(g.WrapBusV(this.GetWire("CLK.clke"), this.GetWire("REGA.e"), wa), wora)
		edecoa[i] = wa
		wb := g.NewWire()
		g.NewANDn(g.WrapBusV(this.GetWire("CLK.clke"), this.GetWire("REGB.e"), wb), worb)
		edecob[i] = wb
	}
	edecbusa := g.WrapBus(edecoa)
	edecbusb := g.WrapBus(edecob)
	this.putBus("REGA.e.dec.bus", edecbusa)
	this.putBus("REGB.e.dec.bus", edecbusb)
	p.NewDecoder(g.WrapBusV(this.GetBus("IR.bus").GetWire(4), this.GetBus("IR.bus").GetWire(5)), edecbusa)
	p.NewDecoder(g.WrapBusV(this.GetBus("IR.bus").GetWire(6), this.GetBus("IR.bus").GetWire(7)), edecbusb)

	// Finally, install the instruction decoder
	this.putBus("INST.bus", g.NewBusN(8))
	notalu := g.NewWire()
	g.NewNOT(this.GetBus("IR.bus").GetWire(0), notalu)
	idecbus := g.NewBusN(8)
	p.NewDecoder(g.WrapBusV(this.GetBus("IR.bus").GetWire(1), this.GetBus("IR.bus").GetWire(2), this.GetBus("IR.bus").GetWire(3)), idecbus)
	for j := 0; j < 8; j++ {
		g.NewAND(notalu, idecbus.GetWire(j), this.GetBus("INST.bus").GetWire(j))
	}

	// Now, setting up instruction circuits involves:
	// - Hook up to the proper wire of INST.bus
	// - Wire up the logical circuit and attach it to proper step wires
	// - Use the "elastic" OR gates (xxx.eor) to enable and set
}
