package gate

/*
NAND
*/
type nand struct {
	a, b, c *wire
}

func NewNAND(a *wire, b *wire, c *wire) *nand {
	this := &nand{a, b, c}
	Connect(a, this)
	Connect(b, this)
	Connect(c, this)
	Signal(this)
	return this
}

func Signal(this *nand) {
	c := (!(GetPower(this.a) && GetPower(this.b)))

	if (GetPower(this.c) != c) || (GetSoft(this.c)) {
		SetPower(this.c, c)
	}
}

func GetC(this *nand) *wire {
	return this.c
}

/*
NOT
*/
type not struct {
}

func NewNOT(a *wire, b *wire) *not {
	this := &not{}
	NewNAND(a, a, b)
	return this
}
