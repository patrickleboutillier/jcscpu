package board

import (
	"fmt"

	g "github.com/patrickleboutillier/jcscpu/go/pkg/gates"
	p "github.com/patrickleboutillier/jcscpu/go/pkg/parts"
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
	/*
	   this.put(
	       "REGA.e", NewWire(),
	       "REGB.e", NewWire(),
	       "REGB.s", NewWire(),
	   ) ;
	   this.put(
	       "REGA.ena.eor", new ORe(this.GetBus("REGA.e")),
	       "REGB.ena.eor", new ORe(this.GetBus("REGB.e")),
	       "REGB.set.eor", new ORe(this.GetBus("REGB.s")),
	   ) ;

	   # s side
	   my @sdeco = () ;
	   for my s (qw/R0 R1 R2 R3/){
	       my w = NewWire() ;
	       new ANDn(3, BUS.wrap(this.GetBus("CLK.clks"), this.GetBus("REGB.s"), w), this.GetBus("s.s")) ;
	       push @sdeco, w ;
	   }
	   this.put("REGB.s.dec", new DECODER(2, BUS.wrap(this.GetBus("IR").os().GetWire(6), this.GetBus("IR").os().GetWire(7)), BUS.wrap(@sdeco))) ;

	   # e side
	   my @edecoa = () ;
	   my @edecob = () ;
	   for my s (qw/R0 R1 R2 R3/){
	       my wora = NewWire() ;
	       my worb = NewWire() ;
	       new OR(wora, worb, this.GetBus("s.e")) ;

	       my wa = NewWire() ;
	       new ANDn(3, BUS.wrap(this.GetBus("CLK.clke"), this.GetBus("REGA.e"), wa), wora) ;
	       push @edecoa, wa ;
	       my wb = NewWire() ;
	       new ANDn(3, BUS.wrap(this.GetBus("CLK.clke"), this.GetBus("REGB.e"), wb), worb) ;
	       push @edecob, wb ;
	   }
	   this.put("REGA.e.dec", new DECODER(2, BUS.wrap(this.GetBus("IR").os().GetWire(4), this.GetBus("IR").os().GetWire(5)), BUS.wrap(@edecoa))) ;
	   this.put("REGB.e.dec", new DECODER(2, BUS.wrap(this.GetBus("IR").os().GetWire(6), this.GetBus("IR").os().GetWire(7)), BUS.wrap(@edecob))) ;

	   # Finally, install the instruction decoder
	   this.put('INST.bus', new BUS()) ;
	   my notalu = NewWire() ;
	   new NOT(this.GetBus("IR").os().GetWire(0), notalu) ;
	   my idec = new DECODER(3, BUS.wrap(map { this.GetBus("IR").os().GetWire(_) } (1,2,3)), new BUS()) ;
	   for (my j = 0 ; j < 8 ; j++){
	       new AND(notalu, idec.os().GetWire(j), this.GetBus("INST.bus").GetWire(j)) ;
	   }
	*/

	// Now, setting up instruction circuits involves:
	// - Hook up to the proper wire of INST.bus
	// - Wire up the logical circuit and attach it to proper step wires
	// - Use the "elastic" OR gates (xxx.eor) to enable and set
}
