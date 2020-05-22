package board

import (
	"fmt"
	"testing"

	ti "github.com/patrickleboutillier/jcscpu/internal/testinst"
	tm "github.com/patrickleboutillier/jcscpu/internal/testmore"
	a "github.com/patrickleboutillier/jcscpu/pkg/arch"
)

var nb_tests_per_inst = 256

func TestALUInstuctionsBasic(t *testing.T) {
	BB := NewInstBreadboard("ALU")

	// Testing of ALU instructions.
	// Add contents of R1 and R2, result in R2
	BB.SetReg("R1", 0b01100100) // 100
	BB.SetReg("R2", 0b00110010) // 50
	BB.SetRAM(0b00001000, 0b10000110)
	BB.SetReg("IAR", 0b00001000)
	BB.Inst()
	tm.Is(t, BB.GetReg("R2").GetPower(), 0b10010110, "100 + 50 = 150") // 150

	// Add contents of R1 and R1, result in R1
	BB.SetReg("R1", 0b01100100) // 100
	BB.SetRAM(0b00001000, 0b10000101)
	BB.SetReg("IAR", 0b00001000)
	BB.Inst()
	tm.Is(t, BB.GetReg("R1").GetPower(), 0b11001000, "100 + 100 = 200") // 200

	// Not contents of R0 back in R0
	BB.SetReg("R0", 0b10101010)
	BB.SetRAM(0b00001001, 0b10110000)
	BB.SetReg("IAR", 0b00001001)
	BB.Inst()
	xtra := a.GetMaxByteValue() - 255
	tm.Is(t, BB.GetReg("R0").GetPower(), xtra+0b01010101, "NOT of 10101010 = 01010101")

	// Bug with TMP.e
	BB.SetReg("R3", 0b00111101)
	BB.SetRAM(0b00001010, 0b11001111)
	BB.SetReg("IAR", 0b00001010)
	BB.SetReg("TMP", 0b00010111)
	BB.GetWire("BUS1.bit1").SetPower(false) // Simulate a bit1 reset after inst1 of the stepper.
	BB.Inst()
	tm.Is(t, BB.GetReg("R3").GetPower(), 0b00111101, "AND of 00111101 with itself = 00111101")
}

func TestLDInstruction(t *testing.T) {
	BB := NewInstBreadboard("LDST")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0000,
		func(tc ti.INSTTestCase) {
			BB.SetRAM(tc.ADDR, tc.DATA)
			BB.SetReg(tc.RA, tc.ADDR)
		},
		doInst(BB, nil),
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg(tc.RB).GetPower(), tc.DATA, fmt.Sprintf("%d copied from RAM@%d (via %s) to %s", tc.DATA, tc.ADDR, tc.RA, tc.RB))
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+1, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+1"))
		},
	)
}

func TestSTInstruction(t *testing.T) {
	BB := NewInstBreadboard("LDST")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0001,
		func(tc ti.INSTTestCase) {
			BB.SetReg(tc.RB, tc.DATA)
			BB.SetReg(tc.RA, tc.ADDR)
		},
		doInst(BB, nil),
		func(tc ti.INSTTestCase) {
			data := tc.DATA
			if tc.RA == tc.RB {
				// In this case, RB gets overridden with the address, so the data becomes the address
				data = tc.ADDR
			}
			tm.Is(t, BB.RAM.GetCell(tc.ADDR).GetPower(), data, fmt.Sprintf("%d stored from %s to RAM@%d (via %s)", data, tc.RB, tc.ADDR, tc.RA))
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+1, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+1"))
		},
	)
}

func TestDATAInstruction(t *testing.T) {
	BB := NewInstBreadboard("DATA")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0010,
		func(tc ti.INSTTestCase) {
		},
		doInst(BB, nil),
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg(tc.RB).GetPower(), tc.IDATA, fmt.Sprintf("%d copied from program (RAM@%d) to %s", tc.IDATA, tc.IDADDR, tc.RB))
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+2, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+2"))
		},
	)
}

func TestJMPRInstruction(t *testing.T) {
	BB := NewInstBreadboard("JUMP")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0011,
		func(tc ti.INSTTestCase) {
			BB.SetReg(tc.RB, tc.ADDR)
		},
		doInst(BB, nil),
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.ADDR, fmt.Sprintf("IAR is now %d", tc.ADDR))
		},
	)
}

func TestJMPInstruction(t *testing.T) {
	BB := NewInstBreadboard("JUMP")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0100,
		func(tc ti.INSTTestCase) {
		},
		doInst(BB, nil),
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IDATA, fmt.Sprintf("IAR is now %d", tc.IDATA))
		},
	)
}

func TestJMPIFInstruction(t *testing.T) {
	BB := NewInstBreadboard("JUMP")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0101,
		func(tc ti.INSTTestCase) {
			BB.GetBus("FLAGS.in").SetPower(tc.FLAGS << 4)
			BB.GetWire("FLAGS.s").SetPower(true)
			BB.GetWire("FLAGS.s").SetPower(false)
			// Reset bus once flags are set in the reg
			BB.GetBus("FLAGS.in").SetPower(0)
		},
		doInst(BB, nil),
		func(tc ti.INSTTestCase) {
			// Decide if we should have jumped or not. If any of the bits of FLAGS and IFLAGS are both on, we jump
			jump := (tc.FLAGS & tc.IFLAGS) > 0
			if jump {
				tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IDATA, fmt.Sprintf("IAR is now %d", tc.IDATA))
			} else {
				tm.Is(t, BB.GetReg("IAR").GetPower(), tc.IADDR+2, fmt.Sprintf("IAR has advanced to the next instruction at tc.IADDR+2"))
			}
		},
	)
}

