package board

import (
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/go/internal/testmore"
)

func TestInstProc(t *testing.T) {
	BB := NewInstProcBreadboard()

	// Place some fake instructions in RAM
	BB.GetBus("DATA.bus").SetPower(0b00000100)
	BB.GetWire("RAM.MAR.s").SetPower(true)
	BB.GetWire("RAM.MAR.s").SetPower(false)
	BB.GetBus("DATA.bus").SetPower(0b10101010)
	BB.GetWire("RAM.s").SetPower(true)
	BB.GetWire("RAM.s").SetPower(false)
	tm.Is(t, BB.RAM.GetCell(0b00000100).GetPower(), 0b10101010, "RAM set correctly at 00000100")
	BB.GetBus("DATA.bus").SetPower(0b00000101)
	BB.GetWire("RAM.MAR.s").SetPower(true)
	BB.GetWire("RAM.MAR.s").SetPower(false)
	BB.GetBus("DATA.bus").SetPower(0b01010101)
	BB.GetWire("RAM.s").SetPower(true)
	BB.GetWire("RAM.s").SetPower(false)
	tm.Is(t, BB.RAM.GetCell(0b00000101).GetPower(), 0b01010101, "RAM set correctly at 00000101")
	BB.GetBus("DATA.bus").SetPower(0b00000110)
	BB.GetWire("RAM.MAR.s").SetPower(true)
	BB.GetWire("RAM.MAR.s").SetPower(false)
	BB.GetBus("DATA.bus").SetPower(0b11110000)
	BB.GetWire("RAM.s").SetPower(true)
	BB.GetWire("RAM.s").SetPower(false)
	tm.Is(t, BB.RAM.GetCell(0b00000110).GetPower(), 0b11110000, "RAM set correctly at 00000110")

	// Set the IAR to our start address
	BB.GetBus("DATA.bus").SetPower(0b00000100)
	BB.GetWire("IAR.s").SetPower(true)
	BB.GetWire("IAR.s").SetPower(false)
	tm.Is(t, BB.GetReg("IAR").GetPower(), 0b00000100, "IAR set correctly")

	BB.Tick()
	tm.Is(t, BB.GetReg("RAM.MAR").GetPower(), 0b00000100, "RAM.MAR contains previous contents of IAR")
	tm.Is(t, BB.GetReg("ACC").GetPower(), 0b00000101, "ACC contains previous contents of IAR + 1")
	BB.Tick()
	tm.Is(t, BB.GetReg("IR").GetPower(), 0b10101010, "IR contains our first fake instruction")
	BB.Tick()
	tm.Is(t, BB.GetReg("IAR").GetPower(), 0b00000101, "IR contains the address our our next instruction")
}

func TestInstImpl(t *testing.T) {
	/*
	   use strict ;
	   use Test::More ;
	   use Breadboard ;

	   plan(tests => 64 + 288) ;

	   my BB = new BREADBOARD(
	       'instproc' => 1,
	       'instimpl' => 1,
	   ) ;
	   BB.show() ;

	   # What we need to test here is that:
	   # 1- Bits 0-3 of the IR setup the proper instruction in the instruction decoder.
	   # 2- Bits 4-7 of the IR setup the propoer register (s) to be enabled or set

	   my @ts = ((0..15), (map { int rand(2) } (0..15))) ;
	   foreach my t (@ts){
	       my inst = sprintf("%04b", t) ;
	       my bin = "{inst}0000" ;
	       BB.get("DATA.bus").power(bin) ;
	       BB.get("IR.s").power(1) ;
	       BB.get("IR.s").power(0) ;
	       is(BB.get("IR").power(), bin, "IR properly set to bin") ;
	       my @res = split(//, "00000000") ;
	       res[t] = '1' if t < 8 ; # t >= 8 is an ALU instruction and does not use INST.bus
	       my res = join('', @res) ;
	       is(BB.get("INST.bus").power(), res, "IR:{inst}XXXX . INST.bus:res") ;
	   }


	   @ts = ((0..15), (map { int rand(2) } (0..15))) ;
	   my %map = ("00" => "R0",  "01" => "R1", "10" => "R2", "11" => "R3") ;
	   foreach my t (@ts){
	       my rspec = sprintf("%04b", t) ;
	       my bin = "0000{rspec}" ;
	       BB.get("DATA.bus").power(bin) ;
	       BB.get("IR.s").power(1) ;
	       BB.get("IR.s").power(0) ;
	       is(BB.get("IR").power(), bin, "IR properly set to bin") ;
	       my b45 = substr(rspec, 0, 2) ;
	       my b67 = substr(rspec, 2, 2) ;
	       # REGA.e, REGB.e, REGB.s should already all be turned on since they are connected to an ORe that has no inputs yet.
	       my ra = map{b45} ;
	       my rb = map{b67} ;

	       BB.get("CLK.clke").power(1) ;
	       BB.get("REGA.e").power(1) ;
	       BB.get("REGB.e").power(1) ;
	       # warn BB.show() ;
	       map { my res = (((_ eq ra)||(_ eq rb)) ? 1 : 0) ; is(BB.get(_ . '.e').power(), res, "_.e is res")} sort values %map ;

	       BB.get("CLK.clke").power(0) ;
	       BB.get("REGA.e").power(0) ;
	       BB.get("REGB.e").power(0) ;
	       BB.get("CLK.clks").power(1) ;
	       BB.get("REGB.s").power(1) ;
	       map { my res = (_ eq rb ? 1 : 0) ; is(BB.get(_ . '.s').power(), res, "_.s is res")} sort values %map ;
	       BB.get("CLK.clks").power(0) ;
	       BB.get("REGB.s").power(0) ;
	*/
}
