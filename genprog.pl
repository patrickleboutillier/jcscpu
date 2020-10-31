#!/usr/bin/perl


use strict ;
use lib "/home/patrickl/GIT/jcscpu/perl/lib" ;
use jcsasm ;


my @rmap = (R0, R1, R2, R3) ;

my @RAM = () ;
gen_test_prog(\@RAM) ;


# We assume RAM has been cleared just before calling this function
sub gen_test_prog {
	my $RAM = shift ;

	install_bootloader($RAM) ;

	# Generate random values between 64 and 224 to testing purposes
	# Above 64 to ensure we don't write over our program
	# Below 225 to leave place at the end to store our state
	my $minval = 128 ;
	my $maxval = 248 ;
	my $r0 = $minval + int(rand($maxval - $minval)) ;
	my $r1 = $minval + int(rand($maxval - $minval)) ;
	my $r2 = $minval + int(rand($maxval - $minval)) ;
	my $r3 = $minval + int(rand($maxval - $minval)) ;
	my $data = $minval + int(rand($maxval - $minval)) ;
	my @r = ($r0, $r1, $r2, $r3) ;
	warn "$r0, $r1, $r2, $r3" ;

	# Store these values in RAM in the proper reserved slots, and generate the equivalent 
	# instructions
	$RAM->[248] = $r0 ;
	$RAM->[249] = $r1 ;
	$RAM->[250] = $r2 ;
 	$RAM->[251] = $r3 ;
	for (my $i = 0 ; $i < 4 ; $i++){
	    DATA(R1, 248+$i) ;
    	DATA(R0, $r[$i]) ;
	    ST(R1, R0) ;
	}

	# Generate random flag values (C, A, E, Z)
	my $c = int(rand(2)) ;
	my $a = int(rand(2)) ;
	my $e = int(rand(2)) ;
	$e = 0 if ($a && $e) ;
	my $z = int(rand(2)) ;
	my @flags = ($c, $a, $e, $z) ;
	warn join(", ", @flags) ;

	# Store them in the proper reserved slots and generate the equivalent instructions.
	$RAM->[252] = $c ;
	$RAM->[253] = $a ;
	$RAM->[254] = $e ;
	$RAM->[255] = $z ;
	for (my $i = 0 ; $i < 4 ; $i++){
	    DATA(R1, 252+$i) ;
    	DATA(R0, $flags[$i]) ;
	    ST(R1, R0) ;
	}

	# Run the instructions to set the FLAGS properly
	set_flags(join('', @flags)) ;


	# Load the registers just before running the instruction
	for (my $i = 0 ; $i < 4 ; $i++){
	    DATA($rmap[$i], $r[$i]) ;
	}
	$RAM->[$r0] = $r0 ;
	$RAM->[$r1] = $r1 ;
	$RAM->[$r2] = $r2 ;
	$RAM->[$r3] = $r3 ;
	# Generate the equivalent instructions
	for (my $i = 0 ; $i < 4 ; $i++){
		ST($rmap[$i], $rmap[$i]) ;
	}


	# So now the initial state is set. The next step is to generate a random test instruction
	# Pick 2 registers at random to use in the instruction. Also choose an unused register.
	my $ra = int(rand(3)) ;
	my $rb = int(rand(3)) ;
	my $rx = undef ;
	for (my $i = 0 ; $i < 4 ; $i++){
		if (($i != $ra)&&($i != $rb)){
			$rx = $i ;
			last ;
		}
	}
	warn "ra is $ra, rb = $rb, rx is $rx, c is $c\n" ;

	
	# simulate instruction and update RAM
	my @alu = (1000, 1001, 1010, 1011, 1100, 1101, 1110, 1111, 110) ;
	my @bus = (0, 1, 10) ;
	my @jmp = (11, 100) ;
	my @insts = (@bus, @jmp, @alu) ;
	my $inst = $insts[int(rand(scalar(@insts)))] ;
	my $jinst = int(rand(16)) ;
	warn "inst is $inst\n" ;
	simulate_instruction($RAM, $inst, $jinst, join('', @flags), $ra, $rb, $rx, $data, $c) ;
	do_instruction($inst, $jinst, join('', @flags), $ra, $rb, $rx, $data) ;


	# Now that the instruction is done, we need to save the register and flags state to RAM.
   	DATA($rmap[$rx], 248+$ra) ;
   	ST($rmap[$rx], $rmap[$ra]) ;
   	DATA($rmap[$rx], 248+$rb) ;
   	ST($rmap[$rx], $rmap[$rb]) ;

	# Now we need to store the resulting flags to RAM.
	# Start by setting all the flags locations
    DATA(R0, 1) ;
	for (my $i = 0 ; $i < 4 ; $i++){
	    DATA(R1, 252+$i) ;
	    ST(R1, R0) ;
	}
	store_flags() ;
	DUMP() ;
	HALT() ;

	my @insts = grep { /^[01]/} @{jcsasm::done()} ;
	my $i = 0 ;
	for ( ; $i < scalar(@insts) ; $i++){
		my $bin_inst = $insts[$i] ;
		$bin_inst =~ s/\s+.*$// ;
		$RAM[$i] = oct("0b" . $bin_inst) ;
		print "$bin_inst\n" ;
	}
	# Add a last HALT added by jcscpu
	$RAM->[$i] = 97 ;
	dump_RAM(\@RAM) ;	
} ;


