/*
Subroutine: COMPLEX_TO_SS60
Purpose: convert the resultant complex number to BCD and display the ASCII character to the JTAG.
Input: real and imaginary numbers of the resultant complex number
Registers Used In Subroutine: r2 - r16
	r2 = real input
	r3 = imaginary input
	r4 = JTAG IO Address
	r5 = JTAG control register
	r6 = shifted JTAG control register
	r7 = stand in characters
		r7 = '+'
		r7 = 'j'
		r7 = line feed/enter
	r8 = extra register
	r9 = remainderR
	r10 = firstR
	r11 = remainderI
	r12 = firstI
	r13 = extra register
	r14 = pro
	r15 = 0x0A
	
Output: no output
Author: Liliana Holguin
Date: April 18, 2024
*/
.equ SWITCHES, 0xff200040
.equ LED, 0xff200000
.equ STACK, 0x8000
.equ JTAG, 0xff201000
.equ PB, 0xff200050

.global _start

_start:
	movia r2, SWITCHES
	movia r3, LED
	movia r4, 0x1000
	
	
	
	#r7 = swVal
	#r19 = imaginary
	#r20 = real
	
	movia r10, 0x000000FF
	movia r11, 0x0000FF00
	
	#PB STUFF
	movia sp, STACK
	
	movia r12, PB
	movi r13, 0b01
	stwio r13, 0x8(r12)
	movi r14, 1
	
	
	LOOP:
		
		ldwio r7, 0(r2) #load switchVal from switches into r7
		stwio r7, 0(r3) #store switchVal into LEDs
		
		
		#imaginary
		and r17, r7, r10 #gets imaginary number, r17, by anding switchVal and 0x00FF
		
		#real
		and r18, r7, r11 #gets real number, r18, by anding switchVal and 0xFF00
		srli r18, r18, 8 #shifts real number right 8 bits
		
		#CHECKS WHEN PUSHBUTTON PRESSED
		checkPB:
			ldhuio r13, 0xC(r12) #load PB edge-capture flag into r13
			andi r13, r13, 0b01 #apply mask to only keep PB bit 0
			beq r13, r0, checkPB #loop back if r13 = 0 (no event)
		movi r13, 0b01 #mask for PB bit 0
		stwio r13, 0xC(r12) #clear PB edge-capture flag
		
		stb r18, 0(r4) #store real number into memory address
		stb r17, 1(r4) #store imaginary number into next memory address with offset 1
		addi r4, r4, 2 #increase memory address by 2
	
		#PUSHES NEEDED REGISTERS (r2 - r15) ONTO STACK
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
		subi sp, sp, 4 
		stw r15, 0(sp) 
		
		#PUSHES INPUTS (r17-imaginary, r18- real) ONTO STACK
		subi sp, sp, 4 
		stw r17, 0(sp) 
		
		subi sp, sp, 4 
		stw r18, 0(sp) 
		
		call COMPLEX_TO_JTAG #calls COMPLEX_TO_JTAG subroutine
		
		#POPS DUMMY OUTPUTS (r0) FROM STACK
		ldw r0, 0(sp) 
		addi sp, sp, 4 
		
		ldw r0, 0(sp) 
		addi sp, sp, 4 
		
		#POPS USED REGISTERS (r15 - r2) FROM STACK
		ldw r15, 0(sp) 
		addi sp, sp, 4 
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
	
	COMPLEX_TO_JTAG:
		
		#POPS REAL INPUT
		ldw r2, 0(sp)
		addi sp, sp, 4
		
		#POPS IMAGINARY INPUT
		ldw r3, 0(sp)
		addi sp, sp, 4
		
		movi r15, 0xA #stores 0xA, 10, into r15
		
		#REAL NUMBER CALCULATIONS#
		divu r10, r2, r15 #divides real input by 0xA to get firstR, stored in r10
		mul r14, r10, r15 
		sub r9, r2, r14 #calculates the remainder of the real input divided by 0xA to get remainderR, stored in r9
		
		
		#CONVERTS remainderR INTO ASCII CHARACTER
		
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
		
		#PUSHES r9, remainderR, ONTO STACK
		subi sp, sp, 4 
		stw r9, 0(sp) 

		call ASCII #calls ASCII subroutine
		
		#POPS OUTPUT, remainderR, FROM ASCII SUBROUTINE INTO r9
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
		

		#CONVERTS firstR INTO ASCII CHARACTER
		
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
		
		#PUSHES r10, firstR, ONTO STACK
		subi sp, sp, 4 
		stw r10, 0(sp) 

		call ASCII #calls ASCII subroutine
		
		#POPS OUTPUT, firstR, FROM ASCII SUBROUTINE INTO r10
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
		
		
		#IMAGINARY NUMBER CALCULATIONS#
		divu r12, r3, r15 #divides imaginary input by 0xA to get firstI, stored in r12
		mul r14, r12, r15 
		sub r11, r3, r14 #calculates the remainder of the imaginary input divided by 0xA to get remainderI, stored in r11
		
		#CONVERTS remainderI INTO ASCII CHARACTER
		
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
		
		#PUSHES r11, remainderI, ONTO STACK
		subi sp, sp, 4 
		stw r11, 0(sp) 

		call ASCII #calls ASCII subroutine
		
		#POPS OUTPUT, remainderI, FROM ASCII SUBROUTINE INTO r11
		ldw r11, 0(sp) 
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
		
		#CONVERTS firstI INTO ASCII CHARACTER
		
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
		
		#PUSHES r12, firstI, ONTO STACK
		subi sp, sp, 4 
		stw r12, 0(sp) 

		call ASCII #calls ASCII subroutine
		
		#POPS OUTPUT, firstI, FROM ASCII SUBROUTINE INTO r12
		ldw r12, 0(sp) 
		addi sp, sp, 4 
		
		#POPS RETURN ADDRESS FROM STACK
		ldw ra, 0(sp) 
		addi sp, sp, 4 
		
		#PUSHES NEEDED REGISTERS (r2 - r4) ONTO STACK
		ldw r4, 0(sp)
		addi sp, sp, 4 
		ldw r3, 0(sp) 
		addi sp, sp, 4
		ldw r2, 0(sp) 
		addi sp, sp, 4 
		
		#WRITES TO JTAG#
		
		movia r4, JTAG #moves IO address for JTAG into r4
		
		#WRITES firstR TO JTAG
		writeFirstR:
			ldwio r5, 4(r4) #read JTAG control register into r5
			srli r6, r5, 16 #shift 16 to leave WSPACE in r6
			beq r6, r0, writeFirstR #if WRITE FIFO space = 0, wait
		stwio r10, 0(r4) #write firstR character, r10, to JTAG data register
		
		#WRITES remainderR TO JTAG
		writeRemainderR:
			ldwio r5, 4(r4) #read JTAG control register into r5
			srli r6, r5, 16 #shift 16 to leave WSPACE in r6
			beq r6, r0, writeRemainderR #if WRITE FIFO space = 0, wait
		stwio r9, 0(r4) #write remainderR character, r9, to JTAG data register
		
		#WRITES PLUS(+) TO JTAG
		writePlus:
			movi r7, 0x2B #moves ASCII Hex value for '+' into r7
			
			ldwio r5, 4(r4) #read JTAG control register into r5
			srli r6, r5, 16 #shift 16 to leave WSPACE in r6
			beq r6, r0, writePlus #if WRITE FIFO space = 0, wait
		stwio r7, 0(r4) #write plus(+) character, r7, to JTAG data register
		
		#WRITES j TO JTAG
		writeJ:
			movi r7, 0x6A #moves ASCII Hex value for 'j' into r7
			
			ldwio r5, 4(r4) #read JTAG control register into r5
			srli r6, r5, 16 #shift 16 to leave WSPACE in r6
			beq r6, r0, writeJ #if WRITE FIFO space = 0, wait
		stwio r7, 0(r4) #write 'j' character, r7, to JTAG data register
		
		#WRITES firstI TO JTAG
		writeFirstI:
			ldwio r5, 4(r4) #read JTAG control register into r5
			srli r6, r5, 16 #shift 16 to leave WSPACE in r6
			beq r6, r0, writeFirstI #if WRITE FIFO space = 0, wait
		stwio r12, 0(r4) #write firstI character, r12, to JTAG data register
		
		#WRITES remainderI TO JTAG
		writeRemainderI:
			ldwio r5, 4(r4) #read JTAG control register into r5
			srli r6, r5, 16 #shift 16 to leave WSPACE in r6
			beq r6, r0, writeRemainderI #if WRITE FIFO space = 0, wait
		stwio r11, 0(r4) #write remainderI character, r11, to JTAG data register
		
		#WRITES enter TO JTAG
		writeEnter:
			movi r7, 0xA #moves ASCII Hex value for enter/line feed into r7
			
			ldwio r5, 4(r4) #read JTAG control register into r5
			srli r6, r5, 16 #shift 16 to leave WSPACE in r6
			beq r6, r0, writeEnter #if WRITE FIFO space = 0, wait
		stwio r7, 0(r4) #write line feed(enter) character, r7, to JTAG data register
		
		#PUSHES DUMMY OUTPUTS, r0, ONTO STACK
		subi sp, sp, 4 
		stw r0, 0(sp)
		
		subi sp, sp, 4 
		stw r0, 0(sp)
		
		ret
	
	ASCII:
		
		#POPS VALUE, val
		ldw r2, 0(sp)
		addi sp, sp, 4

		#if val = 0, get ASCII hex value for 0 and move into r4
		Nxt0: movi r3,0x0
			bne r2,r3,Nxt1
			movi r4,0x30
			br done
		#else if val = 1, get ASCII hex value for 1 and move into r4
	 	Nxt1: movi r3,0x1
			bne r2,r3,Nxt2
			movi r4,0x31
			br done
		#else if val = 2, get ASCII hex value for 2 and move into r4
	 	Nxt2: movi r3,0x2
	  		bne r2,r3,Nxt3
	  		movi r4,0x32
	  		br done
		#else if val = 3, get ASCII hex value for 3 and move into r4
	 	Nxt3: movi r3,0x3
	  		bne r2,r3,Nxt4
	  		movi r4,0x33
	  		br done
		#else if val = 4, get ASCII hex value for 4 and move into r4
	 	Nxt4: movi r3,0x4
	  		bne r2,r3,Nxt5
	  		movi r4,0x34
	  		br done
		#else if val = 5, get ASCII hex value for 5 and move into r4
	 	Nxt5: movi r3,0x5
	  		bne r2,r3,Nxt6
	  		movi r4,0x35
	  		br done
		#else if val = 6, get ASCII hex value for 6 and move into r4
	 	Nxt6: movi r3,0x6
	  		bne r2,r3,Nxt7
	  		movi r4,0x36
	  		br done
		#else if val = 7, get ASCII hex value for 7 and move into r4
	 	Nxt7: movi r3,0x7
	  		bne r2,r3,Nxt8
	  		movi r4,0x37
	  		br done
		#else if val = 8, get ASCII hex value for 8 and move into r4
	 	Nxt8: movi r3,0x8
	  		bne r2,r3,Nxt9
	  		movi r4,0x38
	  		br done
		#else if val = 9, get ASCII hex value for 9 and move into r4
	 	Nxt9: movi r3,0x9
	  		bne r2,r3,dflt
	  		movi r4,0x39
	  		br done
		#else, get ASCII hex value for 'E' and move into r4
	 	dflt: movi r4, 0x45
		
		#PUSH ASCII hex value, r4, onto stack
	 	done:
	  		subi sp, sp, 4
	  		stw r4, 0(sp)
			
	  		ret
	
.end