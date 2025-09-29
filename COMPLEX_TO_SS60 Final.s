/*
Subroutine: COMPLEX_TO_SS60
Purpose: convert the resultant complex number to BCD and display the bit pattern to the Seven-Segment Display.
Input: real and imaginary numbers of the resultant complex number
Registers Used In Subroutine: r2 - r14
	r2 = real
		r2 = SS74 IO Address
	r3 = imaginary
		r3 = SS30 IO Address
	r6 = ptn0
	r5 = ptn1
	r4 = ptn2: |-
	r7 = ptn3: -|
	r8 = ptn4: j
	r9 = ptn5
	r10 = ptn6
	r11 = ptn30
	r12 = ptn74
	r13 = pro
	r14 = 0x0A
	
Output: no output
Author: Liliana Holguin
Date: April 18, 2024
*/

.equ SWITCHES, 0xff200040
.equ LED, 0xff200000
.equ STACK, 0x8000
.equ SS30, 0xff200020
.equ SS74, 0xff200030

.global _start

_start:
	movia r2, SWITCHES
	movia r3, LED
	
	movia r5, 0x000000FF
	movia r6, 0x0000FF00
	
	movia sp, STACK
	
	LOOP:
		
		ldwio r7, 0(r2) #load switchVal from switches into r7
		stwio r7, 0(r3) #store switchVal into LEDs
		
		#imaginary number
		and r17, r7, r5	#gets imaginary number, r17, by anding switchVal and 0x00FF
		
		#real number
		and r18, r7, r6 #gets real number, r18, by anding switchVal and 0xFF00
		srli r18, r18, 8 #shifts real number right 8 bits
		
		#PUSHES NEEDED REGISTERS (r2 - r14) ONTO STACK
		subi sp, sp, 4 		
		stw r2, 0(sp) 		
		subi sp, sp, 4 		
		stw r3, 0(sp) 		
		subi sp, sp, 4 		
		stw r4, 0(sp) #
		subi sp, sp, 4 		
		stw r5, 0(sp) 		
		subi sp, sp, 4 		
		stw r6, 0(sp)		
		subi sp, sp, 4 		
		stw r7, 0(sp)		
		subi sp, sp, 4 		
		stw r8, 0(sp)		
		subi sp, sp, 4 		
		stw r9, 0(sp) 		
		subi sp, sp, 4 		
		stw r10, 0(sp) 		
		subi sp, sp, 4 		
		stw r11, 0(sp) 		
		subi sp, sp, 4 		
		stw r12, 0(sp) 		
		subi sp, sp, 4 		
		stw r13, 0(sp) 		
		subi sp, sp, 4 
		stw r14, 0(sp) 
		
		
		#PUSHES INPUTS (r17-imaginary, r18- real) ONTO STACK
		subi sp, sp, 4
		stw r17, 0(sp)
		
		subi sp, sp, 4
		stw r18, 0(sp)
		
		call COMPLEX_TO_SS60 #calls COMPLEX_TO_SS60 subroutine
		
		#POPS DUMMY OUTPUTS (r0) FROM STACK
		ldw r0, 0(sp)
		addi sp, sp, 4
		
		ldw r0, 0(sp)
		addi sp, sp, 4
		
		#POPS USED REGISTERS (r14 - r2) FROM STACK
		ldw r14, 0(sp) 
		addi sp, sp, 4 
		ldw r13, 0(sp) 
		addi sp, sp, 4 
		ldw r12, 0(sp) 
		addi sp, sp, 4 
		ldw r11, 0(sp) 
		addi sp, sp, 4 
		ldw r10, 0(sp) 
		addi sp, sp, 4 
		ldw r9, 0(sp) 
		addi sp, sp, 4 
		ldw r8, 0(sp) 
		addi sp, sp, 4 
		ldw r7, 0(sp) 
		addi sp, sp, 4 
		ldw r6, 0(sp) 
		addi sp, sp, 4 
		ldw r5, 0(sp) 
		addi sp, sp, 4 
		ldw r4, 0(sp) 
		addi sp, sp, 4 
		ldw r3, 0(sp) 
		addi sp, sp, 4 
		ldw r2, 0(sp) 
		addi sp, sp, 4
		
		
	br LOOP
	
	COMPLEX_TO_SS60:
		
		#POPS REAL INPUT
		ldw r2, 0(sp)
		addi sp, sp, 4
		
		#POPS IMAGINARY INPUT
		ldw r3, 0(sp)
		addi sp, sp, 4
		
		movia r14, 0x0A #stores 0xA, 10, into r14
		
		#REAL NUMBER CALCULATIONS#
		divu r10, r2, r14 #divides real input by 0xA to get val6, stored in r10
		mul r13, r10, r14
		sub r9, r2, r13 #calculates the remainder of the real input divided by 0xA to get val5, stored in r9
		
		
		#GETS ptn5
		
		#PUSHES NEEDED REGISTERS (r2 - r4) ONTO STACK
		subi sp, sp, 4 
		stw r2, 0(sp) 
		subi sp, sp, 4 
		stw r3, 0(sp) 
		subi sp, sp, 4
		stw r4, 0(sp) 
		
		#PUSHES RETURN ADDRESS ONTO STACK
		subi sp, sp, 4 
		stw ra, 0(sp) 
		
		#PUSHES r9, val5, ONTO STACK
		subi sp, sp, 4 
		stw r9, 0(sp) 

		call Pat #calls Pat subroutine
		
		#POPS OUTPUT, ptn5, FROM Pat SUBROUTINE INTO r9
		ldw r9, 0(sp) 
		addi sp, sp, 4 
		
		#POPS RETURN ADDRESS FROM STACK
		ldw ra, 0(sp) 
		addi sp, sp, 4 
		
		#POPS UESED REGISTERS (r4 - r2) FROM STACK
		ldw r4, 0(sp) 
		addi sp, sp, 4 
		ldw r3, 0(sp) 
		addi sp, sp, 4 
		ldw r2, 0(sp) 
		addi sp, sp, 4 
		
		
		#GETS ptn6
		
		#PUSHES NEEDED REGISTERS (r2 - r4) ONTO STACK
		subi sp, sp, 4 
		stw r2, 0(sp) 
		subi sp, sp, 4 
		stw r3, 0(sp) 
		subi sp, sp, 4
		stw r4, 0(sp) 
		
		#PUSHES RETURN ADDRESS ONTO STACK
		subi sp, sp, 4 
		stw ra, 0(sp) 
		
		#PUSHES r10, val6, ONTO STACK
		subi sp, sp, 4 
		stw r10, 0(sp) 

		call Pat #calls Pat subroutine

		#POPS OUTPUT, ptn6, FROM Pat SUBROUTINE INTO r10
		ldw r10, 0(sp) 
		addi sp, sp, 4 
		
		#POPS RETURN ADDRESS FROM STACK
		ldw ra, 0(sp) 
		addi sp, sp, 4 
		
		#POPS USED REGISTERS (r4 - r2) FROM STACK
		ldw r4, 0(sp) 
		addi sp, sp, 4 
		ldw r3, 0(sp) 
		addi sp, sp, 4 
		ldw r2, 0(sp) 
		addi sp, sp, 4
		
		
		#DISPLAY TO SS74
		
		slli r9, r9, 8 #shifts r9, ptn5, left by 8 bits to be at SS6
		slli r10, r10, 16 #shifts r10, ptn6, left by 16 bits to be at SS5
		or r12, r10, r9 #ors bit pattern r9, ptn5, and r10, ptn6, into r12, ptn74
		movia r7, 0b01000110 #moves bit pattern for left side of plus into r7, ptn-|
		or r12, r12, r7 #ors r12, ptn74, and r7, ptn-|, into r12, ptn74
		
		movia r2, SS74 #moves IO address for SS74 into r2
		stwio r12, 0(r2) #stores r12, ptn74, into r2, SS74 IO address
		
		#IMAGINARY NUMBER CALCULATIONS#
		divu r5, r3, r14 #divides imaginary input by 0xA to get ptn1, stored in r5
		mul r13, r5, r14
		sub r6, r3, r13 #calculates the remainder of the imaginary input divided by 0xA to get ptn0, stored in r6
		
		
		#GETS ptn0
		
		#PUSHES NEEDED REGISTERS (r2 - r4) ONTO STACK
		subi sp, sp, 4 
		stw r2, 0(sp) 
		subi sp, sp, 4 
		stw r3, 0(sp) 
		subi sp, sp, 4
		stw r4, 0(sp) 
		
		#PUSHES RETURN ADDRESS ONTO STACK
		subi sp, sp, 4 
		stw ra, 0(sp) 
		
		#PUSHES r6, val0, ONTO STACK
		subi sp, sp, 4 
		stw r6, 0(sp) 

		call Pat #calls Pat subroutine
		
		#POPS OUTPUT, ptn0, FROM Pat SUBROUTINE INTO r6
		ldw r6, 0(sp) 
		addi sp, sp, 4 
		
		#POPS RETURN ADDRESS FROM STACK
		ldw ra, 0(sp) 
		addi sp, sp, 4 
		
		#POPS USED REGISTERS (r4 - r2) FROM STACK
		ldw r4, 0(sp) 
		addi sp, sp, 4 
		ldw r3, 0(sp) 
		addi sp, sp, 4 
		ldw r2, 0(sp) 
		addi sp, sp, 4 
		
		
		#GETS ptn1
		
		#PUSHES NEEDED REGISTERS (r2 - r4) ONTO STACK
		subi sp, sp, 4 
		stw r2, 0(sp) 
		subi sp, sp, 4 
		stw r3, 0(sp) 
		subi sp, sp, 4
		stw r4, 0(sp) 
		
		#PUSHES RETURN ADDRESS ONTO STACK
		subi sp, sp, 4 
		stw ra, 0(sp) 
		
		#PUSHES r5, val1, ONTO STACK
		subi sp, sp, 4 
		stw r5, 0(sp) 

		call Pat #calls Pat subroutine

		#POPS OUTPUT, ptn1, FROM Pat SUBROUTINE INTO r5
		ldw r5, 0(sp) 
		addi sp, sp, 4 
		
		#POPS RETURN ADDRESS FROM STACK
		ldw ra, 0(sp) 
		addi sp, sp, 4 
		
		#POPS USED REGISTERS (r4 - r2) FROM STACK
		ldw r4, 0(sp) 
		addi sp, sp, 4 
		ldw r3, 0(sp) 
		addi sp, sp, 4 
		ldw r2, 0(sp) 
		addi sp, sp, 4
		
		
		#DISPLAY TO SS30
		
		slli r5, r5, 8 #shifts r5, ptn1, left by 8 bits to be at SS1
		or r11, r5, r6 #ors bit pattern r6, ptn0, and r5, ptn1, into r11, ptn30
		movia r4, 0b00011110 #moves bit pattern for J into r4, ptnJ
		slli r4, r4, 16 #shifts r4, ptnJ, left by 16 bits to be at SS2
		or r11, r11, r4 #ors r11, ptn30, and r4, ptnJ, into r11, ptn30
		movia r8, 0b01110000 #moves bit pattern for right side of plus into r9, ptn|-
		slli r8, r8, 24 #shifts r8, ptn|-, left by 24 bits to be at SS3
		or r11, r11, r8 #ors r11, ptn30, and r8, ptn|-, into r11, ptn30
		
		movia r3, SS30 #moves IO address for SS30 into r3
		stwio r11, 0(r3) #stores r11, ptn30, into r3, SS30 IO address
		
		#PUSHES DUMMY OUTPUTS, r0, ONTO STACK
		subi sp, sp, 4
		stw r0, 0(sp)
		
		subi sp, sp, 4
		stw r0, 0(sp)
		
		ret
		
	Pat:
		#POPS VALUE, val
		ldw r2, 0(sp)
		addi sp, sp, 4
		
		#if val = 0, get bit pattern for 0 and move into r4
		Nxt0: 
			movi r3, 0x0
			bne r2, r3, Nxt1
			movi r4, 0b00111111
			br Done
		#else if val = 1, get bit pattern for 1 and move into r4
		Nxt1: 
			movi r3, 0x1
			bne r2, r3, Nxt2
			movi r4, 0b00000110
			br Done
		#else if val = 2, get bit pattern for 2 and move into r4
		Nxt2: 
			movi r3, 0x2
			bne r2, r3, Nxt3
			movi r4, 0b01011011
			br Done
		#else if val = 3, get bit pattern for 3 and move into r4
		Nxt3: 
			movi r3, 0x3
			bne r2, r3, Nxt4
			movi r4, 0b01001111
			br Done
		#else if val = 4, get bit pattern for 4 and move into r4
		Nxt4: 
			movi r3, 0x4
			bne r2, r3, Nxt5
			movi r4, 0b01100110
			br Done
		#else if val = 5, get bit pattern for 5 and move into r4
		Nxt5: 
			movi r3, 0x5
			bne r2, r3, Nxt6
			movi r4, 0b01101101
			br Done
		#else if val = 6, get bit pattern for 6 and move into r4
		Nxt6: 
			movi r3, 0x6
			bne r2, r3, Nxt7
			movi r4, 0b01111101
			br Done
		#else if val = 7, get bit pattern for 7 and move into r4
		Nxt7:
			movi r3, 0x7
			bne r2, r3, Nxt8
			movi r4, 0b00000111
			br Done
		#else if val = 8, get bit pattern for 8 and move into r4
		Nxt8:
			movi r3, 0x8
			bne r2, r3, Nxt9
			movi r4, 0b01111111
			br Done
		#else if val = 8, get bit pattern for 8 and move into r4
		Nxt9:
			movi r3, 0x9
			bne r2, r3, default
			movi r4, 0b01101111
			br Done
		#else, bit pattern is all lights on and move into r4
		default:
			movi r4, 0b11111111
			br Done
		
		#PUSH bit pattern, r4, onto stack
		Done:
			subi sp, sp, 4
			stw r4, 0(sp)
		
			ret
.end
		
		
			