#define SW 0xff200040
#define LED 0xff200000
#define SS30 0xff200020
#define io_rd(addr) (*(volatile unsigned int *)(addr))
#define io_wr(addr, data) (*(volatile unsigned int *)(addr) = (data))
#define rd(addr) (*(unsigned int *)(addr))
#define wr(addr, data) (*(unsigned int *)(addr) = (data))

void display_win(unsigned int user_cards[], unsigned int user_total, unsigned int dealer_total);
void display_bust(unsigned int user_total);
unsigned int user_score(char user_card, unsigned int user_total);
unsigned int dealer_score(char dealer_card, unsigned int dealer_total);
void first_deal(unsigned int dealer_cards[], unsigned int user_cards[]);
void display_dealer_cards(unsigned int dealer_cards[], unsigned int user_cards[]);
void display_user_cards (char user_card); 
	
int main(void) {
	
	//Initialize Variables
	unsigned int *mem = (unsigned int *) 0x4000;
	unsigned int *jtag = (unsigned int *) 0xff201000;
	
	
	unsigned int datareg;
	unsigned int rvalid;
	unsigned int ctrlreg;
	unsigned int wspace;
	
	unsigned int user_cards[] = {0, 0, 0, 0, 0};
	unsigned int dealer_cards[] = {0, 0, 0, 0, 0};
	
	char user_card;
	char user_card1;
	char user_card2;
	char user_card3;
	char user_card4;
	char user_card5;
	
	char dealer_card;
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
	
	while (1) {
		//Initialize Totals
		unsigned int user_total = 0;
		unsigned int dealer_total = 0;
		
		//GET DEALER'S FIRST CARDS//
		
		//Print "Enter Dealer's First Cards: "
		i = 0; 
		while(dealer_first_cards[i] != '\0') { 
			do {
				ctrlreg = io_rd(jtag+1);
				wspace = ctrlreg >> 16;
			} while (wspace == 0);
			io_wr(jtag, dealer_first_cards[i]);
			i++;
		}
		
		//Read and Echo Print Dealer Card 1
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
		
		//Add Dealer Card 1 to Dealer Card Array
		dealer_cards[0] = dealer_card1;
		//Assign Dealer Card 1 to Dealer Card
		dealer_card = dealer_card1;
		//Store Dealer Card 1 to Memory
		wr(mem, dealer_card1);
		
		//GET DEALER TOTAL AND DISPLAY TO LEDS
		
		//Get Dealer Total
		dealer_total = dealer_score(dealer_card, dealer_total);
		//Store to Memory
		wr(mem+10, dealer_total); 
		//Shift Dealer Total Left 8
		dealer_total = dealer_total << 8;  
		//Combine Dealer Total with User Total and Store Into Variable dis_total
		dis_total = user_total | dealer_total; 
		//Shift Dealer Total Right 8
		dealer_total = dealer_total >> 8;
		//Display Dealer and User Total to LEDs
		io_wr(LED, dis_total);
		
		
		//Read and Echo Print Dealer Card 2
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
		
		
		//Add Dealer Card 2 to Dealer Card Array
		dealer_cards[1] = dealer_card2;
		//Assign Dealer Card 2 to Dealer Card
		dealer_card = dealer_card2;
		//Store Dealer Card 2 to Memory
		wr(mem+1, dealer_card2);
		
		
		//GET DEALER TOTAL AND DISPLAY TO LEDS
		
		//Get Dealer Total
		dealer_total = dealer_score(dealer_card, dealer_total);
		//Store to Memory
		wr(mem+10, dealer_total);
		//Shift Dealer Total Left 8
		dealer_total = dealer_total << 8;
		//Combine Dealer Total with User Total and Store Into Variable dis_total
		dis_total = user_total | dealer_total;
		//Shift Dealer Total Right 8
		dealer_total = dealer_total >> 8;
		//Display Dealer and User Total to LEDs
		io_wr(LED, dis_total);
		
		
		//GET USER'S FIRST CARDS//
		
		//Print "Enter User's First Cards: "
		i = 0; 
		while(user_first_cards[i] != '\0') { 
			do {
				ctrlreg = io_rd(jtag+1);
				wspace = ctrlreg >> 16;
			} while (wspace == 0);
			io_wr(jtag, user_first_cards[i]);
			i++;
		}
		
		//Read and Echo Print User Card 1
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
		
		//Add User Card 1 to User Card Array
		user_cards[0] = user_card1;
		//Assign User Card 1 to User Card
		user_card = user_card1;
		//Store User Card 1 to Memory
		wr(mem+5, user_card1);
		
		
		//GET USER TOTAL AND DISPLAY TO LEDS
		
		//Get User Total
		user_total = user_score(user_card, user_total);
		//Store User Total to Memory
		wr(mem+11, user_total);
		//Shift Dealer Total Left 8
		dealer_total = dealer_total << 8;
		//Combine User Total with Dealer Total Into Variable dis_total
		dis_total = user_total | dealer_total;
		//Shift Dealer Total Right 8
		dealer_total = dealer_total >> 8;
		//Display Dealer and User Total to LEDs
		io_wr(LED, dis_total);
		
		
		//Read and Echo Print User Card 2
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
		
		//Add User Card 2 to User Card Array
		user_cards[1] = user_card2;
		//Assign User Card 2 to User Card
		user_card = user_card2;
		//Store User Card 2 to Memory
		wr(mem+6, user_card2);
		
		
		//GET USER TOTAL AND DISPLAY TO LEDS
		
		//Get User Total
		user_total = user_score(user_card, user_total);
		//Store User Total to Memory
		wr(mem+11, user_total);
		//Shift Dealer Total Left 8
		dealer_total = dealer_total << 8;
		//Combine User Total with Dealer Total Into Variable dis_total
		dis_total = user_total | dealer_total;
		//Shift Dealer Total Right 8
		dealer_total = dealer_total >> 8;
		//Display Dealer and User Total to LEDs
		io_wr(LED, dis_total);
		

		
		//GET DEALER'S NEXT CARDS//
		
		//Print "Enter Dealer's Next Cards: "
		i = 0; 
		while(dealer_next_cards[i] != '\0') { 
			do {
				ctrlreg = io_rd(jtag+1);
				wspace = ctrlreg >> 16;
			} while (wspace == 0);
			io_wr(jtag, dealer_next_cards[i]);
			i++;
		}
		
		//Read and Echo Print Dealer Card 3
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
		
		//Add Dealer Card 3 to Dealer Card Array
		dealer_cards[2] = dealer_card3;
		//Assign Dealer Card 3 to Dealer Card
		dealer_card = dealer_card3;
		//Store Dealer Card 3 to Memory
		wr(mem+2, dealer_card3);
		
		
		//GET DEALER TOTAL AND DISPLAY TO LEDS
		
		//Get Dealer Total
		dealer_total = dealer_score(dealer_card, dealer_total);
		//Store Dealer Total to Memory
		wr(mem+10, dealer_total);
		//Shift Dealer Total Left 8
		dealer_total = dealer_total << 8;
		//Combine Dealer Total and User Total Into Variable dis_total
		dis_total = user_total | dealer_total;
		//Shift Dealer Total Right 8
		dealer_total = dealer_total >> 8;
		//Display Dealer Total and User Total to LEDs
		io_wr(LED, dis_total);
		

		//Read and Echo Print Dealer Card 4
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
		
		//Add Dealer Card 4 to Dealer Card Array
		dealer_cards[3] = dealer_card4;
		//Assign Dealer Card 4 to Dealer Card
		dealer_card = dealer_card4;
		//Store Dealer Card 4 to Memory
		wr(mem+3, dealer_card4);
		
		
		//GET DEALER TOTAL AND DISPLAY TO LEDS
		
		//Get Dealer Total
		dealer_total = dealer_score(dealer_card, dealer_total);
		//Store Dealer Totoal to Memory
		wr(mem+10, dealer_total);
		//Shift Dealer Total Left 8
		dealer_total = dealer_total << 8;
		//Combine Dealer Total and User Total Into Variable dis_total
		dis_total = user_total | dealer_total;
		//Shift Dealer Total Right 8
		dealer_total = dealer_total >> 8;
		//Display Dealer Total and User Total to LEDs
		io_wr(LED, dis_total);
		
		
		//Read and Echo Print Dealer Card 4
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
		
		//Add Dealer Card 5 to Dealer Card Array
		dealer_cards[4] = dealer_card5;
		//Assign Dealer Card 5 to Dealer Card
		dealer_card = dealer_card5;
		//Store Dealer Card 5 to Memory
		wr(mem+4, dealer_card5);
		
		
		//GET DEALER TOTAL AND DISPLAY TO LEDS
		
		//Store Dealer Totoal to Memory
		dealer_total = dealer_score(dealer_card, dealer_total);
		//Store Dealer Totoal to Memory
		wr(mem+10, dealer_total);
		//Shift Dealer Total Left 8
		dealer_total = dealer_total << 8;
		//Combine Dealer Total and User Total Into Variable dis_total
		dis_total = user_total | dealer_total;
		//Shift Dealer Total Right 8
		dealer_total = dealer_total >> 8;
		//Display Dealer Total and User Total to LEDs
		io_wr(LED, dis_total);
				
		
		//GET USER'S NEXT CARDS//
		
		//Print "Enter User's Next Cards: "
		i = 0; 
		while(user_next_cards[i] != '\0') { 
			do {
				ctrlreg = io_rd(jtag+1);
				wspace = ctrlreg >> 16;
			} while (wspace == 0);
			io_wr(jtag, user_next_cards[i]);
			i++;
		}
		
		//Read and Echo Print User Card 3
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
		
		//Add User Card 3 to User Card Array
		user_cards[2] = user_card3;
		//Assign User Card 3 to User Card
		user_card = user_card3;
		//Store User Card 3 to Memory
		wr(mem+7, user_card3);
		
		
		//GET USER TOTAL AND DISPLAY TO LEDS
		
		//Get User Total
		user_total = user_score(user_card, user_total);
		//Store User Total to Memory
		wr(mem+11, user_total);
		//Shift Dealer Total Left 8
		dealer_total = dealer_total << 8;
		//Combine Dealer Total and User Total Into Variable dis_total
		dis_total = user_total | dealer_total;
		//Shift Dealer Total Right 8
		dealer_total = dealer_total >> 8;
		//Display Dealer Total and User Total to LEDs
		io_wr(LED, dis_total);
		
		
		//Read and Echo Print User Card 4
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
		
		//Add User Card 4 to User Card Array
		user_cards[3] = user_card4;
		//Assign User Card 4 to User Card
		user_card = user_card4;
		//Store User Card 4 to Memory
		wr(mem+8, user_card4);
		
		
		//GET USER TOTAL AND DISPLAY TO LEDS
		
		//Get User Total
		user_total = user_score(user_card, user_total);
		//Store User Total to Memory
		wr(mem+11, user_total)
		//Shift Dealer Total Left 8
		dealer_total = dealer_total << 8;
		//Combine Dealer Total and User Total Into Variable dis_total
		dis_total = user_total | dealer_total;
		//Shift Dealer Total Right 8
		dealer_total = dealer_total >> 8;
		//Display Dealer Total and User Total to LEDs
		io_wr(LED, dis_total);
		
		
		//Read and Echo Print User Card 5
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
		
		//Add User Card 5 to User Card Array
		user_cards[4] = user_card5;
		//Assign User Card 5 to User Card
		user_card = user_card5;
		//Store User Card 5 to Memory
		wr(mem+9, user_card5);
		
		
		//GET USER TOTAL AND DISPLAY TO LEDS
		
		//Get User Total
		user_total = user_score(user_card, user_total);
		//Store User Total to Memory
		wr(mem+11, user_total)
		//Shift Dealer Total Left 8
		dealer_total = dealer_total << 8;
		//Combine Dealer Total and User Total Into Variable dis_total
		dis_total = user_total | dealer_total;
		//Shift Dealer Total Right 8
		dealer_total = dealer_total >> 8;
		//Display Dealer Total and User Total to LEDs
		io_wr(LED, dis_total);
		
		
		//DISPLAY TO JTAG//
		
		//Displays First Cards for Dealer and User to JTAG
		first_deal(dealer_cards, user_cards);
		
		//Prints Next User Cards Next to First User Cards
		i = 2;
		while (i < 5) {
			user_card = user_cards[i];
			display_user_cards(user_card);
			i++;
		}
		
		//Displays Dealer Cards and User Cards in Next Lines
		display_dealer_cards(dealer_cards, user_cards);
		
		
		//DETERMINE WIN//
		
		//Determine If User Bust
		if (user_total >= 22) {
				display_bust(user_total);
		}
		//Determine If User Won or Lost
		else {
			display_win(user_cards, user_total, dealer_total);
		}
		
		//Print New Line
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, new_line);
	}
	return 0;
}

