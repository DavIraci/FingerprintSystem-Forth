
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
