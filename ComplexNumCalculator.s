/*
ET-344
Spring 2024
Final Project
Seth Havens, Liliana Holguin, Michael Pick
*/
#define SW  0xff200040	 //constant SW input address 
#define LED 0xff200000	 //constant LED output address 
#define SS30 0xff200020 // address of 7-segment displays 3 to 0

#define io_rd(addr) (*(volatile unsigned int *)(addr))
#define io_wr(addr, data) (*(volatile unsigned int *)(addr) = (data))
#define rd(addr) (*(unsigned int *)(addr))
#define wr(addr, data) (*(unsigned int *)(addr) = (data))

unsigned int User_Menu(void);
unsigned int User_Interaction(void);
unsigned int Dealer_Logic(unsigned int dealer_total);
unsigned int Led_Feedback(unsigned int val1);

char card_deal(unsigned int seed, unsigned int Deck[]);
unsigned int ran_gen(unsigned int seed);
char Deck_check(unsigned int card_num, unsigned int Deck[], unsigned int Deckcount);
unsigned int add_dealer_hand(char Card, unsigned int dealer_cards[]);
unsigned int add_user_hand(char Card, unsigned int user_cards[]);
unsigned int deal_arr(unsigned int seed, unsigned int Deck[], unsigned int dealer_cards[]);
unsigned int deal_arr_usr(unsigned int seed, unsigned int Deck[], unsigned int user_cards[]);

void display_win(unsigned int user_cards[], unsigned int user_total, unsigned int dealer_total);
void display_bust(unsigned int user_total);
unsigned int user_score(char user_card, unsigned int user_total);
unsigned int dealer_score(char dealer_card, unsigned int dealer_total);
void first_deal(unsigned int dealer_cards[], unsigned int user_cards[]);
void display_dealer_cards(unsigned int dealer_cards[], unsigned int user_cards[]);
void display_user_cards(unsigned int user_cards[]);

