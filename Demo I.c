#define SW 0xff200040
#define LED 0xff200000
#define SS30 0xff200020
#define io_rd(addr) (*(volatile unsigned int *)(addr))
#define io_wr(addr, data) (*(volatile unsigned int *)(addr) = (data))
#define rd(addr) (*(unsigned int *)(addr))
#define wr(addr, data) (*(unsigned int *)(addr) = (data))

//void display_win(char user_cards[], unsigned int user_total, unsigned int dealer_total);
unsigned int user_score(char user_card, unsigned int user_total);
unsigned int dealer_score(char dealer_cards[], unsigned int dealer_total);
void first_deal (char dealer_cards[], char user_cards[]);
void display_dealer_cards (char dealer_cards[], char user_cards[]);
void display_user_cards (char user_card);

int main(void) {
	unsigned int *mem = (unsigned int *) 0x1000;
	unsigned int *jtag = (unsigned int *) 0xff201000;
	
	
	unsigned int datareg;
	unsigned int rvalid;
	unsigned int ctrlreg;
	unsigned int wspace;
	
	char user_cards[] = {'0', '0', '0', '0', '0'};
	char dealer_cards[] = {'0', '0', '0', '0', '0'};
	
	char user_card;
	char user_card1;
	char user_card2;
	char user_card3;
	char user_card4;
	char user_card5;
	
	char dealer_card1;
	char dealer_card2;
	char dealer_card3;
	char dealer_card4;
	char dealer_card5;
	
	char dealer_first_cards [] = "Enter Dealer's First Cards: ";
	char user_first_cards[] = "\nEnter User's First Cards: ";
	char dealer_next_cards[] = "\nEnter Dealer's Next Cards: ";
	char user_next_cards[] = "\nEnter User's Next Cards: ";
	char new_line = '\n';
	
	unsigned int dis_total;
	
	unsigned int i;
	
	unsigned int user_total = 0;
	unsigned int dealer_total = 0;
	
	while (1) {
		//GET DEALER'S FIRST CARDS
		i = 0; 
		while(dealer_first_cards[i] != '\0') { 
			do {
				ctrlreg = io_rd(jtag+1);
				wspace = ctrlreg >> 16;
			} while (wspace == 0);
			io_wr(jtag, dealer_first_cards[i]);
			i++;
		}

		do{
			datareg = io_rd(jtag); 
			rvalid = datareg >> 15; 
			rvalid = rvalid & 0b01; 
		} while (rvalid == 0); 
		dealer_card1 = datareg & 0x00ff;

		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, dealer_card1);


		do{
			datareg = io_rd(jtag); 
			rvalid = datareg >> 15; 
			rvalid = rvalid & 0b01; 
		} while (rvalid == 0); 
		dealer_card2 = datareg & 0x00ff;

		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, dealer_card2);
		
		dealer_cards[0] = dealer_card1;
		dealer_cards[1] = dealer_card2;
		
		wr(mem, dealer_card1);
		wr(mem+1, dealer_card2);
		
		//GET USER'S FIRST CARDS
		i = 0; 
		while(dealer_first_cards[i] != '\0') { 
			do {
				ctrlreg = io_rd(jtag+1);
				wspace = ctrlreg >> 16;
			} while (wspace == 0);
			io_wr(jtag, user_first_cards[i]);
			i++;
		}

		do{
			datareg = io_rd(jtag); 
			rvalid = datareg >> 15; 
			rvalid = rvalid & 0b01; 
		} while (rvalid == 0); 
		user_card1 = datareg & 0x00ff;

		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, user_card1);
		
		

		do{
			datareg = io_rd(jtag); 
			rvalid = datareg >> 15; 
			rvalid = rvalid & 0b01; 
		} while (rvalid == 0); 
		user_card2 = datareg & 0x00ff;

		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, user_card2);
		
		
		
		user_cards[0] = user_card1;
		user_card = user_card1;
		user_total = user_score(user_card, user_total);
		dis_total = user_total | dealer_total;
		io_wr(LED, dis_total);
		
		user_cards[1] = user_card2;
		user_card = user_card2;
		user_total = user_score(user_card, user_total);
		dis_total = user_total | dealer_total;
		io_wr(LED, dis_total);
		
		wr(mem+5, user_card1);
		wr(mem+6, user_card2);
		

		
		//GET DEALER'S NEXT CARDS
		i = 0; 
		while(dealer_next_cards[i] != '\0') { 
			do {
				ctrlreg = io_rd(jtag+1);
				wspace = ctrlreg >> 16;
			} while (wspace == 0);
			io_wr(jtag, dealer_next_cards[i]);
			i++;
		}

		do{
			datareg = io_rd(jtag); 
			rvalid = datareg >> 15; 
			rvalid = rvalid & 0b01; 
		} while (rvalid == 0); 
		dealer_card3 = datareg & 0x00ff;

		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, dealer_card3);


		do{
			datareg = io_rd(jtag); 
			rvalid = datareg >> 15; 
			rvalid = rvalid & 0b01; 
		} while (rvalid == 0); 
		dealer_card4 = datareg & 0x00ff;

		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, dealer_card4);
		
		do{
			datareg = io_rd(jtag); 
			rvalid = datareg >> 15; 
			rvalid = rvalid & 0b01; 
		} while (rvalid == 0); 
		dealer_card5 = datareg & 0x00ff;

		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, dealer_card5);
		
		dealer_cards[2] = dealer_card3;
		dealer_total = dealer_score(dealer_cards, dealer_total);
		dealer_total = dealer_total << 8;
		dis_total = user_total | dealer_total;
		io_wr(LED, dis_total);

		dealer_cards[3] = dealer_card4;
		dealer_total = dealer_score(dealer_cards, dealer_total);
		dealer_total = dealer_total << 8;
		dis_total = user_total | dealer_total;
		io_wr(LED, dis_total);
		
		dealer_cards[4] = dealer_card5;
		dealer_total = dealer_score(dealer_cards, dealer_total);
		dealer_total = dealer_total << 8;
		dis_total = user_total | dealer_total;
		io_wr(LED, dis_total);
		
		wr(mem+2, dealer_card3);
		wr(mem+3, dealer_card4);
		wr(mem+4, dealer_card5);
		
		//GET USER'S NEXT CARDS
		i = 0; 
		while(user_next_cards[i] != '\0') { 
			do {
				ctrlreg = io_rd(jtag+1);
				wspace = ctrlreg >> 16;
			} while (wspace == 0);
			io_wr(jtag, user_next_cards[i]);
			i++;
		}

		do{
			datareg = io_rd(jtag); 
			rvalid = datareg >> 15; 
			rvalid = rvalid & 0b01; 
		} while (rvalid == 0); 
		user_card3 = datareg & 0x00ff;

		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, user_card3);

		
		do{
			datareg = io_rd(jtag); 
			rvalid = datareg >> 15; 
			rvalid = rvalid & 0b01; 
		} while (rvalid == 0); 
		user_card4 = datareg & 0x00ff;

		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, user_card4);
		
		do{
			datareg = io_rd(jtag); 
			rvalid = datareg >> 15; 
			rvalid = rvalid & 0b01; 
		} while (rvalid == 0); 
		user_card5 = datareg & 0x00ff;

		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, user_card5);
		
		user_cards[2] = user_card3;
		user_cards[3] = user_card4;
		user_cards[4] = user_card5;
		
		wr(mem+7, user_card3);
		wr(mem+8, user_card4);
		wr(mem+9, user_card5);
		
		//DISPLAY TO JTAG
		first_deal(dealer_cards, user_cards);
		
		i = 2;
		while (i < 5) {
			user_card = user_cards[i];
			display_user_cards(user_card);
			user_total = user_score(user_card, user_total);
			dis_total = user_total | dealer_total;
			io_wr(LED, dis_total);
			i++;
		}
		
		display_dealer_cards(dealer_cards, user_cards);
		dealer_total = dealer_score(dealer_cards, dealer_total);
		dealer_total = dealer_total << 8;
		dis_total = user_total | dealer_total;
		io_wr(LED, dis_total);
		
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, new_line);
	}
	return 0;
}