//FIRST DEAL FUNCTION//
void first_deal (unsigned int dealer_cards[], unsigned int user_cards[]) {
	//Initialize Variables
	unsigned int *jtag = (unsigned int *) 0xff201000;
	
	unsigned int ctrlreg;
	unsigned int wspace;
	
	char dealer_card_msg [] = "\nDealer Cards: ";
	char user_card_msg[] = "\nUser Cards:   ";
	
	char ast = 0x2A;
	unsigned int i;
	
	//Print "Dealer Cards: "
	i = 0; 
	while(dealer_card_msg[i] != '\0') { 
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, dealer_card_msg[i]);
		i++;
	}
	
	//Hide Dealer's First Card with *
	do {
		ctrlreg = io_rd(jtag+1);
		wspace = ctrlreg >> 16;
	} while (wspace == 0);
	io_wr(jtag, ast);
	
	//Print Dealer's Second Card
	do {
		ctrlreg = io_rd(jtag+1);
		wspace = ctrlreg >> 16;
	} while (wspace == 0);
	io_wr(jtag, dealer_cards[1]);
	
	
	//Print "User Cards:  "
	i = 0; 
	while(user_card_msg[i] != '\0') { 
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, user_card_msg[i]);
		i++;
	}
	
	//Prints User's First Card
	do {
		ctrlreg = io_rd(jtag+1);
		wspace = ctrlreg >> 16;
	} while (wspace == 0);
	io_wr(jtag, user_cards[0]);
	
	//Prints User's Second Card
	do {
		ctrlreg = io_rd(jtag+1);
		wspace = ctrlreg >> 16;
	} while (wspace == 0);
	io_wr(jtag, user_cards[1]);
	
}