int main()						
{ 
	//Initialize Variables
	unsigned int seed;
	unsigned int count = 2;
	unsigned int dealer_choice;
	unsigned int selection;
	
	char user_card;
	char user_card1;
	char user_card2;
	
	char dealer_card;
	char dealer_card1;
	char dealer_card2;
	
	char new_line = '\n';
	
	unsigned int *mem = (unsigned int *) 0x4000;
	unsigned int *jtag = (unsigned int *) 0xff201000;
	unsigned int ctrlreg;
	unsigned int wspace;
	
	while (1){	
		
		unsigned int user_cards[5];
		//initilizing user_cards all to zero
		for(unsigned int i=0; i<5; i++){ 
			user_cards[i]=0;
		}
		//initilizing dealer cards all to zero
		unsigned int dealer_cards[5];
		for(unsigned int i=0; i<5; i++){ 
			dealer_cards[i]=0;
		}
		//initilizing deck all to zero
		unsigned int Deck[52];
		for(unsigned int i=0; i<52; i++){ 
			Deck[i]=0;
			}
		
		//Initialize User Total and Dealer Total to 0
		unsigned int user_total = 0;
		unsigned int dealer_total = 0;
		
		//Display User Menu
		seed = User_Menu();
		//calling card for dealercard1
		seed = deal_arr(seed, Deck, dealer_cards);
		//Assigns Fist Card in Dealer Card Array to Dealer Card 1
		dealer_card1 = dealer_cards[0];
		//Assigns Dealer Card 1 to Dealer Card
		dealer_card = dealer_card1;
		//Store Dealer Card 1 to Memory
		wr(mem, dealer_card1);
		//Gets Dealer Total
		dealer_total = dealer_score(dealer_card, dealer_total);
		//Store Dealer Total to Memory
		wr(mem+10, dealer_total);
		
		//calling card for dealercard2
		seed = deal_arr(seed, Deck, dealer_cards);
		//Assigns Second Card in Dealer Card Array to Dealer Card 2
		dealer_card2 = dealer_cards[1];
		//Assigns Dealer Card 2 to Dealer Card
		dealer_card = dealer_card2;
		//Store Dealer Card 2 to Memory
		wr(mem+1, dealer_card2);
		//Gets Dealer Total
		dealer_total = dealer_score(dealer_card, dealer_total);
		//Store Dealer Total to Memory
		wr(mem+10, dealer_total);
		
		//calling card for playercard1
		seed = deal_arr_usr(seed, Deck, user_cards);
		//Assigns Fist Card in User Card Array to User Card 1
		user_card1 = user_cards[0];
		//Assigns User Card 1 to User Card
		user_card = user_card1;
		//Store User Card 1 to Memory
		wr(mem+5, user_card1);
		//Gets User Total
		user_total = user_score(user_card, user_total);
		//Store User Total to Memory
		wr(mem+11, user_total);

		//calling card for playercard2
		seed = deal_arr_usr(seed, Deck, user_cards);
		//Assigns Second Card in User Card Array to User Card 2
		user_card2 = user_cards[1];
		//Assigns User Card 2 to User Card
		user_card = user_card2;
		//Store User Card 2 to Memory
		wr(mem+6, user_card2);
		//Gets User Total
		user_total = user_score(user_card, user_total);
		//Store User Total to Memory
		wr(mem+11, user_total);
		
		//Writes User Total to LEDs
		selection = Led_Feedback(user_total);
		io_wr(LED, selection);
		
		//Displays Dealer and User First Card to JTAG
		first_deal(dealer_cards, user_cards);
		
		do{
			seed = User_Interaction();
			//if zero dont get new num and get out 
			if (seed == 0) {
				break;
			}
			else {
				seed = deal_arr_usr(seed, Deck, user_cards);
				user_card = user_cards[count];
				//Store Next User Card to Memory
				wr(mem+(count + 5), user_card);
				display_user_cards(user_cards);
				user_total = user_score(user_card, user_total);
				//Store User Total to Memory
				wr(mem+11, user_total);
				selection = Led_Feedback(user_total);
				io_wr(LED, selection);
				//Determine If User Bust
				if (user_total >= 22) {
					display_bust(user_total);
					break;
				}
				count+=1;
			}
		}while((seed>0) && (count <= 5));

		count = 2;
		do{
			//If User Bust, Break
			if (user_total >= 22) {
					display_bust(user_total);
					break;
			}
			else {
				dealer_choice = Dealer_Logic(dealer_total); 
				if (dealer_choice == 1) {
					seed = deal_arr(seed, Deck, dealer_cards);
					dealer_card = dealer_cards[count];
					//Store Next Dealer Card to Memory
					wr(mem+count, dealer_card);
					dealer_total = dealer_score(dealer_card, dealer_total);
					//Store User Total to Memory
					wr(mem+10, dealer_total);
					count += 1;
				}
				else if (dealer_choice == 0) {
					break;
				}
				else {
					break;
				}

			}
		} while(dealer_choice == 1);
		
		//Display Dealer and User Cards to JTAG
		display_dealer_cards(dealer_cards, user_cards);
		//Display Win Status of User to JTAG
		display_win(user_cards, user_total, dealer_total);
		
		//Prints New Line to JTAG
		do {
				ctrlreg = io_rd(jtag+1);
				wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, new_line);

	}
	return 0;	
}
// User_Menu block – block that displays menu for user and waits for user to start game
// Input: none
// Output: random value
//Author/date: Seth Havens 05/8/24
unsigned int User_Menu(void) {
	unsigned int *jtag = (unsigned int *)0xff201000; // Pointer to JTAG
	unsigned int ctrlreg; // Control register
	unsigned int wspace; // Write FIFO space
	unsigned int pbFlag;
	unsigned int *PB = (unsigned int *)0xff200050; // PB pointer
	io_wr(PB + 2, 0b01); // Enable PB interrupt bit0 (CPUlator)
	unsigned int val;

    char msg[] = "\nWelcome to BlackJack\n(c)opywrite: Seth Havens, Michael Pick, Liliana Holguin\n\nHow to play:\nHIT = PushButton 1\nSTAND = PushButton 0\n\nTo start hit any PushButton\n"; // Message to be printed

    // Print the message
    for (int i = 0; msg[i] != '\0'; i++) {
        do {
            ctrlreg = io_rd(jtag + 1); // Read JTAG control register
            wspace = ctrlreg >> 16;     // Shift to get WSPACE
        } while (wspace == 0); // If no write space, loop back
        io_wr(jtag, msg[i]);   // Write character to JTAG
    }

    // Wait for pushbutton press and output value accordingly
    unsigned int r=1; 	//initailize intager holing random value r
	do {
		r++;		//increment r by 1
		if(r>52)		//if r is greater than 52 set back to 1
			r=1;
        pbFlag = io_rd(PB + 3) & 0b11; // Check if PB was pressed
        if (pbFlag == 1) {              // If PB0 is pressed
            val = 2;

            io_wr(PB + 3, 0b01); // Clear edge-capture bit 0 flag
        } else if (pbFlag == 2) {      // If PB1 is pressed
            val = 1;

            io_wr(PB + 3, 0b10); // Clear edge-capture bit 1 flag
        }
    } while (pbFlag != 1 && pbFlag != 2); // Continue until either PB0 or PB1 is pressed
//if statement to start game
	if(val == 1)		//if val=1 then return random number
		return r;
	else if(val == 2)		//if val=0 then return random number
		return r;
		

}
// User_Interaction block – block that displays and gives the user the option to choose to HIT or STAND
// Input: none
// Output: random value or 0
//Author/date: Seth Havens 05/8/24
unsigned int User_Interaction(void) {
    unsigned int *jtag = (unsigned int *)0xff201000; // Pointer to JTAG
    unsigned int ctrlreg; // Control register
    unsigned int wspace; // Write FIFO space
    unsigned int pbFlag;
    unsigned int *PB = (unsigned int *)0xff200050; // PB pointer
    io_wr(PB + 2, 0b01); // Enable PB interrupt bit0 (CPUlator)
    unsigned int val;

    char msg[] = "\nWhat do you want to do\n\nHIT = PushButton 1\nSTAND = PushButton 0\n"; // Message to be printed

    // Print the message
    for (int i = 0; msg[i] != '\0'; i++) {
        do {
            ctrlreg = io_rd(jtag + 1); // Read JTAG control register
            wspace = ctrlreg >> 16;     // Shift to get WSPACE
        } while (wspace == 0); // If no write space, loop back
        io_wr(jtag, msg[i]);   // Write character to JTAG
    }

    // Wait for pushbutton press and output value accordingly
    unsigned int r=1; 	//initailize intager holing random value r
	do {
		r++;		//increment r by 1
		if(r>52)		//if r is greater than 52 set back to 1
			r=1;
        pbFlag = io_rd(PB + 3) & 0b11; // Check if PB was pressed
        if (pbFlag == 1) {              // If PB0 is pressed
            val = 2;
            //io_wr(LED, val); // Output 1
            io_wr(PB + 3, 0b01); // Clear edge-capture bit 0 flag
        } else if (pbFlag == 2) {      // If PB1 is pressed
            val = 1;
            //io_wr(LED, val); // Output 0
            io_wr(PB + 3, 0b10); // Clear edge-capture bit 1 flag
        }
    } while (pbFlag != 1 && pbFlag != 2); // Continue until either PB0 or PB1 is pressed
//if statement 
	if(val == 1)		//if val=1 then return random number meaning player choose to HIT
		return r;
	else if (val == 2)		//if val=0 then return 0 meaning player choose to STAND
		return 0;
		
}
// Dealer_Logic block – block that figures out if the dealer can HIT/STAND/BUST
// Input: dealer total
// Output: HIT/STAND/dealer total
//Author/date: Seth Havens 05/8/24
unsigned int Dealer_Logic(unsigned int val1) {

//if statement 
	if(val1<17)		//if val=1 then return random number meaning dealer gets to HIT
		return 1;
	else if((17>=val1) && (val1<=21))		//if val=0 then return 0 meaning dealer STAND
		return 0;
	else if(val1>21);		// if val is greater than 21 dealer busted 
		return val1;
		
}
// Led_Feedback block – block that displays user total on LEDS
// Input: User total
// Output: LED pattern
//Author/date: Seth Havens 05/8/24
unsigned int Led_Feedback(unsigned int val1){
	unsigned int ptn;
	switch(val1) {
		case 0:		//User score 0
			ptn = 0b0000000000000000000000000000000; break;
		case 1:		//User score 1
			ptn = 0b0000000000000000000000000000001; break;
		case 2:		//User score 2
			ptn = 0b0000000000000000000000000000011; break;
		case 3:		//User score 3
			ptn = 0b0000000000000000000000000000111; break;
		case 4:		//User score 4
			ptn = 0b0000000000000000000000000001111; break;
		case 5:		//User score 5
			ptn = 0b0000000000000000000000000011111; break;
		case 6:		//User score 6
			ptn = 0b0000000000000000000000000111111; break;
		case 7:		//User score 7
			ptn = 0b0000000000000000000000001111111; break;
		case 8:		//User score 8
			ptn = 0b0000000000000000000000011111111; break;
		case 9:		//User score 9
			ptn = 0b0000000000000000000000111111111; break;
		case 10:		//User score 10
			ptn = 0b0000000000000000000001111111111; break;
		case 11:		//User score 11
			ptn = 0b0000000000000000000011111111111; break;
		case 12:		//User score 12
			ptn = 0b0000000000000000000111111111111; break;
		case 13:		//User score 13
			ptn = 0b0000000000000000001111111111111; break;
		case 14:		//User score 14
			ptn = 0b0000000000000000011111111111111; break;
		case 15:		//User score 15
			ptn = 0b0000000000000000111111111111111; break;
		case 16:		//User score 16
			ptn = 0b0000000000000001111111111111111; break;
		case 17:		//User score 17
			ptn = 0b0000000000000011111111111111111; break;
		case 18:		//User score 18
			ptn = 0b0000000000000111111111111111111; break;
		case 19:		//User score 19
			ptn = 0b0000000000001111111111111111111; break;
		case 20:		//User score 20
			ptn = 0b0000000000011111111111111111111; break;
		case 21:		//User score 21
			ptn = 0b0000000000111111111111111111111; break;
		case 22:		//User score 22
			ptn = 0b0000000001111111111111111111111; break;
		case 23:		//User score 23
			ptn = 0b0000000011111111111111111111111; break;
		case 24:		//User score 24
			ptn = 0b000000011111111111111111111111; break;
		case 25:		//User score 25
			ptn = 0b0000001111111111111111111111111; break;
		case 26:		//User score 26
			ptn = 0b0000011111111111111111111111111; break;
		case 27:		//User score 27
			ptn = 0b0000111111111111111111111111111; break;
		case 28:		//User score 28
			ptn = 0b0001111111111111111111111111111; break;
		case 29:		//User score 29
			ptn = 0b0011111111111111111111111111111; break;
		case 30:		//User score 30
			ptn = 0b0111111111111111111111111111111; break;
		case 31:		//User score 31
			ptn = 0b1111111111111111111111111111111; break;
		default:		//User score error
			ptn = 0b0101010101010101010101010101010; 
	}
	return ptn;
}

