package gates

type prehook func(bool)

var on *Wire = nil
var off *Wire = nil

type Wire struct {
	power, soft, terminal bool
	gates                 []*NAND
	prehooks              []prehook
}

func NewWire() *Wire {
	return &Wire{false, false, false, make([]*NAND, 0, 8), make([]prehook, 0, 2)}
}

func On() *Wire {
	if on == nil {
		on = NewWire()
		on.SetPower(true)
		on.SetTerminal()
	}
	return on
}

func Off() *Wire {
	if off == nil {
		off = NewWire()
		off.SetTerminal()
	}
	return off
}

func (this *Wire) GetPower() bool {
	return this.power
}

func (this *Wire) SetPowerSoft(v bool) {
	this.power = v
	this.soft = true
}

func (this *Wire) SetPower(v bool) {
	if !this.terminal {
		this.power = v
		this.soft = false

		for _, g := range this.gates {
			if this != g.c {
				g.Signal()
			}
		}

		for _, f := range this.prehooks {
			f(v)
		}
	}
}

func (this *Wire) SetTerminal() {
	this.terminal = true
}

func (this *Wire) AddPrehook(f prehook) {
	this.prehooks = append(this.prehooks, f)
}

// Connect the gates to the current Wire.
func (this *Wire) Connect(g *NAND) {
	this.gates = append(this.gates, g)
}

/*
package WIRE ;

use strict ;
use Carp ;


my $ON = new WIRE(1, 1) ;
my $OFF = new WIRE(0, 1) ;

sub new {
    my $class = shift ;
    my $v = shift ;
    my $terminal = shift ;

    my $this = {
        power => $v || 0,
        terminal => $terminal,  # Terminal wires cannot change power.
        gates => [],
        prehooks => [],
        soft => 0,
    } ;
    bless $this, $class ;

    return $this ;
}


sub on {
    return $ON ;
}


sub off {
    return $ON ;
}


sub name {
    my $this = shift ;
    my $name = shift ;

    if (defined($name)){
        $this->{name} = $name ;
        $this->prehook(sub {
            warn "Wire $this->{name}\@$this (smart:$this->{smart}) changing power to $_[0]\n" ;
        }) ;
    }

    return $this->{name} ;
}
*/