//DISPLAY USER CARDS FUNCTION//
void display_user_cards (char user_card) {
	//Initialize Variables
	unsigned int *jtag = (unsigned int *) 0xff201000;
	
	unsigned int ctrlreg;
	unsigned int wspace;
	
	//Display User Card
	do {
		ctrlreg = io_rd(jtag+1);
		wspace = ctrlreg >> 16;
	} while (wspace == 0);
	io_wr(jtag, user_card);
}

//DISPLAY DEALER CARDS FUNCTION//
void display_dealer_cards (unsigned int dealer_cards[], unsigned int user_cards[]) {
	//Initialize Variables
	unsigned int *jtag = (unsigned int *) 0xff201000;
	
	unsigned int ctrlreg;
	unsigned int wspace;
	
	char dealer_card_msg [] = "\nDealer Cards: ";
	char user_card_msg[] = "\nUser Cards:   ";
	
	unsigned int i;
	
	//Print "Dealer Cards: "
	i = 0; 
	while(dealer_card_msg[i] != '\0') { 
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, dealer_card_msg[i]);
		i++;
	}
	
	//Print All Dealer Cards
	i = 0;
	while (i < 5) {
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, dealer_cards[i]);
		i++;
	}
	
	//Print "User Cards: "
	i = 0; 
	while(user_card_msg[i] != '\0') { 
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, user_card_msg[i]);
		i++;
	}
	
	//Print All User Cards
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

