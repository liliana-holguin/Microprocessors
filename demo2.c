#define SW  0xff200040	 //constant SW input address 
#define LED 0xff200000	 //constant LED output address 
#define SS30 0xff200020 // address of 7-segment displays 3 to 0
#define SS74 0xff200030 // address of 7-segment displays 7 to 4
#define io_rd(addr) (*(volatile unsigned int *)(addr))
#define io_wr(addr, data) (*(volatile unsigned int *)(addr) = (data))
#define rd(addr) (*(unsigned int *)(addr))
#define wr(addr, data) (*(unsigned int *)(addr) = (data))

unsigned int Led_Feedback(unsigned int val1);
int main()						//start here
{ 
	//unsigned int *mem = (unsigned int *) 0x2000;	// declare pointer to memory address mem at 0x1000
	unsigned int pbFlag;
    unsigned int *PB = (unsigned int *) 0xff200050; // (1) PB pointer
    io_wr(PB+2, 0b01); // (2) enable PB interrupt bit0 (CPUlator
	unsigned int selection; 		// 32-bit unsigned integer val
	unsigned int val1; 		// 32-bit unsigned integer val

while (1){	
	
	do{							
		val1 = io_rd(SW);				// read from switches	
		pbFlag = io_rd(PB+3); 			// check if PB was pressed
		pbFlag = pbFlag & 0b01; 		// mask PB bit 0
											// & = bitwise AND operation
	}while (pbFlag == 0); 			// if NOT pressed stay in loop
	io_wr(PB+3, 0b01); 
	
	selection = Led_Feedback(val1);
	io_wr(LED, selection);
}
return 0;	
}
unsigned int Led_Feedback(unsigned int val1){
	unsigned int ptn;
	switch(val1) {
		case 0:
			ptn = 0b0000000000000000000000000000000; break;
		case 1:
			ptn = 0b0000000000000000000000000000001; break;
		case 2:
			ptn = 0b0000000000000000000000000000011; break;
		case 3:
			ptn = 0b0000000000000000000000000000111; break;
		case 4:
			ptn = 0b0000000000000000000000000001111; break;
		case 5:
			ptn = 0b0000000000000000000000000011111; break;
		case 6:
			ptn = 0b0000000000000000000000000111111; break;
		case 7:
			ptn = 0b0000000000000000000000001111111; break;
		case 8:
			ptn = 0b0000000000000000000000011111111; break;
		case 9:
			ptn = 0b0000000000000000000000111111111; break;
		case 10:
			ptn = 0b0000000000000000000001111111111; break;
		case 11:
			ptn = 0b0000000000000000000011111111111; break;
		case 12:
			ptn = 0b0000000000000000000111111111111; break;
		case 13:
			ptn = 0b0000000000000000001111111111111; break;
		case 14:
			ptn = 0b0000000000000000011111111111111; break;
		case 15:
			ptn = 0b0000000000000000111111111111111; break;
		case 16:
			ptn = 0b0000000000000001111111111111111; break;
		case 17:
			ptn = 0b0000000000000011111111111111111; break;
		case 18:
			ptn = 0b0000000000000111111111111111111; break;
		case 19:
			ptn = 0b0000000000001111111111111111111; break;
		case 20:
			ptn = 0b0000000000011111111111111111111; break;
		case 21:
			ptn = 0b0000000000111111111111111111111; break;
		case 22:
			ptn = 0b0000000001111111111111111111111; break;
		case 23:
			ptn = 0b0000000011111111111111111111111; break;
		case 24:
			ptn = 0b000000011111111111111111111111; break;
		case 25:
			ptn = 0b0000001111111111111111111111111; break;
		case 26:
			ptn = 0b0000011111111111111111111111111; break;
		case 27:
			ptn = 0b0000111111111111111111111111111; break;
		case 28:
			ptn = 0b0001111111111111111111111111111; break;
		case 29:
			ptn = 0b0011111111111111111111111111111; break;
		case 30:
			ptn = 0b0111111111111111111111111111111; break;
		case 31:
			ptn = 0b1111111111111111111111111111111; break;
		default:
			ptn = 0b0101010101010101010101010101010; 
	}
	return ptn;
}
	