sub set_flags {
	my $flags = shift ;

	if ($flags eq '0000'){
		CLF() ;
	}
	elsif ($flags eq '1000'){
		DATA(R0, 100) ;
		DATA(R1, 200) ;
		ADD(R0, R1) ;
	}
	elsif ($flags eq '0100'){
		DATA(R0, 6) ;
		DATA(R1, 2) ;
		AND(R0, R1) ;
	}
	elsif ($flags eq '0010'){
		DATA(R0, 1) ;
		DATA(R1, 1) ;
		AND(R0, R1) ;
	}
	elsif ($flags eq '0001'){
		DATA(R0, 1) ;
		DATA(R1, 2) ;
		AND(R0, R1) ;
	}
	elsif ($flags eq '1100'){
		DATA(R0, 200) ;
		DATA(R1, 100) ;
		ADD(R0, R1) ;
	}
	elsif ($flags eq '1010'){
		DATA(R0, 200) ;
		DATA(R1, 200) ;
		ADD(R0, R1) ;
	}
	elsif ($flags eq '1001'){
		DATA(R0, 127) ;
		DATA(R1, 129) ;
		ADD(R0, R1) ;
	}
	elsif ($flags eq '0101'){
		DATA(R0, 2) ;
		DATA(R1, 1) ;
		AND(R0, R1) ;
	}
	elsif ($flags eq '0011'){
		DATA(R0, 1) ;
		DATA(R1, 1) ;
		XOR(R0, R1) ;
	}
	elsif ($flags eq '1101'){
		DATA(R0, 129) ;
		DATA(R1, 127) ;
		ADD(R0, R1) ;
	}
	elsif ($flags eq '1011'){
		DATA(R0, 128) ;
		DATA(R1, 128) ;
		ADD(R0, R1) ;
	}
	else {
		die("Invalid flag combination $flags!\n") ;
	}
}


sub store_flags {
	# Insert a series of jump instructions that will set the flags on the correct location.
    DATA(R0, 0) ;
    JC(jcsasm::nb_lines() + 5) ;
    DATA(R1, 252) ;
    ST(R1, R0) ;
    JA(jcsasm::nb_lines() + 5) ;
    DATA(R1, 253) ;
    ST(R1, R0) ;
    JE(jcsasm::nb_lines() + 5) ;
    DATA(R1, 254) ;
    ST(R1, R0) ;
    JZ(jcsasm::nb_lines() + 5) ;
    DATA(R1, 255) ;
    ST(R1, R0) ;
}


sub simulate_instruction {
	my $RAM = shift ;
	my $inst = shift ;
	my $jinst = shift ;
	my $flags = shift ;
	my $ra = shift ;
	my $rb = shift ;
	my $rx = shift ;
	my $data = shift ;
	my $ci = shift ;

	my $flags = 0 ;
	my $c = 0 ;
	my $a = $RAM->[248+$ra] > $RAM->[248+$rb] ;
	my $e = $RAM->[248+$ra] == $RAM->[248+$rb] ;
	my $z = -1 ;

	if ($inst == 0){ 		 	# LD
		$RAM->[248+$rb] = $RAM->[$RAM->[248+$ra]] ;
	}
	elsif ($inst == 1){ 		# ST
		$RAM->[$RAM->[248+$ra]] = $RAM->[248+$rb] ;
	}
	elsif ($inst == 10){ 		# DATA
		$RAM->[248+$rb] = $data ;
	}
	elsif ($inst == 11){ 		# JMPR
		# No nothing, as the JUMP has no effect if performed.
	}
	elsif ($inst == 100){ 		# JMP
		# No nothing, as the JUMP has no effect if performed.
	}
	elsif ($inst == 101){ 		# JXXX
		# We need to figure out if we will jump or not, base in $jinst and $flags
		# In NOT, we must produce the proper side-effect.
	}
	elsif ($inst == 110){ 		# CLF
		$c = 0 ;
		$a = 0 ;
		$e = 0 ;
		$z = 0 ;
		$flags = 1 ;
	}
	elsif ($inst == 1000){ 	# ADD
		my $sum = $RAM->[248+$ra] + $RAM->[248+$rb] + $ci ;
		$c = $sum > 255 ;
		$RAM->[248+$rb] = $sum % 256 ;
		$flags = 1 ;
	}
	elsif ($inst == 1001){ 	# SHR
		$c = $RAM->[248+$ra] % 2 ;
		$RAM->[248+$rb] = ($RAM->[248+$ra] + 256*$ci) >> 1 ;
		$flags = 1 ;
	}
	elsif ($inst == 1010){ 	# SHL
		$c = $RAM->[248+$ra] >= 128 ;
		$RAM->[248+$rb] = (($RAM->[248+$ra] << 1) % 256) + $ci ;
		$flags = 1 ;
	}
	elsif ($inst == 1011){ 	# NOT
		$RAM->[248+$rb] = (~ $RAM->[248+$ra]) % 256 ;
		$flags = 1 ;
	}
	elsif ($inst == 1100){ 	# AND
		$RAM->[248+$rb] = $RAM->[248+$ra] & $RAM->[248+$rb] ;
		$flags = 1 ;
	}
	elsif ($inst == 1101){	# OR
		$RAM->[248+$rb] = $RAM->[248+$ra] | $RAM->[248+$rb] ;
		$flags = 1 ;
	}
	elsif ($inst == 1110){	# XOR
		$RAM->[248+$rb] = $RAM->[248+$ra] ^ $RAM->[248+$rb] ;
		$flags = 1 ;
	}
	elsif ($inst == 1111){	# CMP
		$flags = -1 ;
	}

	if ($flags){
		$RAM->[252] = $c ;
		$RAM->[253] = $a ;
		$RAM->[254] = $e ;
		$RAM->[255] = (($z != -1) ? $z : ! $RAM->[248+$rb]) ;
		if ($flags == -1){
			$RAM->[255] = 1 ;
		}
	}
}


