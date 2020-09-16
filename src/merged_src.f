
: ':' [ CHAR : ] LITERAL ;
: ';' [ CHAR ; ] LITERAL ;
: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: '.' [ CHAR . ] LITERAL ;

: ( IMMEDIATE 1 BEGIN KEY DUP '(' = IF DROP 1+ ELSE ')' = IF 1- THEN THEN DUP 0= UNTIL DROP ;
: SPACES BEGIN DUP 0> WHILE SPACE 1- REPEAT DROP ;
: WITHIN -ROT OVER <= IF > IF TRUE ELSE FALSE THEN ELSE 2DROP FALSE THEN ;
: ALIGNED 3 + 3 INVERT AND ;
: ALIGN HERE @ ALIGNED HERE ! ;
: C, HERE @ C! 1 HERE +! ;
: S" IMMEDIATE ( -- addr len )
	STATE @ IF
		' LITS , HERE @ 0 ,
		BEGIN KEY DUP '"'
                <> WHILE C, REPEAT
		DROP DUP HERE @ SWAP - 4- SWAP ! ALIGN
	ELSE
		HERE @
		BEGIN KEY DUP '"'
                <> WHILE OVER C! 1+ REPEAT
		DROP HERE @ - HERE @ SWAP
	THEN
;

: ." IMMEDIATE ( -- )
	STATE @ IF
		[COMPILE] S" ' TELL ,
	ELSE
		BEGIN KEY DUP '"' = IF DROP EXIT THEN EMIT AGAIN
	THEN
;


: JF-HERE   HERE ;
: JF-CREATE   CREATE ;
: JF-FIND   FIND ;
: JF-WORD   WORD ;

: HERE   JF-HERE @ ;
: ALLOT   HERE + JF-HERE ! ;

: [']   ' LIT , ; IMMEDIATE
: '   JF-WORD JF-FIND >CFA ;

: CELL+  4 + ;

: ALIGNED   3 + 3 INVERT AND ;
: ALIGN JF-HERE @ ALIGNED JF-HERE ! ;

: DOES>CUT   LATEST @ >CFA @ DUP JF-HERE @ > IF JF-HERE ! ;

: CREATE   JF-WORD JF-CREATE DOCREATE , ;
: (DODOES-INT)  ALIGN JF-HERE @ LATEST @ >CFA ! DODOES> ['] LIT ,  LATEST @ >DFA , ;
: (DODOES-COMP)  (DODOES-INT) ['] LIT , , ['] FIP! , ;
: DOES>COMP   ['] LIT , HERE 3 CELLS + , ['] (DODOES-COMP) , ['] EXIT , ;
: DOES>INT   (DODOES-INT) LATEST @ HIDDEN ] ;
: DOES>   STATE @ 0= IF DOES>INT ELSE DOES>COMP THEN ; IMMEDIATE

DROP

HEX
\***CONSTANT***\
FE200000 CONSTANT GPIO_BASE
GPIO_BASE 1400 + CONSTANT UART2
2DC6C00 CONSTANT CLOCK
\***VARIABLE***\
VARIABLE TIMEOUT
VARIABLE BAUD
VARIABLE CLOCKDIV
9600 BAUD !
\***GPIO***\
: GPIO ( value -- ) GPIO_BASE + CONSTANT ;
0  GPIO GPFSEL0
1C GPIO GPSET0
28 GPIO GPCLR0
94 GPIO GPPUD
98 GPIO GPPUDCLK0
\***REGISTRES ADDRESS***\
: ADDR{ ( address -- ) ;
: ADDR ( address -- address )  DUP CONSTANT 4 + ;
: }ADDR  ( addr -- ) DROP ;
UART2 ADDR{ 				
	ADDR DR 		\ 4  Data Register
	ADDR RSRECR 	\ 8
	ADDR SKIP  		\ C
	ADDR SKIP 		\ 10
	ADDR SKIP 		\ 14
	ADDR SKIP 		\ 18	
	ADDR FR 		\ 1C Flag Register
	ADDR SKIP 		\ 20
	ADDR SKIP 		\ 24
	ADDR IBRD 		\ 28 Integer Baud Rate Divisor
	ADDR FBRD 		\ 2C Fractional Baud Rate Divisor
	ADDR LCRH 		\ 30 Line Control Register
	ADDR CREG 		\ 34 Control Register
	ADDR IFLS 		\ 38 Interrupt FIFO Level Select Register
	ADDR IMSC 		\ 3C Interrupt Mask Set Clear Register
	ADDR RIS 		\ 40 Row Interrupt Status Register
	ADDR SKIP 		\ 44 Masked Interrupt Status Register
	ADDR ICR 		\ 48 Interrupt Clear Register
	ADDR DMACR 		\ 4C DMA Control Register
	34 + 			\ 80
	ADDR ITCR 		\ 84 Test Control Register
	ADDR ITIP 		\ 88 Integration Test Input Register
	ADDR ITOP 		\ 8C Integration test output register
	ADDR TDR 		\ 90 Test data register
}ADDR
\***UTILITY***\
: SPIN ( -- ) 
	0 BEGIN 
		1 1+ DROP 1+ DUP 
	96 = UNTIL DROP ;
: 6BITMASK ( value -- valuewith6bit ) SWAP 3F INVERT AND ;
: FETCH_AND ( reg_addr and_value -- result ) SWAP @ AND ;
\***INITIALIZE***\
: INIT ( -- )
	CLOCK 4 * BAUD @ / CLOCKDIV ! 
	GPFSEL0 @ 6BITMASK 1B OR GPFSEL0 ! 
	0 GPPUD ! 
	SPIN C000 GPPUDCLK0 ! SPIN 
	0 GPPUDCLK0 ! 
	7FF ICR ! 
	1 IBRD ! 
	28 FBRD ! 
	CLOCKDIV @ FFFFFFC0 AND 6 RSHIFT IBRD ! 
	CLOCKDIV @ 3F AND FBRD ! 
	70 LCRH ! 
	301 CREG ! ; 
\***BAUD SETTING***\
: CHANGEBAUD ( value -- ) BAUD ! INIT ;
\***COMMUNICATION FUNCTION***\
: SERIAL_IN_READY ( -- flag ) FR 10 FETCH_AND ; 
: SERIAL_IN ( -- read_byte ) DR FF FETCH_AND ;
: SERIAL_OUT_READY ( -- flag ) FR 20 FETCH_AND ;
: SERIAL_OUT ( write_byte --  ) DR ! ; 
: SERIAL_WRITE  ( n -- n ) 
	BEGIN 
		SERIAL_OUT_READY 
	0= UNTIL SERIAL_OUT ;
: SERIAL_READ ( -- n ) 
	0 TIMEOUT ! BEGIN 
		TIMEOUT @ 1+ DUP TIMEOUT ! 
		C350 = IF 
			-1 EXIT 
		THEN SERIAL_IN_READY 
	0= UNTIL SERIAL_IN ;

HEX
\***COLOR CONSTANT***\
0 CONSTANT BLACK
FF CONSTANT BLUE
FF00 CONSTANT GREEN
FF0000 CONSTANT RED
FFFFFF CONSTANT WHITE
FF751A CONSTANT ORANGE
\***CONSTANT***\
4 CONSTANT PIXEL_SIZE
1000 CONSTANT ROW_SIZE
E CONSTANT CHAR_SIZE
12 CONSTANT LINE_SIZE
10 CONSTANT SPACE_SIZE
400 CONSTANT SCREEN_WIDTH
300 CONSTANT SCREEN_HEIGHT
10 CONSTANT BAR_HEIGHT
179 CONSTANT BAR_WIDTH
120 CONSTANT IMG_HEIGHT
100 CONSTANT IMG_WIDTH
\***POSITION CONSTANT***\
3E8FA000 CONSTANT FRAMEBUFFER
3EB5071C CONSTANT RESULT_POSITION
3EA62000 CONSTANT INDICATIONS_POSITION
3E942000 CONSTANT MENU_POSITION
3EB1A508 CONSTANT PROGRESS_LINE_POSITION
3E9EA600 CONSTANT IMAGE_POSITION
3EB625D4 CONSTANT MESSAGE_POSITION
\***VARIABLE***\
VARIABLE PROGRESS_LINE_CURRENT
\***UTILITY***\
: TAKE_TIMES ( -- ) 0 BEGIN 1 1+ DROP 1+ DUP F000 = UNTIL DROP ;
: DROP4 ( d c b a -- c b a ) >R >R NIP R> R> ;
\***PIXEL MANIPULATION***\
: PD ( buffer n -- buffer+n*1000 ) ROW_SIZE * + ;
: PR ( buffer n -- buffer+n*4 ) PIXEL_SIZE * + ;
: PU ( buffer n -- buffer+n*1000 ) ROW_SIZE * - ;
: PL ( buffer n -- buffer+n*4 ) PIXEL_SIZE * - ;
: NEXT_CHAR ( buffer -- buffer+4*3 ) PIXEL_SIZE 3 * + ;
: NEXT_LINE ( buffer -- buffer+1000*12 ) ROW_SIZE LINE_SIZE * + ;
: MULTIPLE_LINE ( buffer n -- buffer+1000*12*n ) LINE_SIZE ROW_SIZE * * + ;
: NEW_LINE ( buffer color -- buffernew buffernew color ) SWAP NEXT_LINE DUP ROT ;
: CHAR_SPACE ( buffer -- buffer+4*3 )  SWAP PIXEL_SIZE SPACE_SIZE * + SWAP ;
: WORDS_LENGTH ( nchar -- pixelsize ) DUP CHAR_SIZE * SWAP 1- 3 * + ;
\***DRAW FUNCTIONS***\
: PX_ON ( buffer color -- ) SWAP ! ;
: HOR_LINE ( bufferpos size color -- ) -ROT SWAP 0 BEGIN 2DUP PR 4 PICK PX_ON 1+ DUP 3 PICK = UNTIL 2DROP 2DROP ;
: VERT_LINE ( bufferpos size color -- ) -ROT SWAP 0 BEGIN 2DUP PD 4 PICK PX_ON 1+ DUP 3 PICK = UNTIL 2DROP 2DROP ;
: DRAW_RECTANGLE ( buffer width height color -- ) SWAP >R -ROT R> ROT 0 BEGIN 2DUP PD 4 PICK 6 PICK HOR_LINE 1+ DUP 3 PICK = UNTIL DROP 2DROP 2DROP ;
: SCREEN_BLACK ( -- ) FRAMEBUFFER SCREEN_WIDTH SCREEN_HEIGHT BLACK DRAW_RECTANGLE ;
\***PROGRESS BAR FUNCTION***\
: LOADING_BAR ( -- )
	PROGRESS_LINE_POSITION 1 PR 1 PD PROGRESS_LINE_CURRENT !
    PROGRESS_LINE_POSITION BAR_WIDTH WHITE HOR_LINE
    PROGRESS_LINE_POSITION BAR_HEIGHT WHITE VERT_LINE
    PROGRESS_LINE_POSITION ROW_SIZE BAR_HEIGHT 1- * + BAR_WIDTH WHITE HOR_LINE
    PROGRESS_LINE_POSITION PIXEL_SIZE BAR_WIDTH 1- * + BAR_HEIGHT WHITE VERT_LINE ;
: NEXT_PROGRESS ( -- ) PROGRESS_LINE_CURRENT @ BAR_HEIGHT 1- WHITE VERT_LINE PIXEL_SIZE PROGRESS_LINE_CURRENT +! ;
: RESTORE_PROGRESS_BAR ( -- ) PROGRESS_LINE_POSITION 1 PR 1 PD 0 BEGIN 2DUP PD BAR_WIDTH 2- BLACK HOR_LINE 1+ DUP BAR_HEIGHT 2- = UNTIL 2DROP ;
\***IMAGE WINDOW FUNCTION***\
: IMAGE_WINDOW ( -- )
    IMAGE_POSITION 4 PL 4 PU DUP 2DUP 
    IMG_WIDTH 8 + WHITE HOR_LINE
    IMG_HEIGHT 7 + WHITE VERT_LINE
    IMG_HEIGHT 7 + PD IMG_WIDTH 8 + WHITE HOR_LINE
    IMG_WIDTH 7 + PR IMG_HEIGHT 7 + WHITE VERT_LINE ;
\***CLEAR FUNCTIONS***\
: CLR_WORDS ( buffer nchar --  ) WORDS_LENGTH CHAR_SIZE 2 + BLACK DRAW_RECTANGLE ;
: CLR_RESULT ( -- ) RESULT_POSITION B CLR_WORDS ;
: CLR_MENU ( -- ) MENU_POSITION 0 BEGIN SWAP DUP 1C CLR_WORDS NEXT_LINE SWAP 1+ DUP 6 = UNTIL 2DROP ;
: CLR_CHOICE ( -- ) MENU_POSITION DUP 2F CLR_WORDS NEXT_LINE NEXT_LINE DUP 1E CLR_WORDS NEXT_LINE 1B CLR_WORDS ;
: CLR_PIJ ( -- ) FRAMEBUFFER 3 PR BB 20 BLACK DRAW_RECTANGLE ;
: CLR_INDICATIONS ( -- ) INDICATIONS_POSITION DUP F CLR_WORDS NEXT_LINE E CLR_WORDS ;
: CLR_MESSAGE ( -- ) MESSAGE_POSITION 17 CLR_WORDS ;
: CLR_IMAGE ( -- ) IMAGE_POSITION 4 PL 4 PU 0 BEGIN 2DUP PR IMG_HEIGHT 8 + BLACK VERT_LINE 1+ DUP IMG_WIDTH 8 + = UNTIL 2DROP ; 
: CLR_PROGRESS_BAR ( -- ) PROGRESS_LINE_POSITION 0 BEGIN 2DUP PD BAR_WIDTH BLACK HOR_LINE 1+ DUP BAR_HEIGHT = UNTIL 2DROP ; 
\***LETTERS***\
: C_A ( buffer color -- buffer color ) SWAP
    DUP 2 PD C 3 PICK VERT_LINE       1 PR
    DUP 1 PD D 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 5 3 PICK VERT_LINE
    DUP 7 PD 4 3 PICK VERT_LINE       1 PR
    DUP 4 3 PICK VERT_LINE
    DUP 7 PD 4 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 7 PD 4 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP 7 PD 4 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP 7 PD 4 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 7 PD 4 3 PICK VERT_LINE       1 PR
    DUP 4 3 PICK VERT_LINE
    DUP 7 PD 4 3 PICK VERT_LINE       1 PR
    DUP 5 3 PICK VERT_LINE
    DUP 7 PD 4 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 1 PD D 3 PICK VERT_LINE       1 PR
    DUP 2 PD C 3 PICK VERT_LINE       1 PR
    NEXT_CHAR SWAP ;
: C_B ( buffer color -- buffer color ) SWAP 
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 2 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 5 PD 4 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 1 PD C 3 PICK VERT_LINE       1 PR
    DUP 2 PD 4 3 PICK VERT_LINE 
    DUP 8 PD 4 3 PICK VERT_LINE       1 PR
    NEXT_CHAR SWAP ;
: C_C ( buffer color -- buffer color ) SWAP 
    DUP 4 PD 6 3 PICK VERT_LINE       1 PR
    DUP 1 PD C 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 4 3 PICK VERT_LINE
    DUP A PD 4 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 4 3 PICK VERT_LINE
    DUP A PD 4 3 PICK VERT_LINE       1 PR
    DUP 4 3 PICK VERT_LINE
    DUP A PD 4 3 PICK VERT_LINE       1 PR
    DUP 4 3 PICK VERT_LINE
    DUP A PD 4 3 PICK VERT_LINE       1 PR
    NEXT_CHAR SWAP ;
: C_D ( buffer color -- buffer color ) SWAP 
    DUP 3 3 PICK VERT_LINE                    
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE                    
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 4 3 PICK VERT_LINE
    DUP A PD 4 3 PICK VERT_LINE       1 PR
    DUP 5 3 PICK VERT_LINE
    DUP 9 PD 5 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 1 PD C 3 PICK VERT_LINE       1 PR
    DUP 2 PD A 3 PICK VERT_LINE       1 PR
    NEXT_CHAR SWAP ;
: C_E ( buffer color -- buffer color ) SWAP 
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE     
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE     
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE     
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE     
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE     
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR    
    NEXT_CHAR SWAP ;
: C_F ( buffer color -- buffer color ) SWAP 
    DUP 1 PD D 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE    
    DUP 6 PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE            1 PR
    DUP 3 3 PICK VERT_LINE            1 PR
    DUP 3 3 PICK VERT_LINE            1 PR    
    NEXT_CHAR SWAP ;
: C_G ( buffer color -- buffer color ) SWAP 
    DUP 2 PD A 3 PICK VERT_LINE       1 PR
    DUP 1 PD C 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 5 3 PICK VERT_LINE
    DUP 9 PD 5 3 PICK VERT_LINE       1 PR
    DUP 4 3 PICK VERT_LINE
    DUP A PD 4 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 7 PD 2 3 PICK VERT_LINE     
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 7 PD 2 3 PICK VERT_LINE     
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 5 3 PICK VERT_LINE
    DUP 7 PD 7 3 PICK VERT_LINE       1 PR
    DUP 5 3 PICK VERT_LINE
    DUP 7 PD 7 3 PICK VERT_LINE       1 PR
    DUP 1 PD 4 3 PICK VERT_LINE
    DUP 7 PD 6 3 PICK VERT_LINE       1 PR
    DUP 2 PD 3 3 PICK VERT_LINE
    DUP 7 PD 5 3 PICK VERT_LINE       1 PR
    NEXT_CHAR SWAP ;
: C_H ( buffer color -- buffer color ) SWAP 
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 5 PD 4 3 PICK VERT_LINE       1 PR
    DUP 5 PD 4 3 PICK VERT_LINE       1 PR
    DUP 5 PD 4 3 PICK VERT_LINE       1 PR
    DUP 5 PD 4 3 PICK VERT_LINE       1 PR
    DUP 5 PD 4 3 PICK VERT_LINE       1 PR
    DUP 5 PD 4 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    NEXT_CHAR SWAP ;
: C_I ( buffer color -- buffer color ) SWAP 
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    NEXT_CHAR SWAP ;
: C_J ( buffer color -- buffer color ) SWAP 
    DUP 3 3 PICK VERT_LINE
    DUP 8 PD 4 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 8 PD 5 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 8 PD 6 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP A PD 4 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP D 3 PICK VERT_LINE            1 PR
    DUP C 3 PICK VERT_LINE            1 PR
    DUP 3 3 PICK VERT_LINE            1 PR
    DUP 3 3 PICK VERT_LINE            1 PR
    DUP 3 3 PICK VERT_LINE            1 PR
    NEXT_CHAR SWAP ;
: C_K ( buffer color -- buffer color ) SWAP 
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 5 PD 4 3 PICK VERT_LINE       1 PR
    DUP 4 PD 6 3 PICK VERT_LINE       1 PR
    DUP 3 PD 8 3 PICK VERT_LINE       1 PR
    DUP 2 PD A 3 PICK VERT_LINE       1 PR
    DUP 1 PD C 3 PICK VERT_LINE       1 PR
    DUP 6 3 PICK VERT_LINE
    DUP 8 PD 6 3 PICK VERT_LINE       1 PR
    DUP 5 3 PICK VERT_LINE
    DUP 9 PD 5 3 PICK VERT_LINE       1 PR
    DUP 4 3 PICK VERT_LINE
    DUP A PD 4 3 PICK VERT_LINE       1 PR  
    DUP 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE       1 PR  
    DUP 2 3 PICK VERT_LINE
    DUP C PD 2 3 PICK VERT_LINE       1 PR    
    NEXT_CHAR SWAP ;
: C_L ( buffer color -- buffer color ) SWAP 
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP B PD 3 3 PICK VERT_LINE       1 PR
    DUP B PD 3 3 PICK VERT_LINE       1 PR   
    NEXT_CHAR SWAP ;
: C_M ( buffer color -- buffer color ) SWAP 
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 1 PD 5 3 PICK VERT_LINE       1 PR
    DUP 2 PD 5 3 PICK VERT_LINE       1 PR
    DUP 3 PD 5 3 PICK VERT_LINE       1 PR
    DUP 4 PD 5 3 PICK VERT_LINE       1 PR
    DUP 4 PD 5 3 PICK VERT_LINE       1 PR
    DUP 3 PD 5 3 PICK VERT_LINE       1 PR
    DUP 2 PD 5 3 PICK VERT_LINE       1 PR
    DUP 1 PD 5 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    NEXT_CHAR SWAP ;
: C_N ( buffer color -- buffer color ) SWAP 
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP 1 PD 7 3 PICK VERT_LINE       1 PR
    DUP 2 PD 7 3 PICK VERT_LINE       1 PR
    DUP 3 PD 7 3 PICK VERT_LINE       1 PR
    DUP 4 PD 7 3 PICK VERT_LINE       1 PR
    DUP 5 PD 7 3 PICK VERT_LINE       1 PR
    DUP 6 PD 7 3 PICK VERT_LINE       1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    DUP E 3 PICK VERT_LINE            1 PR
    NEXT_CHAR SWAP ;
: C_O ( buffer color -- buffer color ) SWAP 
    DUP 4 PD 6 3 PICK VERT_LINE             1 PR
    DUP 2 PD A 3 PICK VERT_LINE             1 PR
    DUP 1 PD C 3 PICK VERT_LINE             1 PR
    DUP 5 3 PICK VERT_LINE             
    DUP 9 PD 5 3 PICK VERT_LINE             1 PR
    DUP 4 3 PICK VERT_LINE             
    DUP A PD 4 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 2 3 PICK VERT_LINE             
    DUP C PD 2 3 PICK VERT_LINE             1 PR
    DUP 2 3 PICK VERT_LINE             
    DUP C PD 2 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 4 3 PICK VERT_LINE             
    DUP A PD 4 3 PICK VERT_LINE             1 PR
    DUP 5 3 PICK VERT_LINE             
    DUP 9 PD 5 3 PICK VERT_LINE             1 PR
    DUP 1 PD C 3 PICK VERT_LINE             1 PR
    DUP 2 PD A 3 PICK VERT_LINE             1 PR
    DUP 4 PD 6 3 PICK VERT_LINE             1 PR
    NEXT_CHAR SWAP ;
: C_P ( buffer color -- buffer color ) SWAP  
    DUP 1 PD D 3 PICK VERT_LINE             1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP 7 PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP 7 PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP 7 PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP 7 PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP 7 PD 3 3 PICK VERT_LINE             1 PR
    DUP 4 3 PICK VERT_LINE             
    DUP 6 PD 4 3 PICK VERT_LINE             1 PR
    DUP A 3 PICK VERT_LINE                  1 PR
    DUP 1 PD 8 3 PICK VERT_LINE             1 PR
    DUP 2 PD 6 3 PICK VERT_LINE             1 PR
    DUP 3 PD 4 3 PICK VERT_LINE             1 PR
    NEXT_CHAR SWAP ;
: C_Q ( buffer color -- buffer color ) SWAP 
    DUP 4 PD 6 3 PICK VERT_LINE             1 PR
    DUP 2 PD A 3 PICK VERT_LINE             1 PR
    DUP 1 PD C 3 PICK VERT_LINE             1 PR
    DUP 5 3 PICK VERT_LINE             
    DUP 9 PD 5 3 PICK VERT_LINE             1 PR
    DUP 4 3 PICK VERT_LINE             
    DUP A PD 4 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 2 3 PICK VERT_LINE             
    DUP C PD 2 3 PICK VERT_LINE             1 PR
    DUP 2 3 PICK VERT_LINE 
    DUP 7 PD 3 3 PICK VERT_LINE      
    DUP C PD 2 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 7 PD 7 3 PICK VERT_LINE             1 PR
    DUP 4 3 PICK VERT_LINE
    DUP 8 PD 6 3 PICK VERT_LINE             1 PR
    DUP 5 3 PICK VERT_LINE
    DUP 9 PD 5 3 PICK VERT_LINE             1 PR
    DUP 1 PD C 3 PICK VERT_LINE             1 PR
    DUP 2 PD C 3 PICK VERT_LINE             1 PR
    DUP 4 PD 6 3 PICK VERT_LINE             
    DUP C PD 2 3 PICK VERT_LINE             1 PR
    NEXT_CHAR SWAP ;
: C_R ( buffer color -- buffer color ) SWAP
    DUP 1 PD D 3 PICK VERT_LINE             1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP 7 PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP 7 PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP 7 PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP 7 PD 4 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP 7 PD 5 3 PICK VERT_LINE             1 PR
    DUP 4 3 PICK VERT_LINE             
    DUP 6 PD 7 3 PICK VERT_LINE             1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP 1 PD 8 3 PICK VERT_LINE             
    DUP A PD 4 3 PICK VERT_LINE             1 PR
    DUP 2 PD 6 3 PICK VERT_LINE             
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 PD 4 3 PICK VERT_LINE             
    DUP C PD 2 3 PICK VERT_LINE             1 PR
    NEXT_CHAR SWAP ;
: C_S ( buffer color -- buffer color ) SWAP  
    DUP 2 PD 4 3 PICK VERT_LINE             
    DUP A PD 4 3 PICK VERT_LINE             1 PR
    DUP 1 PD 6 3 PICK VERT_LINE             
    DUP A PD 4 3 PICK VERT_LINE             1 PR
    DUP 8 3 PICK VERT_LINE             
    DUP A PD 4 3 PICK VERT_LINE             1 PR
    DUP 9 3 PICK VERT_LINE             
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 5 PD 4 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 5 PD 4 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 5 PD 4 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 5 PD 4 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 5 PD 4 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 5 PD 4 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE             
    DUP 5 PD 9 3 PICK VERT_LINE             1 PR
    DUP 4 3 PICK VERT_LINE             
    DUP 6 PD 8 3 PICK VERT_LINE             1 PR
    DUP 4 3 PICK VERT_LINE             
    DUP 7 PD 6 3 PICK VERT_LINE             1 PR
    DUP 4 3 PICK VERT_LINE             
    DUP 8 PD 4 3 PICK VERT_LINE             1 PR
    NEXT_CHAR SWAP ;
: C_T ( buffer color -- buffer color ) SWAP 
    DUP 3 3 PICK VERT_LINE                  1 PR
    DUP 3 3 PICK VERT_LINE                  1 PR
    DUP 3 3 PICK VERT_LINE                  1 PR
    DUP 3 3 PICK VERT_LINE                  1 PR
    DUP 3 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP 3 3 PICK VERT_LINE                  1 PR
    DUP 3 3 PICK VERT_LINE                  1 PR
    DUP 3 3 PICK VERT_LINE                  1 PR
    DUP 3 3 PICK VERT_LINE                  1 PR
    DUP 3 3 PICK VERT_LINE                  1 PR
    NEXT_CHAR SWAP ;
: C_U ( buffer color -- buffer color ) SWAP  
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    DUP E 3 PICK VERT_LINE                  1 PR
    NEXT_CHAR SWAP ;
: C_V ( buffer color -- buffer color ) SWAP  
    DUP 8 3 PICK VERT_LINE                  1 PR
    DUP 9 3 PICK VERT_LINE                  1 PR
    DUP A 3 PICK VERT_LINE                  1 PR
    DUP B 3 PICK VERT_LINE                  1 PR
    DUP 6 PD 6 3 PICK VERT_LINE             1 PR
    DUP 7 PD 6 3 PICK VERT_LINE             1 PR
    DUP 8 PD 6 3 PICK VERT_LINE             1 PR
    DUP 8 PD 6 3 PICK VERT_LINE             1 PR
    DUP 7 PD 6 3 PICK VERT_LINE             1 PR
    DUP 6 PD 6 3 PICK VERT_LINE             1 PR
    DUP B 3 PICK VERT_LINE                  1 PR
    DUP A 3 PICK VERT_LINE                  1 PR
    DUP 9 3 PICK VERT_LINE                  1 PR
    DUP 8 3 PICK VERT_LINE                  1 PR
    NEXT_CHAR SWAP ;
: C_W ( buffer color -- buffer color ) SWAP  
    DUP A 3 PICK VERT_LINE                  1 PR
    DUP C 3 PICK VERT_LINE                  1 PR
    DUP D 3 PICK VERT_LINE                  1 PR
    DUP 9 PD 5 3 PICK VERT_LINE             1 PR
    DUP 9 PD 5 3 PICK VERT_LINE             1 PR
    DUP 7 PD 6 3 PICK VERT_LINE             1 PR
    DUP 6 PD 5 3 PICK VERT_LINE             1 PR
    DUP 6 PD 5 3 PICK VERT_LINE             1 PR
    DUP 7 PD 6 3 PICK VERT_LINE             1 PR
    DUP 9 PD 5 3 PICK VERT_LINE             1 PR
    DUP 9 PD 5 3 PICK VERT_LINE             1 PR
    DUP D 3 PICK VERT_LINE                  1 PR
    DUP C 3 PICK VERT_LINE                  1 PR
    DUP A 3 PICK VERT_LINE                  1 PR
    NEXT_CHAR SWAP ;
: C_X ( buffer color -- buffer color ) SWAP  
    DUP 3 3 PICK VERT_LINE                  
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 4 3 PICK VERT_LINE                  
    DUP A PD 4 3 PICK VERT_LINE             1 PR
    DUP 5 3 PICK VERT_LINE                  
    DUP 9 PD 5 3 PICK VERT_LINE             1 PR
    DUP 1 PD 5 3 PICK VERT_LINE                  
    DUP 8 PD 5 3 PICK VERT_LINE             1 PR
    DUP 2 PD A 3 PICK VERT_LINE             1 PR
    DUP 3 PD 8 3 PICK VERT_LINE             1 PR
    DUP 4 PD 6 3 PICK VERT_LINE             1 PR
    DUP 4 PD 6 3 PICK VERT_LINE             1 PR
    DUP 3 PD 8 3 PICK VERT_LINE             1 PR
    DUP 2 PD A 3 PICK VERT_LINE             1 PR
    DUP 1 PD 5 3 PICK VERT_LINE                  
    DUP 8 PD 5 3 PICK VERT_LINE             1 PR
    DUP 5 3 PICK VERT_LINE                  
    DUP 9 PD 5 3 PICK VERT_LINE             1 PR
    DUP 4 3 PICK VERT_LINE                  
    DUP A PD 4 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    NEXT_CHAR SWAP ;
: C_Y ( buffer color -- buffer color ) SWAP
    DUP 5 3 PICK VERT_LINE                  1 PR
    DUP 6 3 PICK VERT_LINE                  1 PR
    DUP 7 3 PICK VERT_LINE                  1 PR
    DUP 3 PD 5 3 PICK VERT_LINE             1 PR
    DUP 4 PD 5 3 PICK VERT_LINE             1 PR
    DUP 5 PD 9 3 PICK VERT_LINE             1 PR
    DUP 6 PD 8 3 PICK VERT_LINE             1 PR
    DUP 6 PD 8 3 PICK VERT_LINE             1 PR
    DUP 5 PD 9 3 PICK VERT_LINE             1 PR
    DUP 4 PD 5 3 PICK VERT_LINE             1 PR
    DUP 3 PD 5 3 PICK VERT_LINE             1 PR
    DUP 7 3 PICK VERT_LINE                  1 PR
    DUP 6 3 PICK VERT_LINE                  1 PR
    DUP 5 3 PICK VERT_LINE                  1 PR
    NEXT_CHAR SWAP ;
: C_Z ( buffer color -- buffer color ) SWAP 
    DUP 3 3 PICK VERT_LINE                  
    DUP 9 PD 5 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 8 PD 6 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 8 PD 6 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 7 PD 7 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 7 PD 3 3 PICK VERT_LINE             
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 6 PD 3 3 PICK VERT_LINE             
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 6 PD 3 3 PICK VERT_LINE             
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 5 PD 3 3 PICK VERT_LINE             
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 5 PD 3 3 PICK VERT_LINE             
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 4 PD 3 3 PICK VERT_LINE             
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 7 3 PICK VERT_LINE                  
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 6 3 PICK VERT_LINE                  
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 6 3 PICK VERT_LINE                  
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    DUP 5 3 PICK VERT_LINE                  
    DUP B PD 3 3 PICK VERT_LINE             1 PR
    NEXT_CHAR SWAP ;
\***NUMBERS***\
: N_1 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 1 PD 3 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE                  
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_2 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 2 PD 2 3 PICK VERT_LINE         1 PR
    DUP 1 PD 3 3 PICK VERT_LINE         
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE                  
    DUP 9 PD 5 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 8 PD 6 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 7 PD 7 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 5 PD 5 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE                  
    DUP 4 PD 5 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 8 3 PICK VERT_LINE                  
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 1 PD 6 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 2 PD 4 E PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_3 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 3 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 6 PD 2 3 PICK VERT_LINE          
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE
    DUP 5 PD 4 3 PICK VERT_LINE          
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 1 PD 5 3 PICK VERT_LINE
    DUP 8 PD 5 3 PICK VERT_LINE         1 PR
    DUP 2 PD 3 3 PICK VERT_LINE
    DUP 9 PD 3 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_4 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 6 PD 5 3 PICK VERT_LINE         1 PR
    DUP 5 PD 6 3 PICK VERT_LINE         1 PR
    DUP 4 PD 7 3 PICK VERT_LINE         1 PR
    DUP 3 PD 4 3 PICK VERT_LINE         
    DUP 8 PD 3 3 PICK VERT_LINE         1 PR
    DUP 2 PD 4 3 PICK VERT_LINE         
    DUP 8 PD 3 3 PICK VERT_LINE         1 PR
    DUP 1 PD 4 3 PICK VERT_LINE         
    DUP 8 PD 3 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 8 PD 3 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_5 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 7 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 8 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE         
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE         
    DUP 7 PD 6 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_6 ( buffer color -- buffer color ) SWAP 1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 6 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 6 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 6 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 6 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE         
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE         
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE         
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_7 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 3 3 PICK VERT_LINE              1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP 8 PD 6 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP 6 PD 8 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP 4 PD 8 3 PICK VERT_LINE         1 PR
    DUP A 3 PICK VERT_LINE              1 PR
    DUP 8 3 PICK VERT_LINE              1 PR
    DUP 6 3 PICK VERT_LINE              1 PR
    DUP 4 3 PICK VERT_LINE              1 PR
    NEXT_CHAR SWAP ;
: N_8 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 2 PD 2 3 PICK VERT_LINE              
    DUP A PD 2 3 PICK VERT_LINE         1 PR
    DUP 1 PD 4 3 PICK VERT_LINE              
    DUP 9 PD 4 3 PICK VERT_LINE         1 PR
    DUP 6 3 PICK VERT_LINE              
    DUP 8 PD 6 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 2 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 2 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 2 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP 2 3 PICK VERT_LINE  
    DUP 5 PD 4 3 PICK VERT_LINE       
    DUP C PD 2 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 6 3 PICK VERT_LINE              
    DUP 8 PD 6 3 PICK VERT_LINE         1 PR
    DUP 1 PD 4 3 PICK VERT_LINE              
    DUP 9 PD 4 3 PICK VERT_LINE         1 PR
    DUP 2 PD 2 3 PICK VERT_LINE              
    DUP A PD 2 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: N_9 ( buffer color -- buffer color ) SWAP 1 PR
    DUP 8 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 8 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 8 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE  
    DUP 5 PD 3 3 PICK VERT_LINE       
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    NEXT_CHAR SWAP ;
: N_0 ( buffer color -- buffer color ) SWAP 1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP 4 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 4 3 PICK VERT_LINE              
    DUP A PD 4 3 PICK VERT_LINE         1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    DUP E 3 PICK VERT_LINE              1 PR
    NEXT_CHAR SWAP ;
\***PUNCTUATION MARKS***\
: DOT ( buffer color -- buffer color ) SWAP
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: 2DOTS ( buffer color -- buffer color ) SWAP
    DUP 3 PD 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 PD 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 PD 3 3 PICK VERT_LINE
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: C_! ( buffer color -- buffer color ) SWAP
    DUP 1 PD 7 3 PICK VERT_LINE         1 PR
    DUP 9 3 PICK VERT_LINE              1 PR
    DUP A 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP A 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP A 3 PICK VERT_LINE              
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 9 3 PICK VERT_LINE              1 PR
    DUP 1 PD 7 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: C_? ( buffer color -- buffer color ) SWAP
    DUP 3 PD 3 3 PICK VERT_LINE         1 PR
    DUP 1 PD 5 3 PICK VERT_LINE         1 PR
    DUP 5 3 PICK VERT_LINE              
    DUP 8 PD 2 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP 7 PD 3 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 3 3 PICK VERT_LINE              
    DUP 5 PD 5 3 PICK VERT_LINE         
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    DUP 8 3 PICK VERT_LINE              1 PR
    DUP 1 PD 6 3 PICK VERT_LINE         1 PR
    DUP 2 PD 4 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
: COMMON ( buffer color -- buffer color ) SWAP
    DUP F PD 1 3 PICK VERT_LINE         1 PR
    DUP B PD 5 3 PICK VERT_LINE         1 PR
    DUP B PD 4 3 PICK VERT_LINE         1 PR
    DUP B PD 3 3 PICK VERT_LINE         1 PR
    NEXT_CHAR SWAP ;
\***RESULT MESSAGE***\
: CORRECT ( -- ) 
    0 BEGIN RESULT_POSITION GREEN C_C C_O C_R C_R C_E C_C C_T TAKE_TIMES CLR_RESULT TAKE_TIMES 2DROP 1+ DUP 3 = UNTIL DROP RESULT_POSITION GREEN C_C C_O C_R C_R C_E C_C C_T 2DROP ;
: ERROR ( -- )  
    0 BEGIN RESULT_POSITION 17 PR RED C_E C_R C_R C_O C_R C_! C_! TAKE_TIMES CLR_RESULT TAKE_TIMES 2DROP 1+ DUP 3 =  UNTIL DROP RESULT_POSITION 17 PR RED C_E C_R C_R C_O C_R C_! C_! 2DROP ;
: REGOK ( -- ) RESULT_POSITION GREEN C_R C_E C_G C_I C_S C_T C_E C_R C_E C_D 2DROP ;
\***EXTRA MESSAGE***\
: NOMATCH ( -- ) 
    MESSAGE_POSITION 5 WORDS_LENGTH 5 + PR RED C_N C_O CHAR_SPACE C_M C_A C_T C_C C_H 2DROP ;
: NOFINGER ( -- ) MESSAGE_POSITION RED C_N C_O CHAR_SPACE C_F C_I C_N C_G C_E C_R CHAR_SPACE C_O C_N CHAR_SPACE C_S C_E C_N C_S C_O C_R 2DROP ;
: FAIL ( -- ) MESSAGE_POSITION 4 WORDS_LENGTH PR RED C_C C_A C_P C_T C_U C_R C_E CHAR_SPACE C_F C_A C_I C_L 2DROP ;
: ALREADYREG ( -- ) MESSAGE_POSITION ORANGE C_F C_I C_N C_G C_E C_R CHAR_SPACE C_A C_L C_R C_E C_A C_D C_Y CHAR_SPACE C_R C_E C_G C_I C_S C_T C_E C_R 2DROP ;
: FIRSTACQ ( -- ) MESSAGE_POSITION GREEN C_F C_I C_R C_S C_T CHAR_SPACE C_A C_C C_Q C_U C_I C_S C_I C_T C_I C_O C_N CHAR_SPACE C_O C_K 2DROP ;
: DOWNLOADING ( -- ) MESSAGE_POSITION WHITE  C_D C_O C_W C_N C_L C_O C_A C_D C_I C_N C_G CHAR_SPACE C_I C_M C_A C_G C_E 2DROP ;
: RESTORING ( -- ) MESSAGE_POSITION WHITE  C_R C_E C_S C_T C_O C_R C_I C_N C_G CHAR_SPACE C_I C_M C_A C_G C_E 2DROP ;
: BLURRING ( -- ) MESSAGE_POSITION WHITE  C_B C_L C_U C_R C_R C_I C_N C_G CHAR_SPACE C_I C_M C_A C_G C_E 2DROP ;
: NOTADMIN ( -- ) MESSAGE_POSITION RED C_A C_D C_M C_I C_N CHAR_SPACE C_N C_O C_T CHAR_SPACE C_V C_E C_R C_I C_F C_I C_E C_D 2DROP ;
: ADMINGRANTED ( -- ) 
    MENU_POSITION NEXT_LINE NEXT_LINE DUP 1E CLR_WORDS DUP
    NEXT_LINE 1B CLR_WORDS 
    RED C_A C_D C_M C_I C_N CHAR_SPACE C_P C_E C_R C_M C_I C_S C_S C_I C_O C_N CHAR_SPACE C_G C_R C_A C_N C_T C_E C_D 2DROP ;
: FAILCOMBINE ( -- ) MESSAGE_POSITION RED C_F C_A C_I C_L CHAR_SPACE C_T C_O CHAR_SPACE C_C C_O C_M C_B C_I C_N C_E 2DROP ;
: DELETED ( -- ) MESSAGE_POSITION RED C_D C_E C_L C_E C_T C_E C_D 2DROP ;
: DONE ( -- ) MESSAGE_POSITION GREEN C_D C_O C_N C_E C_! 2DROP ;
: PUT_FINGER ( color -- buffer color ) INDICATIONS_POSITION DUP ROT C_P C_U C_T CHAR_SPACE C_Y C_O C_U C_R CHAR_SPACE C_F C_I C_N C_G C_E C_R NIP SWAP NEXT_LINE SWAP C_O C_N CHAR_SPACE C_T C_H C_E CHAR_SPACE C_S C_E C_N C_S C_O C_R DOT DOT DOT ;
\***MENU FUNCTIONS***\
: LOGIN ( buffer color -- buffer color ) N_1 DOT CHAR_SPACE C_L C_O C_G C_I C_N ;
: REGISTER ( buffer color -- buffer color ) N_2 DOT CHAR_SPACE C_R C_E C_G C_I C_S C_T C_E C_R CHAR_SPACE C_N C_E C_W CHAR_SPACE C_F C_I C_N C_G C_E C_R C_P C_R C_I C_N C_T ;
: SCAN ( buffer color -- buffer color ) N_3 DOT CHAR_SPACE C_S C_C C_A C_N CHAR_SPACE C_A C_N C_D CHAR_SPACE C_S C_H C_O C_W CHAR_SPACE C_F C_I C_N C_G C_E C_R C_P C_R C_I C_N C_T ;
: CANCEL ( buffer color -- buffer color ) N_4 DOT CHAR_SPACE C_C C_A C_N C_C C_E C_L CHAR_SPACE C_A C_L C_L CHAR_SPACE C_F C_I C_N C_G C_E C_R CHAR_SPACE C_L C_I C_B C_R C_A C_R C_Y ;
: SHUT_OFF ( buffer color -- buffer color ) N_5 DOT CHAR_SPACE C_S C_H C_U C_T CHAR_SPACE C_O C_F C_F ;
: MENU ( color --  )
    MENU_POSITION DUP ROT C_S C_E C_L C_E C_C C_T CHAR_SPACE C_A C_N CHAR_SPACE C_O C_P C_T C_I C_O C_N CHAR_SPACE C_F C_R C_O C_M CHAR_SPACE C_B C_E C_L C_O C_W 2DOTS 
    NIP NEW_LINE LOGIN
    NIP NEW_LINE REGISTER
    NIP NEW_LINE SCAN
    NIP NEW_LINE CANCEL
    NIP NEW_LINE SHUT_OFF
    2DROP DROP ;
\***CHOICE MANIPULATION***\
: ADMIN_PERMISSION ( -- ) 
    MENU_POSITION NEXT_LINE NEXT_LINE DUP RED C_N C_E C_E C_D CHAR_SPACE C_T C_O CHAR_SPACE  C_C C_H C_E C_C C_K CHAR_SPACE C_A C_D C_M C_I C_N CHAR_SPACE C_P C_E C_R C_M C_I C_S C_S C_I C_O C_N 
    2DROP NEXT_LINE WHITE C_P C_L C_E C_A C_S C_E CHAR_SPACE C_I C_N C_S C_E C_R C_T CHAR_SPACE C_A C_D C_M C_I C_N  CHAR_SPACE C_F C_I C_N C_G C_E C_R DOT DOT DOT 2DROP ;
: CHOICE ( n -- ) CLR_MENU WHITE MENU_POSITION SWAP C_Y C_O C_U C_R CHAR_SPACE C_C C_H C_O C_I C_C C_E 2DOTS CHAR_SPACE 
    DROP BLUE ROT CASE 
        1 OF LOGIN NIP PUT_FINGER ENDOF
        2 OF REGISTER ADMIN_PERMISSION ENDOF
        3 OF SCAN NIP PUT_FINGER ENDOF
        4 OF CANCEL ADMIN_PERMISSION ENDOF
        5 OF SHUT_OFF ENDOF
    ENDCASE 2DROP ;
: SHOW_ID ( ID -- )
	DUP DUP 64 / TUCK 64 * - A / ROT OVER A * - 2 PICK 64 * - SWAP ROT
	MESSAGE_POSITION 4 WORDS_LENGTH PR WHITE C_Y C_O C_U C_R CHAR_SPACE C_I C_D CHAR_SPACE C_I C_S 2DOTS CHAR_SPACE
	0 BEGIN -ROT 3 PICK
		CASE
			0 OF N_0 ENDOF
			1 OF N_1 ENDOF
			2 OF N_2 ENDOF
			3 OF N_3 ENDOF
			4 OF N_4 ENDOF
			5 OF N_5 ENDOF
			6 OF N_6 ENDOF
			7 OF N_7 ENDOF
			8 OF N_8 ENDOF
			9 OF N_9 ENDOF
			." error " ENDCASE
	    DROP4 ROT
	1+ DUP 3 = UNTIL DROP 2DROP ;

HEX
\***CONSTANT***\
100 CONSTANT IMG_WIDTH
9000 CONSTANT IMAGE_SIZE
12000 CONSTANT BITMAP_SIZE
303 CONSTANT START_BLURRING
\***ARRAY***\
CREATE PACKTOSEND EF , 01 , FF , FF , FF , FF , 01 , 00 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , 
CREATE PACKTOREC -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 , -1 ,
CREATE IMAGE IMAGE_SIZE CELLS ALLOT
CREATE 32BITMAP BITMAP_SIZE CELLS ALLOT
\***VARAIBLE***\
VARIABLE ID 
VARIABLE SIZE
VARIABLE CHECKSUM
VARIABLE FINGER_COUNT
\***UTILITY***\
: WAIT ( -- ) 0 BEGIN 1 1+ DROP 1+ DUP A0000 = UNTIL DROP ;
: WAITSHORT ( -- ) 0 BEGIN 1 1+ DROP 1+ DUP A000 = UNTIL DROP ;
: R@ ( -- n ) R> R> DUP >R SWAP >R ;
\***BYTES MANIUPULATION***\
: DIVIDEBYTES ( n -- n1 n2 ) DUP 8 RSHIFT SWAP FF AND ;
: 1BYTE2BYTE ( n -- n1 n2 ) DUP F0 AND SWAP F AND ;
: RESTOREBYTES ( n -- n1 n2 ) 1BYTE2BYTE 4 LSHIFT ;
: 8TO32 ( n1 -- n1n1n1 ) DUP 8 LSHIFT DUP 8 LSHIFT OR OR ;
\***ARRAY MANIUPULATION***\
: READ_ARRAY_N ( arrayname pos -- val ) CELLS + @ ;
: READ_ARRAY ( arrayname size -- ) 
	0 BEGIN 
		2 PICK OVER READ_ARRAY_N . 
	1+ 2DUP = UNTIL DROP 2DROP ;
: WRITE_ARRAY_N ( arrayname pos val -- ) -ROT CELLS + ! ;
: WRITE_ARRAY ( a1 a2 ... an  arrayname n -- ) 
	BEGIN 
		ROT OVER 1- SWAP 3 PICK -ROT WRITE_ARRAY_N 1- DUP 
	0= UNTIL 2DROP ;
: SIZE_W/0_CHECK ( -- size ) SIZE @ 2- ;
: ARRAY_OFFSET ( arrayname offeset -- arrayname+offset ) CELLS + ;
\***COMMUNICATION***\
: DROP_N_READ ( N -- ) 
	0 BEGIN 
		SERIAL_READ DUP 
		-1 = IF ." TIMEOUT-OCCURRED WHILE TRYING TO READ. ENDING AT: " SWAP . -ROT 2DROP EXIT 
		THEN DROP 
	1+ 2DUP = UNTIL 2DROP ;
: RECEIVEWRITE ( size -- ) 
	PACKTOREC SWAP 0 BEGIN 
		SERIAL_READ DUP 
		-1 = IF ." TIMEOUT-OCCURRED WHILE TRYING TO READ. ENDING AT: " SWAP . -ROT 2DROP EXIT 
		THEN 3 PICK SWAP 2 PICK SWAP WRITE_ARRAY_N 
	1+ DUP 2 PICK = UNTIL 
	DROP 2DROP ;
: SEND_N ( arrayname size -- ) 
	0 BEGIN 
		DUP 3 PICK SWAP READ_ARRAY_N SERIAL_WRITE 1+ DUP 
	2 PICK = UNTIL 
	DROP 2DROP ;
\***PACKET MANIUPULATION***\
: CALCULATE_CHECKSUM ( size -- )  
	0 CHECKSUM ! 6 BEGIN 
		PACKTOSEND OVER READ_ARRAY_N CHECKSUM +! 
	1+ 2DUP = UNTIL 2DROP ;
: WRITE_PACKET ( a1 a2 ... an n -- )
	PACKTOSEND 8 CELLS + SWAP WRITE_ARRAY
	SIZE_W/0_CHECK CALCULATE_CHECKSUM
	PACKTOSEND SIZE_W/0_CHECK CHECKSUM @ DIVIDEBYTES
	2SWAP CELLS + 2 WRITE_ARRAY ;
: WRITESEND ( a1 a2 ... an n -- )
	DUP PICK 9 + SIZE !
	WRITE_PACKET PACKTOSEND SIZE @ SEND_N  ;
\***RECEIVE PACKET MANIUPULATION***\
: TAKE_ID ( -- ID ) PACKTOREC B READ_ARRAY_N ;
: SHOW_ACK ( size -- ) ." ACK-PACK: " PACKTOREC SWAP READ_ARRAY CR ;
: CHECK_CONFIRMATION ( -- value ) PACKTOREC 9 READ_ARRAY_N ;
: SHOW_CONFIRMATION ( -- ) 
	CLR_INDICATIONS CHECK_CONFIRMATION 
	CASE 
		0 OF CORRECT ENDOF 
		1 OF ERROR ENDOF
		2 OF NOFINGER ERROR ENDOF
		3 OF FAIL ERROR ENDOF
		9 OF NOMATCH ERROR ENDOF
		A OF FAILCOMBINE ERROR ENDOF
		24 OF ALREADYREG ENDOF
		56 OF FIRSTACQ ENDOF
		ERROR
	ENDCASE ; 
: SEND_RECEIVE_ACK ( size a1 a2 ... an n -- ) WRITESEND DUP RECEIVEWRITE DUP -1 <> IF SHOW_ACK ELSE DROP THEN ;
: SEND_RECEIVE_SHOW ( size a1 a2 ... an n -- ) WRITESEND DUP RECEIVEWRITE DUP -1 <> IF SHOW_ACK ELSE DROP THEN SHOW_CONFIRMATION ;
\***IMAGES MANIUPULATION***\
: STORE_IMAGE ( -- )
	IMAGE IMAGE_SIZE 9 DROP_N_READ CR 0 BEGIN 
		DUP 0> IF DUP 80 MOD 
			0= IF 
				NEXT_PROGRESS B DROP_N_READ 
			THEN 
		THEN SERIAL_READ DUP 
		-1 = IF 
			." TIMEOUT-OCCURRED WHILE TRYING TO READ. ENDING AT: " DROP . EXIT 
		THEN 3 PICK SWAP 2 PICK SWAP WRITE_ARRAY_N 
	1+ DUP 2 PICK = UNTIL 
	2 DROP_N_READ DROP 2DROP ;
: ELABORATE_IMAGE 
	0 BEGIN 
		IMAGE OVER READ_ARRAY_N RESTOREBYTES >R 8TO32 R> 8TO32 32BITMAP 3 PICK 2* ARRAY_OFFSET 2 WRITE_ARRAY 
		1+ DUP DUP 2E1 MOD 
		0= IF 
			NEXT_PROGRESS 
		THEN 
	IMAGE_SIZE = UNTIL 
	DROP ;
: BLURRINGMASK ( Pos -- ) 32BITMAP SWAP READ_ARRAY_N FF AND + SWAP ;
: 50DUP ( value -- ) DUP 0 BEGIN >R 2DUP R> 1+ DUP 18 = UNTIL DROP ;
: BLURRING7  ( -- )
	START_BLURRING BEGIN
		DUP IMG_WIDTH MOD FD = IF 6 + THEN 50DUP
		IMG_WIDTH 3 * - 3 - 32BITMAP SWAP READ_ARRAY_N FF AND SWAP
		IMG_WIDTH 3 * - 2 - BLURRINGMASK
		IMG_WIDTH 3 * - 1 - BLURRINGMASK
		IMG_WIDTH 3 * -     BLURRINGMASK
		IMG_WIDTH 3 * - 1 + BLURRINGMASK
		IMG_WIDTH 3 * - 2 + BLURRINGMASK
		IMG_WIDTH 3 * - 3 + BLURRINGMASK
		IMG_WIDTH 2 * - 3 - BLURRINGMASK
		IMG_WIDTH 2 * - 2 - BLURRINGMASK
		IMG_WIDTH 2 * - 1 - BLURRINGMASK
		IMG_WIDTH 2 * -     BLURRINGMASK
		IMG_WIDTH 2 * - 1 + BLURRINGMASK
		IMG_WIDTH 2 * - 2 + BLURRINGMASK
		IMG_WIDTH 2 * - 3 + BLURRINGMASK
		IMG_WIDTH - 3 - BLURRINGMASK
		IMG_WIDTH - 2 - BLURRINGMASK
		IMG_WIDTH - 1 - BLURRINGMASK
		IMG_WIDTH -     BLURRINGMASK
		IMG_WIDTH - 1 + BLURRINGMASK
		IMG_WIDTH - 2 + BLURRINGMASK
		IMG_WIDTH - 3 + BLURRINGMASK
		3 - BLURRINGMASK
		2 - BLURRINGMASK
		1 - BLURRINGMASK
		    BLURRINGMASK
		1 + BLURRINGMASK
		2 + BLURRINGMASK
		3 + BLURRINGMASK
		IMG_WIDTH + 3 - BLURRINGMASK
		IMG_WIDTH + 2 - BLURRINGMASK
		IMG_WIDTH + 1 - BLURRINGMASK
		IMG_WIDTH +     BLURRINGMASK
		IMG_WIDTH + 1 + BLURRINGMASK
		IMG_WIDTH + 2 + BLURRINGMASK
		IMG_WIDTH + 3 + BLURRINGMASK
		IMG_WIDTH 2 * +  3 - BLURRINGMASK
		IMG_WIDTH 2 * +  2 - BLURRINGMASK
		IMG_WIDTH 2 * +  1 - BLURRINGMASK
		IMG_WIDTH 2 * +      BLURRINGMASK
		IMG_WIDTH 2 * +  1 + BLURRINGMASK
		IMG_WIDTH 2 * +  2 + BLURRINGMASK
		IMG_WIDTH 2 * +  3 + BLURRINGMASK
		IMG_WIDTH 3 * +  3 - BLURRINGMASK
		IMG_WIDTH 3 * +  2 - BLURRINGMASK
		IMG_WIDTH 3 * +  1 - BLURRINGMASK
		IMG_WIDTH 3 * +      BLURRINGMASK
		IMG_WIDTH 3 * +  1 + BLURRINGMASK
		IMG_WIDTH 3 * +  2 + BLURRINGMASK
		IMG_WIDTH 3 * +  3 + 32BITMAP SWAP READ_ARRAY_N FF AND + 
		31 / 8TO32 32BITMAP 2 PICK ROT WRITE_ARRAY_N
	1+ DUP 2DUP 703 MOD 0= IF NEXT_PROGRESS DROP ELSE DROP THEN 11CFD = UNTIL
	DROP ;
\***SENSOR'S FUNCTIONS***\
: TAKE_FINGER_COUNT ( -- ) E 03 1D 2 WRITESEND RECEIVEWRITE PACKTOREC B READ_ARRAY_N FINGER_COUNT ! ;
: LED_ON ( -- ) C 03 50 2 SEND_RECEIVE_ACK ;
: LED_OFF ( -- ) C 03 51 2 SEND_RECEIVE_ACK ;
: CAPTURE_IMAGE ( -- ) C 03 01 2 SEND_RECEIVE_ACK ;
: UPLOAD_IMAGE ( -- ) C 03 0A 2 SEND_RECEIVE_ACK STORE_IMAGE ;
: SEARCH_ALL ( -- ) 10 08 55 3E 00 00 00 0A 7 WRITESEND DUP WAIT RECEIVEWRITE DUP
	-1 <> IF 
		SHOW_ACK 
	ELSE DROP 				
	THEN ; 
: DELETE_ALL ( -- ) C 07 0C 00 01 00 1BYTE2BYTE 6 SEND_RECEIVE_ACK ;
: DELETE_USERS ( -- ) C 07 0C 00 01 FINGER_COUNT @ 1BYTE2BYTE 6 SEND_RECEIVE_ACK ;
: AUTO_ENROLL ( -- ) C 08 54 3E 62 00 FINGER_COUNT @ 00 7 WRITESEND DUP WAIT RECEIVEWRITE DUP
	-1 <> IF 
		DUP SHOW_ACK SHOW_CONFIRMATION CHECK_CONFIRMATION 
		56 = IF 
			WAIT DUP RECEIVEWRITE DUP
			-1 <> IF 
				CLR_MESSAGE SHOW_ACK CR CHECK_CONFIRMATION 
				0= IF 
					REGOK TAKE_FINGER_COUNT FINGER_COUNT @ SHOW_ID
				ELSE
					SHOW_CONFIRMATION
				THEN
			THEN
		ELSE DROP 
		THEN 
	ELSE DROP 				
	THEN ;
: SET_BAUD ( value -- ) C 05 0E 04 4 PICK 4 SEND_RECEIVE_SHOW DROP ;
: READ_SYS_PARAM ( -- ) 1C 3 F 2 SEND_RECEIVE_ACK ;
\***FUNCTIONS***\
: SHOW_IMAGE_HDMI_CENTERED ( -- ) 
	IMAGE_POSITION 0 DUP BEGIN 
		2 PICK OVER ROW_SIZE * + ROT 
		BEGIN 
			SWAP 32BITMAP 2 PICK READ_ARRAY_N OVER ! PIXEL_SIZE + SWAP 1+ DUP 100 MOD 
		0= UNTIL 
		-ROT DROP 1+ DUP 
	120 = UNTIL 
	2DROP DROP ;
: CAPTURE_UPLOAD_ELABORATE_SHOW ( -- ) LOADING_BAR IMAGE_WINDOW CLR_PROGRESS_BAR DOWNLOADING CAPTURE_IMAGE UPLOAD_IMAGE CLR_MESSAGE ELABORATE_IMAGE CLR_MESSAGE BLURRING BLURRING7 SHOW_IMAGE_HDMI_CENTERED ;
: CHECK_ADMIN ( -- RESULT ) 
	SEARCH_ALL CHECK_CONFIRMATION 0= IF
		TAKE_ID
		0= IF 
			." ADMIN PERMISSION GRANTED " ADMINGRANTED -1
		ELSE 
			." ADMIN PERMISSION DENIED " NOTADMIN ERROR 0
		THEN 
	ELSE
		SHOW_CONFIRMATION 0
	THEN ;
: SETBAUD ( value -- ) 
	DUP C < OVER 1 > AND IF
		DUP SET_BAUD CHECK_CONFIRMATION 0= IF 2580 * CHANGEBAUD ELSE ." ERROR TO SET BAUD ON SENSOR " DROP THEN 
  	ELSE 
	  	." ERROR NUMBER MUST BE BEETWEN 1 AND 12 " DROP
	THEN ;
: INSERT_ADMIN ( -- )
	." NEED TO CHECK ADMIN PRIVILEGES " CR CHECK_ADMIN IF
		." ADMIN GRANTED, INSERT NEW ADMIN FINGER " CR 
		0 FINGER_COUNT ! AUTO_ENROLL TAKE_FINGER_COUNT
	THEN ;
\***INTERECTIVE FUNCTIONS***\
: MENU_CHOICE ( -- ) CR CR CR CR CR CR ." USE CH_N WHICH 'N' IS THE NUMBER OF YOUR CHOICE, THEN USE 'BACK' TO GO TO MAIN MENU" CR ." (E.G. CH_1 FOR LOGIN): " ;
: CH_1 ( -- )
	1 CHOICE CR 
	SEARCH_ALL CLR_INDICATIONS CHECK_CONFIRMATION 0 = IF TAKE_ID SHOW_ID THEN SHOW_CONFIRMATION ;
: CH_2 ( -- )
	2 CHOICE CR CHECK_ADMIN IF
		BLUE PUT_FINGER 2DROP AUTO_ENROLL
	THEN ;
: CH_3 ( -- )
	3 CHOICE CR
	CLR_PROGRESS_BAR CLR_IMAGE LOADING_BAR IMAGE_WINDOW  
	WAITSHORT CAPTURE_IMAGE CLR_INDICATIONS CHECK_CONFIRMATION 
	0= IF 
		DOWNLOADING UPLOAD_IMAGE CLR_MESSAGE RESTORING ELABORATE_IMAGE CLR_MESSAGE BLURRING BLURRING7 CLR_MESSAGE DONE SHOW_IMAGE_HDMI_CENTERED 
	ELSE
		CLR_MESSAGE SHOW_CONFIRMATION
	THEN ;
: CH_4 ( -- )
	4 CHOICE CR CHECK_ADMIN IF
		DELETE_USERS CHECK_CONFIRMATION 
		0= IF 
			DELETED 
		ELSE
			SHOW_CONFIRMATION
		THEN TAKE_FINGER_COUNT
	THEN ;
: CH_5 ( -- ) 
	5 CHOICE WAIT SCREEN_BLACK CR CR ." TYPE 'START' TO POWER ON " CR CR ;
: START ( -- ) INIT TAKE_FINGER_COUNT CLR_PIJ WHITE MENU MENU_CHOICE ; 
: BACK ( -- ) CLR_CHOICE CLR_RESULT CLR_MESSAGE CLR_IMAGE CLR_PROGRESS_BAR WHITE MENU MENU_CHOICE ;