char Deck_check(unsigned int card_num, unsigned int Deck[], unsigned int Deckcount){
	
	unsigned int ptn;
	
	for (unsigned int i = 0; i < 52; i++) {
        if (Deck[i] == card_num) {
			card_num++; // change the card num if it is found in list
			i = 0; //go back to zero to check whole list again
			}
		if(card_num >= 53){
				card_num = 1; //error prevention to see if the card is above the set Deck valuee
				i = 0; //go back to zero to check whole list again
			}
		}
	Deck[Deckcount] = card_num;
	
	
		switch(card_num) 
			{
			case 1:
				ptn = 'A'; break;
			case 2:
				ptn = '2'; break;
			case 3:
				ptn = '3'; break;
			case 4:
				ptn = '4'; break;
			case 5:
				ptn = '5'; break;
			case 6:
				ptn = '6'; break;
			case 7:
				ptn = '7'; break;
			case 8:
				ptn = '8'; break;
			case 9:
				ptn = '9'; break;
			case 10:
				ptn = 't'; break;
			case 11:
				ptn = 'J'; break;
			case 12:
				ptn = 'Q'; break;
			case 13:
				ptn = 'K'; break;
			case 14:
				ptn = 'A'; break;
			case 15:
				ptn = '2'; break;
			case 16:
				ptn = '3'; break;	
			case 17:
				ptn = '4'; break;
			case 18:
				ptn = '5'; break;
			case 19:
				ptn = '6'; break;
			case 20:
				ptn = '7'; break;
			case 21:
				ptn = '8'; break;
			case 22:
				ptn = '9'; break;
			case 23:
				ptn = 't'; break;
			case 24:
				ptn = 'J'; break;
			case 25:
				ptn = 'Q'; break;
			case 26:
				ptn = 'K'; break;
			case 27:
				ptn = 'A'; break;
			case 28:
				ptn = '2'; break;
			case 29:
				ptn = '3'; break;
			case 30:
				ptn = '4'; break;
			case 31:
				ptn = '5'; break;
			case 32:
				ptn = '6'; break;
			case 33:
				ptn = '7'; break;
			case 34:
				ptn = '8'; break;
			case 35:
				ptn = '9'; break;
			case 36:
				ptn = 't'; break;
			case 37:
				ptn = 'J'; break;
			case 38:
				ptn = 'Q'; break;
			case 39:
				ptn = 'K'; break;
			case 40:
				ptn = 'A'; break;
			case 41:
				ptn = '2'; break;
			case 42:
				ptn = '3'; break;
			case 43:
				ptn = '4'; break;
			case 44:
				ptn = '5'; break;
			case 45:
				ptn = '6'; break;
			case 46:
				ptn = '7'; break;
			case 47:
				ptn = '8'; break;
			case 48:
				ptn = '9'; break;
			case 49:
				ptn = 't'; break;
			case 50:
				ptn = 'J'; break;
			case 51:
				ptn = 'Q'; break;
			case 52:
				ptn = 'K'; break;
			
			default:
				ptn = 'N'; //ERROR
			}
		return ptn;
	}