void first_deal (char dealer_cards[], char user_cards[]) {
	unsigned int *jtag = (unsigned int *) 0xff201000;
	
	unsigned int ctrlreg;
	unsigned int wspace;
	
	char dealer_card_msg [] = "\nDealer Cards: ";
	char user_card_msg[] = "\nUser Cards:   ";
	
	char ast = 0x2A;
	unsigned int i;
	
	i = 0; 
	while(dealer_card_msg[i] != '\0') { 
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, dealer_card_msg[i]);
		i++;
	}
	
	do {
		ctrlreg = io_rd(jtag+1);
		wspace = ctrlreg >> 16;
	} while (wspace == 0);
	io_wr(jtag, ast);
	
	do {
		ctrlreg = io_rd(jtag+1);
		wspace = ctrlreg >> 16;
	} while (wspace == 0);
	io_wr(jtag, dealer_cards[1]);
	
	i = 0; 
	while(user_card_msg[i] != '\0') { 
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, user_card_msg[i]);
		i++;
	}
	
	do {
		ctrlreg = io_rd(jtag+1);
		wspace = ctrlreg >> 16;
	} while (wspace == 0);
	io_wr(jtag, user_cards[0]);
	
	do {
		ctrlreg = io_rd(jtag+1);
		wspace = ctrlreg >> 16;
	} while (wspace == 0);
	io_wr(jtag, user_cards[1]);
	
}

