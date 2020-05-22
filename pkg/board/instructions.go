package board

import (
	g "github.com/patrickleboutillier/jcscpu/pkg/gates"
	p "github.com/patrickleboutillier/jcscpu/pkg/parts"
)

func init() {
	instHandlers["ALU"] = ALUInstructions
	instHandlers["LDST"] = LDSTInstructions
	instHandlers["DATA"] = DATAInstructions
	instHandlers["JUMP"] = JUMPInstructions
	instHandlers["CLF"] = CLFInstructions
	instHandlers["IO"] = IOInstructions
}

func ALUInstructions(BB *Breadboard) {
	aa1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("IR.bus").GetWire(0), aa1)
	BB.GetORe("REGB.ena.eor").AddWire(aa1)
	BB.GetORe("TMP.set.eor").AddWire(aa1)

	aa2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("IR.bus").GetWire(0), aa2)
	BB.GetORe("REGA.ena.eor").AddWire(aa2)
	BB.GetORe("ALU.ci.ena.eor").AddWire(aa2) // Errata //2
	BB.GetORe("ACC.set.eor").AddWire(aa2)
	BB.GetORe("FLAGS.set.eor").AddWire(aa2)

	wnotcmp := g.NewWire()
	aa3 := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("STP.bus").GetWire(5), BB.GetBus("IR.bus").GetWire(0), wnotcmp), aa3)
	BB.GetORe("ACC.ena.eor").AddWire(aa3)
	BB.GetORe("REGB.set.eor").AddWire(aa3)

	// Operation selector
	w := g.NewWire()
	g.NewNOT(w, wnotcmp)
	cmpbus := g.WrapBusV(BB.GetBus("IR.bus").GetWire(1), BB.GetBus("IR.bus").GetWire(2), BB.GetBus("IR.bus").GetWire(3))
	g.NewANDn(cmpbus, w)

	for j := 0; j < 3; j++ {
		g.NewANDn(g.WrapBusV(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("IR.bus").GetWire(0), cmpbus.GetWire(j)), BB.GetBus("ALU.op").GetWire(j))
	}
}

func LDSTInstructions(BB *Breadboard) {
	l1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(0), l1)
	BB.GetORe("REGA.ena.eor").AddWire(l1)
	BB.GetORe("RAM.MAR.set.eor").AddWire(l1)

	l2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(0), l2)
	BB.GetORe("RAM.ena.eor").AddWire(l2)
	BB.GetORe("REGB.set.eor").AddWire(l2)

	s1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(1), s1)
	BB.GetORe("REGA.ena.eor").AddWire(s1)
	BB.GetORe("RAM.MAR.set.eor").AddWire(s1)

	s2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(1), s2)
	BB.GetORe("REGB.ena.eor").AddWire(s2)
	BB.GetORe("RAM.set.eor").AddWire(s2)
}

func DATAInstructions(BB *Breadboard) {
	d1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(2), d1)
	BB.GetORe("BUS1.bit1.eor").AddWire(d1)
	BB.GetORe("IAR.ena.eor").AddWire(d1)
	BB.GetORe("RAM.MAR.set.eor").AddWire(d1)
	BB.GetORe("ACC.set.eor").AddWire(d1)

	d2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(2), d2)
	BB.GetORe("RAM.ena.eor").AddWire(d2)
	BB.GetORe("REGB.set.eor").AddWire(d2)

	d3 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(5), BB.GetBus("INST.bus").GetWire(2), d3)
	BB.GetORe("ACC.ena.eor").AddWire(d3)
	BB.GetORe("IAR.set.eor").AddWire(d3)
}

func JUMPInstructions(BB *Breadboard) {
	// JUMPR
	jr1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(3), jr1)
	BB.GetORe("REGB.ena.eor").AddWire(jr1)
	BB.GetORe("IAR.set.eor").AddWire(jr1)

	// JUMP
	j1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(4), j1)
	BB.GetORe("IAR.ena.eor").AddWire(j1)
	BB.GetORe("RAM.MAR.set.eor").AddWire(j1)

	j2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(4), j2)
	BB.GetORe("RAM.ena.eor").AddWire(j2)
	BB.GetORe("IAR.set.eor").AddWire(j2)

	// JUMPIF
	ji1 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(5), ji1)
	BB.GetORe("BUS1.bit1.eor").AddWire(ji1)
	BB.GetORe("IAR.ena.eor").AddWire(ji1)
	BB.GetORe("RAM.MAR.set.eor").AddWire(ji1)
	BB.GetORe("ACC.set.eor").AddWire(ji1)

	ji2 := g.NewWire()
	g.NewAND(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(5), ji2)
	BB.GetORe("ACC.ena.eor").AddWire(ji2)
	BB.GetORe("IAR.set.eor").AddWire(ji2)

	ji3 := g.NewWire()
	flago := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("STP.bus").GetWire(5), BB.GetBus("INST.bus").GetWire(5), flago), ji3)
	BB.GetORe("RAM.ena.eor").AddWire(ji3)
	BB.GetORe("IAR.set.eor").AddWire(ji3)

	fbus := g.NewBusN(4)
	for j := 0; j < 4; j++ {
		g.NewAND(BB.GetBus("FLAGS.bus").GetWire(j), BB.GetBus("IR.bus").GetWire(j+4), fbus.GetWire(j))
	}
	g.NewORn(fbus, flago)
}

func CLFInstructions(BB *Breadboard) {
	// Use the last 4 bits of the CLF instruction for control instructions.
	breg := g.WrapBusV(BB.GetBus("IR.bus").GetWire(4), BB.GetBus("IR.bus").GetWire(5), BB.GetBus("IR.bus").GetWire(6), BB.GetBus("IR.bus").GetWire(7))
	binst := g.NewBusN(16)
	p.NewDecoder(breg, binst)

	// CLF, 0110000
	cl1 := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("INST.bus").GetWire(6), BB.GetBus("STP.bus").GetWire(3), binst.GetWire(0)), cl1)
	BB.GetORe("BUS1.bit1.eor").AddWire(cl1)
	BB.GetORe("FLAGS.set.eor").AddWire(cl1)

	// HALT, 01100001
	hlt1 := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("INST.bus").GetWire(6), BB.GetBus("STP.bus").GetWire(3), binst.GetWire(1)), hlt1)
	hlt1.AddPrehook(func(v bool) {
		if v {
			BB.CLK.Stop()
		}
	})

	// TODO:
	// DEBUG3,2,1,0
	// END (for specifying the end of a program in ROM)
}

func IOInstructions(BB *Breadboard) {
	// IO
	io1 := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("STP.bus").GetWire(3), BB.GetBus("INST.bus").GetWire(7), BB.GetBus("IR.bus").GetWire(4)), io1)
	BB.GetORe("REGB.ena.eor").AddWire(io1)

	ion4 := g.NewWire()
	g.NewNOT(BB.GetBus("IR.bus").GetWire(4), ion4)
	io2 := g.NewWire()
	g.NewANDn(g.WrapBusV(BB.GetBus("STP.bus").GetWire(4), BB.GetBus("INST.bus").GetWire(7), ion4), io2)
	BB.GetORe("REGB.set.eor").AddWire(io2)

	g.NewAND(BB.GetWire("CLK.clks"), io1, BB.GetWire("IO.clks"))
	g.NewAND(BB.GetWire("CLK.clke"), io2, BB.GetWire("IO.clke"))
	g.NewCONN(BB.GetBus("IR.bus").GetWire(4), BB.GetWire("IO.io"))
	g.NewCONN(BB.GetBus("IR.bus").GetWire(5), BB.GetWire("IO.da"))
}
