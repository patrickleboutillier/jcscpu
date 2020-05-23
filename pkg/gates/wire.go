package gates

type prehook func(bool)

var on *Wire = nil
var off *Wire = nil

var NbWires int

type Wire struct {
	power, soft, terminal bool
	gates                 []*NAND
	prehooks              []prehook
	earlyhooks            []prehook
}

func NewWire() *Wire {
	this := &Wire{gates: make([]*NAND, 0, 2)}
	NbWires++
	return this ;
}

func WireOn() *Wire {
	if on == nil {
		on = NewWire()
		on.SetPower(true)
		on.SetTerminal()
	}
	return on
}

func WireOff() *Wire {
	if off == nil {
		off = NewWire()
		off.SetTerminal()
	}
	return off
}

func (this *Wire) GetPower() bool {
	return this.power
}

func (this *Wire) String() string {
	if this.power {
		return "1"
	} else {
		return "0"
	}
}

func (this *Wire) SetPowerSoft(v bool) {
	if !this.terminal {
		this.power = v
		this.soft = true
	}
}

func (this *Wire) SetPower(v bool) {
	if !this.terminal {
		for _, f := range this.earlyhooks {
			f(v)
		}

		this.power = v
		this.soft = false

		for _, f := range this.prehooks {
			f(v)
		}

		for _, g := range this.gates {
			if this != g.c {
				g.Signal()
			}
		}
	}
}

func (this *Wire) SetTerminal() {
	this.terminal = true
}

func (this *Wire) AddPrehook(f prehook) {
	if this.prehooks == nil {
		this.prehooks = make([]prehook, 0, 0)
	}
	this.prehooks = append(this.prehooks, f)
}

func (this *Wire) AddEarlyhook(f prehook) {
	if this.earlyhooks == nil {
		this.earlyhooks = make([]prehook, 0, 0)
	}
	this.earlyhooks = append(this.earlyhooks, f)
}

// Connect the gates to the current Wire.
func (this *Wire) Connect(g *NAND) {
	this.gates = append(this.gates, g)
}