func TestCLFInstruction(t *testing.T) {
	BB := NewInstBreadboard("CLF")
	ti.RunRandomINSTTests(t, nb_tests_per_inst, 0b0110,
		func(tc ti.INSTTestCase) {
			// Inject the flags in the FLAG reg input
			BB.GetBus("FLAGS.in").SetPower(tc.FLAGS << 4)
			BB.GetWire("FLAGS.s").SetPower(true)
			BB.GetWire("FLAGS.s").SetPower(false)
			// Reset bus once flags are set in the reg
			BB.GetBus("FLAGS.in").SetPower(0)
		},
		func(tc ti.INSTTestCase) {
			// Make sure instruction is a CLF (01100000)
			tc.INST = 0b01100000
			doInst(BB, nil)(tc)
		},
		func(tc ti.INSTTestCase) {
			tm.Is(t, BB.GetReg("FLAGS").GetPower(), 0b00000000, "FLAGS reset")
		},
	)
}

func doInst(BB *Breadboard, hook func(tc ti.INSTTestCase)) ti.INSTDo {
	return func(tc ti.INSTTestCase) {
		BB.SetRAM(tc.IADDR, tc.INST)
		BB.SetRAM(tc.IDADDR, tc.IDATA)
		BB.SetReg("IAR", tc.IADDR)
		if hook != nil {
			hook(tc)
		}
		BB.Inst()
	}
}

/*
use strict
use Test::More
use Breadboard
use Data::Dumper

push @INC, './t'
require 'test_alu.pm'


my $nb_test_per_op = 8
my @ops = (0,1,2,3,4,5,6,7)
plan(tests => 4 + $nb_test_per_op*(scalar(@ops)))

my $BB = new BREADBOARD(
    'instproc' => 1,
    'instimpl' => 1,
    'insts' => ['ALU'],
)

// Testing of ALU instructions.
// Add contents of R1 and R2, result in R2
BB.setREG("R1", "01100100") // 100
BB.setREG("R2", "00110010") // 50
BB.setRAM("00001000", "10000110")
BB.setREG("IAR", "00001000")
BB.inst()
is(BB.get("R2").GetPower(), "10010110", "100 + 50 = 150") // 150

// Add contents of R1 and R1, result in R1
BB.setREG("R1", "01100100") // 100
BB.setRAM("00001000", "10000101")
BB.setREG("IAR", "00001000")
BB.inst()
is(BB.get("R1").GetPower(), "11001000", "100 + 100 = 200") // 200

// Not contents of R0 back in R0
BB.setREG("R0", "10101010")
BB.setRAM("00001001", "10110000")
BB.setREG("IAR", "00001001")
BB.inst()
is(BB.get("R0").GetPower(), "01010101", "NOT of 10101010 = 01010101")

// Bug with TMP.e
BB.setREG("R3", "00111101")
BB.setRAM("00001010", "11001111")
BB.setREG("IAR", "00001010")
BB.setREG("TMP", "00010111")
BB.get("BUS1.bit1").GetPower("0") // Simulate a bit1 reset after inst1 of the instper.
BB.inst()
is(BB.get("R3").GetPower(), "00111101", "AND of 00111101 with itself = 00111101")


foreach my $op (@ops){
    for (my $j = 0 $j < $nb_test_per_op $j++){
        do_test_case($op)
    }
}


sub do_test_case {
    my $op = shift

    my $tc = gen_test_case()
    $tc->{op} = $op

    $tc->{ra} = int rand(4)
    $tc->{rb} = int rand(4)
    if ($tc->{ra} == $tc->{rb}){
        $tc->{b} = $tc->{a}
        $tc->{binb} = sprintf("%08b", $tc->{b})
    }
    // Create our instruction
    $tc->{inst} = "1" . sprintf("%03b%02b%02b", $tc->{op}, $tc->{ra}, $tc->{rb})

    my $res = alu($tc)
    my $vres = valu($tc, 1)

    my $desc = Dumper($tc)
    $desc =~ s/\n\s+//gs
    is_deeply($res, $vres, "inst:$tc->{inst}, $desc")
}


sub alu {
    my $tc = shift

    my %res = %{$tc}

    delete $res{ci} // No flags

    // Generate a random RAM address
    my $addr = sprintf("%08b", int rand(255))

    // When this is implemented, there is no CLF instruction available yet.
    // We need to reset the FLAGS register because the presence of a trailing CI bit will give a bad answer.
    // We also bump s on TMP to let the value into the Ctmp M.
    BB.get("FLAGS")->is().GetPower("00000000")
    BB.get("FLAGS")->s().GetPower(1)
    BB.get("FLAGS")->s().GetPower(0)
    BB.get("TMP")->s().GetPower(1)
    BB.get("TMP")->s().GetPower(0)

    BB.setREG("R$res{ra}", $res{bina})
    BB.setREG("R$res{rb}", $res{binb})
    BB.setRAM($addr, $res{inst})
    BB.setREG("IAR", $addr)
    BB.inst()
    //warn Dumper($tc)
    //warn BB.show()
    //for (my $j = 0 $j < 12 $j++){
    //    BB.qtick()
    //    warn BB.show()
    //}

    $res{out} = oct(0b" . BB.get("R$res{rb}").GetPower()) if ($res{op} < 7)

    if (defined($res{out})){
        $res{binout} = sprintf("%08b", $res{out})
    }

    return \%res
}
*/