//USER SCORE FUNCTION//
unsigned int user_score(char user_card, unsigned int user_total) {
	//Switch Statement to Assign User Card a Value and Update User Total
	switch (user_card) {
		case 'A':
		case 'a':
			user_total += 1;
			break;
		case '2':
			user_total += 2;
			break;
		case '3':
			user_total += 3;
			break;
		case '4':
			user_total += 4;
			break;
		case '5':
			user_total += 5;
			break;
		case '6':
			user_total += 6;
			break;
		case '7':
			user_total += 7;
			break;
		case '8':
			user_total += 8;
			break;
		case '9':
			user_total += 9;
			break;
		case 't':
		case 'J':
		case 'j':
		case 'Q':
		case 'q':
		case 'K':
		case 'k':
			user_total += 10;
			break;
		default:
			user_total += 0;
			break;
	}
	//Return Updated User Total
	return user_total;
}

//DEALER SCORE FUNCTION//
unsigned int dealer_score(char dealer_card, unsigned int dealer_total){
	//Switch Statement to Assign Dealer Card a Value and Update Dealer Total
	switch (dealer_card) {
		case 'A':
		case 'a':
			dealer_total += 1;
			break;
		case '2':
			dealer_total += 2;
			break;
		case '3':
			dealer_total += 3;
			break;
		case '4':
			dealer_total += 4;
			break;
		case '5':
			dealer_total += 5;
			break;
		case '6':
			dealer_total += 6;
			break;
		case '7':
			dealer_total += 7;
			break;
		case '8':
			dealer_total += 8;
			break;
		case '9':
			dealer_total += 9;
			break;
		case 't':
		case 'J':
		case 'j':
		case 'Q':
		case 'q':
		case 'K':
		case 'k':
			dealer_total += 10;
			break;
		default:
			dealer_total += 0;
			break;
	}
	//Return Updated Dealer Total
	return dealer_total;
}

