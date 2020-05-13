package gate

type wire struct {
	power, soft bool
	gates       []*nand
}

func NewWire() *wire {
	return &wire{false, false, make([]*nand, 0, 1024)}
}

func GetPower(this *wire) bool {
	return this.power
}

func SetPowerSoft(this *wire, v bool) {
	this.power = v
	this.soft = true
}

func SetPower(this *wire, v bool) {
	this.power = v
	this.soft = false

	for _, g := range this.gates {
		if this != GetC(g) {
			Signal(g)
		}
	}

	/*
	   # Do prehooks
	   foreach my $hook (@{$this->{prehooks}}){
	       $hook->($v)  ;
	   }
	*/
}

func GetSoft(this *wire) bool {
	return this.soft
}

// Connect the gates to the current wire.
func Connect(this *wire, n *nand) {
	this.gates = append(this.gates, n)
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


sub terminal {
    my $this = shift ;

    $this->{terminal} = 1 ;
    return 1 ;
}


sub prehook {
    my $this = shift ;
    my $sub = shift ;

    if (defined($sub)){
        # Set prehook
        push @{$this->{prehooks}}, $sub ;
    }
}


# Get or set power on a wire.
sub power {
    my $this = $_[0] ;
    my $v = $_[1] ;
    my $soft = $_[2] ; # Soft signal only changes the power value, no signals and no hooks.

    return $this->{power} unless defined($v) ;
    return $this->{power} if $this->{terminal} ;

    # $v = ($v ? 1 : 0) ;
    $this->{power} = $v ;
    $this->{soft} = $soft ;

    if (! $soft){
        # Do prehooks
        foreach my $hook (@{$this->{prehooks}}){
            $hook->($v)  ;
        }

        foreach my $gate (@{$this->{gates}}){
            # Don't send signals to output pin.
            $gate->signal() if ($this ne $gate->{c}) ;
        }
    }

    return $v ;
}


# Connect the gates to the current wire.
sub connect {
    my $this = shift ;
    my @gates = @_ ;

    foreach my $gate (@gates){
        push @{$this->{gates}}, $gate ;
    }

    return $this ;
}


sub show {
    my $this = shift ;

    return $this->power() ;
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
