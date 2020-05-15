package parts

/*
use strict
use Test::More
use Enabler

plan(tests => 7 + 512)

# ENABLER
bis = NewBUS()
we = NewWIRE()
bos = NewBUS()
E = NewENABLER(bis, we, bos)
E.show()

bis.GetWire(0).GetPower(1)
if bos.GetPower() != "00000000" {
	t.Errorf("B(i:10000000,e:0)=o:00000000, e=off, no output")
}
bis.GetWire(4).GetPower(1)
if bos.GetPower() != "00000000" {
	t.Errorf("B(i:10001000,e:0)=o:00000000, e=off, no output")
}
we.GetPower(1)
if bos.GetPower() != "10001000" {
	t.Errorf("B(i:10001000,e:1)=o:10001000, e=on, i goes through")
}
bis.GetWire(4).GetPower(0)
if bos.GetPower() != "10000000" {
	t.Errorf("B(i:10000000,e:1)=o:10000000, e=on, i goes through")
}
bis.GetWire(0).GetPower(0)
if bos.GetPower() != "00000000" {
	t.Errorf("B(i:00000000,e:1)=o:00000000, e=on, i goes through")
}
bis.GetWire(7).GetPower(1)
if bos.GetPower() != "00000001" {
	t.Errorf("B(i:00000001,e:1)=o:00000001, e=on, i goes through")
}
we.GetPower(0)
if bos.GetPower() != "00000000" {
	t.Errorf("B(i:00000001,e:0)=o:00000000, e=off, no output")
}

make_enabler_test(0)
make_enabler_test(1)

sub make_enabler_test {
    random = shift

    @ts = map { (random ? int rand(256) : _) } (0 .. 255)
    foreach t (@ts){
        bin = sprintf("%08b", t)
        we.GetPower(0) 
        bis.GetPower(bin)
        we.GetPower(1)
        is(bos.GetPower(), bin, "ENABLER(bin, 1)=bin")
    }
}
*/