//DISPLAY BUST FUNCTION//
void display_bust(unsigned int user_total) {
	//Initialize Variables
	unsigned int *TIM = (unsigned int *) 0xff202000;

	unsigned int ptn;
	unsigned int bust;
	unsigned int flash;

	unsigned int tOut; //TimeOut

	//initializing counter and max
	unsigned int count = 0;
	unsigned int max = 0x7;

	//for TOP
	io_wr(TIM+3, 0x2FA); //TOPh for 10 ms timer
	io_wr(TIM+2, 0xF07F); //TOPl for 10 ms timer
	io_wr(TIM+1, 0b0110); //set START and CONT bits high
	
	//Turn All Lights Off to Create Flash
	flash = 0b00000000;
	
	//Create "bUSt" Pattern
	bust = 0b01111000;
	ptn = 0b01101101;
	ptn = ptn << 8;
	bust = bust | ptn;
	ptn = 0b00111110;
	ptn = ptn << 16;
	bust = bust | ptn;
	ptn = 0b01111100;
	ptn = ptn << 24;
	bust = bust | ptn;
	
	//Determine if User Bust
	if (user_total >= 22) {
		//Create Timer
		while(count <= max) {
			do {
				tOut = io_rd(TIM);
				tOut = tOut & 0b01;
			}while(tOut == 0);

			io_wr(TIM, 0);
			count++;
			//On Odd Second, Display Bust
			if (count % 2 != 0) {
				io_wr(SS30, bust);
			}
			//On Even Second, Flash
			else {
				io_wr(SS30, flash);
			}	
		}
		//End with No Lights Displayed
		io_wr(SS30, flash);
	}
	//Else No Lights Displayed
	else {
		io_wr(SS30, flash);
	}
}

//DISPLAY WIN FUNCTION//
void display_win(unsigned int user_cards[], unsigned int user_total, unsigned int dealer_total) {
	//Initialize Variables
	unsigned int *TIM = (unsigned int *) 0xff202000;

	unsigned int ptn;
	unsigned int win;
	unsigned int lose;
	unsigned int flash;

	unsigned int tOut; //TimeOut

	//initializing counter and max
	unsigned int count = 0;
	unsigned int max = 0x7;

	//for TOP
	io_wr(TIM+3, 0x2FA); //TOPh for 1 s timer
	io_wr(TIM+2, 0xF07F); //TOPl for 1 s timer
	io_wr(TIM+1, 0b0110); //set START and CONT bits high
	
	//Turn All Lights Off to Create Flash
	flash = 0b00000000;
	
	//Determine if User Win
	if (((user_total >= dealer_total) & (user_total <= 21)) | (dealer_total > 21)) {
		//Create "|/\|| n" Pattern
		win = 0b00110111;
		ptn = 0b00110000;
		ptn = ptn << 8;
		win = win | ptn;
		ptn = 0b00011110;
		ptn = ptn << 16;
		win = win | ptn;
		ptn = 0b00111100;
		ptn = ptn << 24;
		win = win | ptn;

		//Create Timer
		while(count <= max) {
			do {
				tOut = io_rd(TIM);
				tOut = tOut & 0b01;
			}while(tOut == 0);

			io_wr(TIM, 0);
			count++;
			//On Odd Second, Display Win
			if (count % 2 != 0) {
				io_wr(SS30, win);
			}
			//On Even Second, Flash
			else {
				io_wr(SS30, flash);
			}	
		}
		//End With No Lights Displayed
		io_wr(SS30, flash);
	}
	//Determine if User Lost
	else if ((user_total < dealer_total) & (user_total <= 21) & (dealer_total <= 21)) {
		//Create "LOSE" Pattern
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

		//Create Timer
		while(count <= max) {
			do {
				tOut = io_rd(TIM);
				tOut = tOut & 0b01;
			}while(tOut == 0);

			io_wr(TIM, 0);
			count++;
			
			//On Odd Second, Display Lose
			if (count % 2 != 0) {
				io_wr(SS30, lose);
			}
			//On Even Second, Flash
			else {
				io_wr(SS30, flash);
			}	
		}
		//End With No Lights Displayed
		io_wr(SS30, flash);
	}
}