sub do_instruction {
	my $inst = shift ;
	my $jinst = shift ;
	my $flags = shift ;
	my $ra = shift ;
	my $rb = shift ;
	my $rx = shift ;
	my $data = shift ;

	if ($inst == 0){ 		# LD
		LD($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 1){ 	# ST
		ST($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 10){ 	# DATA
		DATA($rmap[$rb], $data) ;
	}
	elsif ($inst == 11){ 	# JMPR
		my $addr = jcsasm::nb_lines() + 4 ;
		DATA($rmap[$rx], $addr) ;
		JMPR($rmap[$rx]) ;
		# Create a side-effect if the jump is not performed
		ST($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 100){ 	# JMP
		JMP(jcsasm::nb_lines() + 3) ;
		# Create a side-effect if the jump is not performed
		ST($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 101){ 	# JXXX
		my $addr = jcsasm::nb_lines() + 3 ;
		jcsasm::add_inst("0101$flags") ;
		jcsasm::add_inst(sprintf("%08b", $addr)) ;
		# Create a side-effect if the jump is not performed
		ST($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 110){ 	# CLF
		CLF() ;
	}
	elsif ($inst == 1000){ 	# ADD
		ADD($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 1001){ 	# SHR
		SHR($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 1010){ 	# SHL
		SHL($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 1011){ 	# NOT
		NOT($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 1100){ 	# AND
		AND($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 1101){	# OR
		OR($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 1110){	# XOR
		XOR($rmap[$ra], $rmap[$rb]) ;
	}
	elsif ($inst == 1111){	# CMP
		CMP($rmap[$ra], $rmap[$rb]) ;
	}
}


sub dump_RAM {
	my $RAM = shift ;

	open(RAM, ">RAM_SIM.txt") ;
	foreach my $i (0..255){
		my $addr_bin = sprintf("%08b", $i) ;
		my $data = $RAM->[$i] || 0 ;
		my $data_bin = sprintf("%08b", $data) ;
		print RAM "DEBUG: RAM[$i/$addr_bin] = $data/$data_bin\n" ;
	}
}


sub install_bootloader {
	my $RAM = shift ;

	$RAM->[225] = oct("0b00100000") ;
    $RAM->[226] = oct("0b00000000") ;
    $RAM->[227] = oct("0b00100001") ;
    $RAM->[228] = oct("0b00000011") ;
    $RAM->[229] = oct("0b01111101") ;
    $RAM->[230] = oct("0b01110001") ;
    $RAM->[231] = oct("0b00100010") ;
    $RAM->[232] = oct("0b00000001") ;
    $RAM->[233] = oct("0b00100011") ;
    $RAM->[234] = oct("0b00000010") ;
    $RAM->[235] = oct("0b01111111") ;
    $RAM->[236] = oct("0b01111000") ;
    $RAM->[237] = oct("0b01110011") ;
    $RAM->[238] = oct("0b00010011") ;
    $RAM->[239] = oct("0b10001000") ;
    $RAM->[240] = oct("0b11110001") ;
    $RAM->[241] = oct("0b01010010") ;
    $RAM->[242] = 245 ;
    $RAM->[243] = oct("0b01000000") ;
    $RAM->[244] = 236 ;
    $RAM->[245] = oct("0b01100001") ;
    $RAM->[246] = oct("0b01000000") ;
    $RAM->[247] = oct("0b00000000") ;
}


