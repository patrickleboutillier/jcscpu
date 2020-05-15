package parts

/*
use strict
use Test::More
use Byte

plan(tests => 9)

# BYTE
bis = NewBUS()
ws = NewWIRE()
bos = NewBUS()
B = NewBYTE(bis, ws, bos)

ws.GetPower(1)
if bos.GetPower() != "00000000" {
	t.Errorf("B(i:00000000,s:1)=o:00000000, s=on, i should equal o")
}
bis.GetWire(0).GetPower(1)
if bos.GetPower() != "10000000" {
	t.Errorf("B(i:10001000,s:1)=o:10001000, s=on, i should equal o")
}
bis.GetWire(4).GetPower(1)
if bos.GetPower() != "10001000" {
	t.Errorf("B(i:10001000,s:1)=o:10001000, s=on, i should equal o")
}
ws.GetPower(0)
if bos.GetPower() != "10001000" {
	t.Errorf("B(i:10001000,s:0)=o:10001000, s=off, i still equal o")
}
bis.GetWire(0).GetPower(0)
if bos.GetPower() != "10001000" {
	t.Errorf("B(i:00001000,s:0)=o:10001000, s=off, o stays at 10001000")
}
ws.GetPower(1)
if bos.GetPower() != "00001000" {
	t.Errorf("B(i:00001000,s:1)=o:00001000, s=on, o goes to 00001000 since i is 00001000")
}
ws.GetPower(0)
if bos.GetPower() != "00001000" {
	t.Errorf("B(i:00001000,s:0)=o:00001000, s=on, i and o stay at 00001000")
}
bis.GetWire(5).GetPower(1)
bis.GetWire(6).GetPower(1)
bis.GetWire(7).GetPower(1)
if bos.GetPower() != "00001000" {
	t.Errorf("B(i:00001111,s:0)=o:00001000, s=off, o stays at 00001000")
}
ws.GetPower(1)
if bos.GetPower() != "00001111" {
	t.Errorf("B(i:00001111,s:1)=o:00001111, s=on, o goes to i (00001111)")
}


*/
