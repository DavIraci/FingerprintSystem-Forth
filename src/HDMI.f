
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