unsigned int ran_gen(unsigned int seed) {
    // Parameters for the LCG
    unsigned int card_num;
    card_num = (seed*151)%313;

    return card_num;
}





char card_deal(unsigned int seed, unsigned int Deck[]){
	unsigned int Deckcount = 0;
	char Card;
	
	
	// checking if this is taken and if so increment, (DECK CHECK)
	for(unsigned int i = 0; i<52; i++){
		if (Deck[i] != 0){
				 Deckcount+=1;
		}
		}

	Card = Deck_check(seed, Deck, Deckcount);
	
	
	return Card;
	
}
	
unsigned int add_dealer_hand(char Card, unsigned int dealer_cards[]){
	unsigned int Deckcount = 0;
	
	//initilizing deck count to see how many items there are in someones cards, then we will
	//use this to append the card into someones cards
	for(unsigned int i = 0; i<5; i++){
		if (dealer_cards[i] != 0){
			Deckcount+=1;
		}
		}
	dealer_cards[Deckcount] = Card;
	return Deckcount;

}
	
unsigned int add_user_hand(char Card, unsigned int user_cards[]){
	unsigned int Deckcount = 0;
	
	//initilizing deck count to see how many items there are in someones cards, then we will
	//use this to append the card into someones cards
	for(unsigned int i = 0; i<5; i++){
		if (user_cards[i] != 0){
			Deckcount+=1;
		}
		}
	user_cards[Deckcount] = Card;
	return Deckcount;
}
unsigned int deal_arr(unsigned int seed, unsigned int Deck[], unsigned int dealer_cards[]){
	
	
		unsigned int rand_num;
		char Card;
	
		rand_num = ran_gen(seed);	
		seed = (rand_num%52)+1;
		
		Card = card_deal(seed, Deck);
	
		add_dealer_hand(Card, dealer_cards);	
	
	
	
	return seed;
}

