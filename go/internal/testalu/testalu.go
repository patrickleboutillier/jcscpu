// Some functions to facilitate ALU testing
package testalu

import (
	"fmt"
	"math/rand"
	"testing"

	tm "github.com/patrickleboutillier/jcscpu/go/internal/testmore"
	"github.com/patrickleboutillier/jcscpu/go/pkg/arch"
	a "github.com/patrickleboutillier/jcscpu/go/pkg/arch"
)

type ALUTest func(ALUTestCase) ALUTestCase

type ALUTestCase struct {
	A, B, C, OP      int
	CI, CO, ALO, EQO bool
}

func NewALUTestCase(a int, b int, ci bool) ALUTestCase {
	return ALUTestCase{A: a, B: b, CI: ci}
}

func NewRandomALUTestCase() ALUTestCase {
	max := a.GetMaxByteValue()
	rb := false
	if rand.Intn(2) == 1 {
		rb = true
	}
	return ALUTestCase{A: rand.Intn(max), B: rand.Intn(max), CI: rb}
}

func bool2int(b bool) int {
	if b {
		return 1
	} else {
		return 0
	}
}

func int2bool(i int) bool {
	if i == 0 {
		return false
	} else {
		return true
	}
}

// Add simulates an ADDer
func Add(tc ALUTestCase) ALUTestCase {
	tc.C = tc.A + tc.B + bool2int(tc.CI)
	tc.CO = false
	if tc.C > a.GetMaxByteValue() {
		tc.C -= (a.GetMaxByteValue() + 1)
		tc.CO = true
	}
	return tc
}

func ShiftRight(tc ALUTestCase) ALUTestCase {
	tc.C = (tc.A >> 1) + (bool2int(tc.CI) * ((arch.GetMaxByteValue() + 1) / 2))
	tc.CO = int2bool(tc.A % 2)
	return tc
}

// ShiftLeft simulates a ShiftLeftter
func ShiftLeft(tc ALUTestCase) ALUTestCase {
	tc.C = (tc.A << 1) + bool2int(tc.CI)
	tc.CO = false
	if tc.C > a.GetMaxByteValue() {
		tc.C -= (a.GetMaxByteValue() + 1)
		tc.CO = true
	}
	return tc
}

// Not simulates a NOTter
func Not(tc ALUTestCase) ALUTestCase {
	tc.C = ^tc.A + a.GetMaxByteValue() + 1
	return tc
}

// And simulates an ANDder
func And(tc ALUTestCase) ALUTestCase {
	tc.C = tc.A & tc.B
	return tc
}

// Or simulates an ORrer
func Or(tc ALUTestCase) ALUTestCase {
	tc.C = tc.A | tc.B
	return tc
}

func RunRandomALUTest(t *testing.T, op int, result ALUTest, expected ALUTest) {
	if op < 0 {
		op = rand.Intn(8)
	}

	tc := NewRandomALUTestCase()
	tc.OP = op
	testname := fmt.Sprintf("ALU(op:%d,a:%d,b:%d,ci:%d)", tc.OP, tc.A, tc.B, bool2int(tc.CI))
	t.Run(testname, func(t *testing.T) {
		tm.Is(t, result(tc), expected(tc), testname)
	})
}

func RunRandomALUTests(t *testing.T, n int, op int, result ALUTest, expected ALUTest) {
	for j := 0; j < n; j++ {
		RunRandomALUTest(t, op, result, expected)
	}
}

/*
# Some functions to facilitate ALU testing.


sub gen_test_case {
    my $ret = {
        a => int rand(256),
        b => int rand(256),
        ci => int rand(2),
    } ;
    $ret->{bina} = sprintf("%08b", $ret->{a}) ;
    $ret->{binb} = sprintf("%08b", $ret->{b}) ;

    return $ret ;
}


sub valu {
    my $tc = shift ;
    my $no_flags = shift ;

    my %res = %{$tc} ;

    if ($no_flags){
        delete $res{ci} ;
    }

    # ADD
    if (($res{op}) == 0){
        my $out = $res{a} + $res{b} + $res{ci} ;
        my $co = 0 ;
        if ($out >= 256){
            $co = 1 ;
            $out -= 256 ;
        }
        $res{out} = $out ;
        $res{co} = $co ;
    }
    # SHR
    elsif (($res{op}) == 1){
        $res{out} = ($res{a} >> 1) + ($res{ci} * 128) ;
        $res{co} = $res{a} % 2 ;
    }
    # SHL
    elsif (($res{op}) == 2){
        my $out = ($res{a} << 1) + $res{ci} ;
        my $co = 0 ;
        if ($out >= 256){
            $out -= 256 ;
            $co = 1 ;
        }
        $res{out} = $out ;
        $res{co} = $co ;
    }
    # NOT
    elsif (($res{op}) == 3){
        my @bina = split(//, sprintf("%08b", $res{a})) ;
        my @res = map { ($_ ? 0 : 1) } @bina ;
        $res{out} = oct("0b" . join('', map { ($_ ? 1 : 0) } @res)) ;
    }
    # AND
    elsif (($res{op}) == 4){
        my @bina = split(//, sprintf("%08b", $res{a})) ;
        my @binb = split(//, sprintf("%08b", $res{b})) ;
        my @res = () ;
        for (my $j = 0 ; $j < 8 ; $j++){
            push @res, ($bina[$j] && $binb[$j]) ;
        }
        $res{out} = oct("0b" . join('', map { ($_ ? 1 : 0) } @res)) ;
    }
    # OR
    elsif (($res{op}) == 5){
        my @bina = split(//, sprintf("%08b", $res{a})) ;
        my @binb = split(//, sprintf("%08b", $res{b})) ;
        my @res = () ;
        for (my $j = 0 ; $j < 8 ; $j++){
            push @res, ($bina[$j] || $binb[$j]) ;
        }
        $res{out} = oct("0b" . join('', map { ($_ ? 1 : 0) } @res)) ;
    }
    # XOR
    elsif (($res{op}) == 6){
        my @bina = split(//, sprintf("%08b", $res{a})) ;
        my @binb = split(//, sprintf("%08b", $res{b})) ;
        my @res = () ;
        for (my $j = 0 ; $j < 8 ; $j++){
            push @res, ($bina[$j] xor $binb[$j]) ;
        }
        $res{out} = oct("0b" . join('', map { ($_ ? 1 : 0) } @res)) ;
    }
    #CMP
    elsif (($res{op}) == 7){
        # Nothing...
    }

    if (defined($res{out})){
        $res{binout} = sprintf("%08b", $res{out}) ;
        $res{z} = ($res{out} == 0 ? 1 : 0) ;
        $res{eqo} = ($res{a} == $res{b}) || 0 ;
        $res{alo} = ($res{a} > $res{b}) || 0;
    }

    if ($no_flags){
        delete $res{co} ;
        delete $res{z} ;
        delete $res{eqo} ;
        delete $res{alo} ;
    }

    return \%res ;
}

*/