void display_user_cards (char user_card) {
	unsigned int *jtag = (unsigned int *) 0xff201000;
	
	unsigned int ctrlreg;
	unsigned int wspace;
	
	do {
		ctrlreg = io_rd(jtag+1);
		wspace = ctrlreg >> 16;
	} while (wspace == 0);
	io_wr(jtag, user_card);
}

void display_dealer_cards (char dealer_cards[], char user_cards[]) {
	unsigned int *jtag = (unsigned int *) 0xff201000;
	
	unsigned int ctrlreg;
	unsigned int wspace;
	
	char dealer_card_msg [] = "\nDealer Cards: ";
	char user_card_msg[] = "\nUser Cards: ";
	
	unsigned int i;
	
	i = 0; 
	while(dealer_card_msg[i] != '\0') { 
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, dealer_card_msg[i]);
		i++;
	}
	
	i = 0;
	while (i < 5) {
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, dealer_cards[i]);
		i++;
	}
	
	i = 0; 
	while(user_card_msg[i] != '\0') { 
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, user_card_msg[i]);
		i++;
	}
	
	i = 0;
	while (i < 5) {
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, user_cards[i]);
		i++;
	}	
}

unsigned int user_score(char user_card, unsigned int user_total) {
	
	if (user_card != '0') {
		switch (user_card) {
			case 'A':
			case 'a':
				user_total += 0x1;
				break;
			case '2':
				user_total += 0x2;
				break;
			case '3':
				user_total += 0x3;
				break;
			case '4':
				user_total += 0x4;
				break;
			case '5':
				user_total += 0x5;
				break;
			case '6':
				user_total += 0x6;
				break;
			case '7':
				user_total += 0x7;
				break;
			case '8':
				user_total += 0x8;
				break;
			case '9':
				user_total += 0x9;
				break;
			case '1':
			case 'J':
			case 'j':
			case 'Q':
			case 'q':
			case 'K':
			case 'k':
				user_total += 0xA;
				break;
			default:
				user_total += 0x0;
				break;
		}
	}
	return user_total;
}

unsigned int dealer_score(char dealer_cards[], unsigned int dealer_total) {
	unsigned int i;
	
	i = 0;
	while (i < 5) {
		switch (dealer_cards[i]) {
			case 'A':
			case 'a':
				dealer_total += 0x1;
				break;
			case '2':
				dealer_total += 0x2;
				break;
			case '3':
				dealer_total += 0x3;
				break;
			case '4':
				dealer_total += 0x4;
				break;
			case '5':
				dealer_total += 0x5;
				break;
			case '6':
				dealer_total += 0x6;
				break;
			case '7':
				dealer_total += 0x7;
				break;
			case '8':
				dealer_total += 0x8;
				break;
			case '9':
				dealer_total += 0x9;
				break;
			case '1':
			case 'J':
			case 'j':
			case 'Q':
			case 'q':
			case 'K':
			case 'k':
				dealer_total += 0xA;
				break;
			default:
				dealer_total += 0x0;
				break;
		}
		i++;
	}
	return dealer_total;
}