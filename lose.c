#define SS30 0xff200020
#define io_rd(addr) (*(volatile unsigned int *)(addr))
#define io_wr(addr, data) (*(volatile unsigned int *)(addr) = (data))
#define rd(addr) (*(unsigned int *)(addr))
#define wr(addr, data) (*(unsigned int *)(addr) = (data))
	
int main (void) {
	unsigned int *TIM = (unsigned int *) 0xff202000;

	unsigned int ptn;
	unsigned int lose;
	unsigned int flash;

	unsigned int tOut; //TimeOut

	//initializing counter
	unsigned int count = 0;
	unsigned int max = 0x5;

	//for TOP
	io_wr(TIM+3, 0x2FA); //TOPh for 10 ms timer
	io_wr(TIM+2, 0xF07F); //TOPl for 10 ms timer
	io_wr(TIM+1, 0b0110); //set START and CONT bits high

	flash = 0b00000000;

	lose = 0b01111001;
	ptn = 0b01101101;
	ptn = ptn << 8;
	lose = lose | ptn;
	ptn = 0b00111111;
	ptn = ptn << 16;
	lose = lose | ptn;
	ptn = 0b00111000;
	ptn = ptn << 24;
	lose = lose | ptn;
	
		
	while(count <= max) {
		do {
			tOut = io_rd(TIM);
			tOut = tOut & 0b01;
		}while(tOut == 0);
		
		io_wr(TIM, 0);
		count++;
		
		if (count % 2 != 0) {
			io_wr(SS30, lose);
		}
		else {
			io_wr(SS30, flash);
		}	
	}
	io_wr(SS30, flash);
	
	return 0;
}