#!/usr/bin/perl

use strict ;
use lib "/home/patrickl/GIT/jcscpu/perl/lib" ;
use jcsasm ;


my %rmap = (0 => R0, 1 => R1, 2 => R2, 3 => R3) ;

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
	my $maxval = 225 ;
	my $r0 = $minval + int(rand($maxval - $minval)) ;
	my $r1 = $minval + int(rand($maxval - $minval)) ;
	my $r2 = $minval + int(rand($maxval - $minval)) ;
	my $r3 = $minval + int(rand($maxval - $minval)) ;
	my @r = ($r0, $r1, $r2, $r3) ;
	warn join(", ", @r) ;

	# Store these values in RAM in the proper reserved slots.
	$RAM->[248] = $r0 ;
	$RAM->[249] = $r1 ;
	$RAM->[250] = $r2 ;
 	$RAM->[251] = $r3 ;

	# Generate the equivalent instructions
	foreach my $i (0..3) {
	    DATA(R1, 248+$i) ;
    	DATA(R0, $r[$i]) ;
	    ST(R1, R0) ;
	}


	# Generate random flag values (C, A, E, Z)
	my $c = int(rand(2)) ;
	my $a = int(rand(2)) ;
	my $e = int(rand(2)) ;
	my $z = int(rand(2)) ;
	my @flags = ($c, $a, $e, $z) ;

	# Store them in the proper reserved slots.
	$RAM->[252] = $c ;
	$RAM->[253] = $a ;
	$RAM->[254] = $e ;
	$RAM->[255] = $z ;

	# Generate the equivalent instructions
	foreach my $i (0..3) {
	    DATA(R1, 252+$i) ;
    	DATA(R0, $flags[$i]) ;
	    ST(R1, R0) ;
	}

	# TODO: run the instructions to set the FLAGS properly

	# Load the registers just before running the instruction
	foreach my $i (0..3) {
	    DATA($rmap{$i}, $r[$i]) ;
	}
	

	# So now the initial state is set. The next step is to generate a random test instruction
	# Pick 2 registers at random to use in the instruction. Also choose an unused register.
	my $ra = int(rand(3)) ;
	my $rb = int(rand(3)) ;
	my $rx = undef ;
	foreach my $i (0..3) {
		if (($i != $ra)&&($i != $rb)){
			$rx = $i ;
			last ;
		}
	}
	warn "ra is $ra, rb = $rb, rx is $rx, c is $c\n" ;

	
	# simulate instruction and update RAM
	my @insts = (1010, 1011, 1100, 1101, 1110, 1111) ;
	my $inst = $insts[int(rand(scalar(@insts)))] ;
	warn "inst is $inst\n" ;
	simulate_instruction($RAM, $inst, $ra, $rb, 0) ;
	do_instruction($inst, $ra, $rb) ;
	# ...
	#

	# Now that the instruction is done, we need to save the register and flags state to RAM.
	foreach my $r ($ra, $rb) {
      	DATA($rmap{$rx}, 248+$r) ;
      	ST($rmap{$rx}, $rmap{$r}) ;
	}

	# Now we need to store the resulting flags to RAM.
	# Start by setting all the flags locations
    DATA(R0, 1) ;
	foreach my $i (0..3) {
	    DATA(R1, 252+$i) ;
	    ST(R1, R0) ;
	}
	# Insert a series of jump instructions that will set the flags on the correct location.
    DATA(R0, 0) ;
    JC('@JA') ;
    DATA(R1, 252) ;
    ST(R1, R0) ;
	LABEL('JA') ;
    JA('@JE') ;
    DATA(R1, 253) ;
    ST(R1, R0) ;
	LABEL('JE') ;
    JE('@JZ') ;
    DATA(R1, 254) ;
    ST(R1, R0) ;
	LABEL('JZ') ;
    JZ('@END') ;
    DATA(R1, 255) ;
    ST(R1, R0) ;
	LABEL('END') ;
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


sub simulate_instruction {
	my $RAM = shift ;
	my $inst = shift ;
	my $ra = shift ;
	my $rb = shift ;
	my $ci = shift ;

	# Clear flags
	$RAM->[252] = 0 ;
	$RAM->[253] = 0 ;
	$RAM->[254] = 0 ; 
	$RAM->[255] = 0 ;

	my $flags = 0 ;
	my $c = 0 ;
	my $a = $RAM->[248+$ra] > $RAM->[248+$rb] ;
	my $e = $RAM->[248+$ra] == $RAM->[248+$rb] ;
	if ($inst == 1010){ 	# SHL
		$c = $RAM->[248+$ra] >= 128 ;
		$RAM->[248+$rb] = ($RAM->[248+$ra] << 1) % 256 ;
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

	$RAM->[252] = $c ;
	if ($flags){
		$RAM->[253] = $a ;
		$RAM->[254] = $e ;
		$RAM->[255] = ! $RAM->[248+$rb] ;
		if ($flags == -1){
			$RAM->[255] = 1 ;
		}
	}
}


sub do_instruction {
	my $inst = shift ;
	my $ra = shift ;
	my $rb = shift ;

	CLF() ;

	if ($inst == 1010){ 	# SHL
		SHL($rmap{$ra}, $rmap{$rb}) ;
	}
	elsif ($inst == 1011){ 	# NOT
		NOT($rmap{$ra}, $rmap{$rb}) ;
	}
	elsif ($inst == 1100){ 	# AND
		AND($rmap{$ra}, $rmap{$rb}) ;
	}
	elsif ($inst == 1101){	# OR
		OR($rmap{$ra}, $rmap{$rb}) ;
	}
	elsif ($inst == 1110){	# XOR
		XOR($rmap{$ra}, $rmap{$rb}) ;
	}
	elsif ($inst == 1111){	# CMP
		CMP($rmap{$ra}, $rmap{$rb}) ;
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


__DATA__
DEBUG: RAM[229/11100101] = oct/01111101

  byte ra = random(0, 3) ;
  byte rb = random(0, 3) ;
  
  // Generate flags, repeat until we have a valid value as A and E cannot be true at the same time.
  byte flags = random(0, 16) ;
  while ((flags & B0110) == B0110)){
    flags = random(0, 16) ;
  }
  byte c = (flags & B1000) >> 3 ;
  byte a = (flags & B0100) >> 2 ;
  byte e = (flags & B0010) >> 1 ;
  byte z = flags & B0001 ;
  RAM[252] = c ;
  RAM[253] = a ;
  RAM[254] = e ;
  RAM[255] = z ;
  
  
  // Setup state
  /*
    // Insert instructions here to set FLAGS properly
    DATA(R0, v1)
    DATA(R1, v2)
    CLF
    OP(R0, R1)
    DATA(R0, r0)
    DATA(R1, r1)
    DATA(R2, r2)
    DATA(R3, r3)
    // ...
    // Save used registers to RAM
V   for (rx in (ra, rb)
      DATA(rx, 248+rx)
      ST(Rx, R0)
    
    // Save flags to RAM
    DATA(R0, 1)
    DATA(R1, 252)
    ST(R1, R0)
    DATA(R1, 253)
    ST(R1, R0)
    DATA(R1, 254)
    ST(R1, R0)
    DATA(R1, 255)
    ST(R1, R0)
    DATA(R0, 0)
    JC(idx+5)
    DATA(R1, 252)
    ST(R1, R0)
    JA(idx+5)
    DATA(R1, 253)
    ST(R1, R0)
    JE(idx+5)
    DATA(R1, 254)
    ST(R1, R0)
    JZ(idx+5)
    DATA(R1, 255)
    ST(R1, R0)
    HALT
}