unsigned int deal_arr_usr(unsigned int seed, unsigned int Deck[], unsigned int user_cards[]){
	
	
		unsigned int rand_num;
		char Card;
	
		rand_num = ran_gen(seed);	
		seed = (rand_num%52)+1;
		
		Card = card_deal(seed, Deck);
	
		add_user_hand(Card, user_cards);	
	
	
	return seed;
}

unsigned int user_score(char user_card, unsigned int user_total) {
	
	////Switch Statement to Assign User Card a Value and Update User Total
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

	return user_total;
}

unsigned int dealer_score(char dealer_card, unsigned int dealer_total){
	//Switch Statement to Assign Dealer Card a Value and Update User Total
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
	return dealer_total;
}

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

void first_deal (unsigned int dealer_cards[], unsigned int user_cards[]) {
	//Initialize Variables
	unsigned int *jtag = (unsigned int *) 0xff201000;
	
	unsigned int ctrlreg;
	unsigned int wspace;
	
	char dealer_card_msg [] = "\nDealer Cards: ";
	char user_card_msg[] = "\nUser Cards: ";
	
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

void display_user_cards (unsigned int user_cards[]) {
	//Initialize Variables
	unsigned int *jtag = (unsigned int *) 0xff201000;
	
	unsigned int ctrlreg;
	unsigned int wspace;
	char user_card_msg[] = "\nUser Cards: ";
	unsigned int i;
	
	//Display User Card
	i = 0; 
	while(user_card_msg[i] != '\0') { 
		do {
			ctrlreg = io_rd(jtag+1);
			wspace = ctrlreg >> 16;
		} while (wspace == 0);
		io_wr(jtag, user_card_msg[i]);
		i++;
	}
	
	//Prints All User Cards
	i = 0;
	while (i < 5) {
		if (user_cards[i] != 0) {
			do {
				ctrlreg = io_rd(jtag+1);
				wspace = ctrlreg >> 16;
			} while (wspace == 0);
			io_wr(jtag, user_cards[i]);
		}
		else {
			break;
		}
		i++;
	}
		
}

void display_dealer_cards (unsigned int dealer_cards[], unsigned int user_cards[]) {
	//Initialize Variables
	unsigned int *jtag = (unsigned int *) 0xff201000;
	
	unsigned int ctrlreg;
	unsigned int wspace;
	
	char dealer_card_msg [] = "\nDealer Cards: ";
	char user_card_msg[] = "\nUser Cards: ";
	
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