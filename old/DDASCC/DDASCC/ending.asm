spritemaskend:
        db 24-1, 96,12*4,1
        db 40-1, 96,13*4,1
        db 24-1,112,14*4,1
        db 96-1, 16,15*4,1
        
        db 120-1,16,16*4,1
        db 88-1, 32,17*4,1
        db 104-1,32,18*4,1
        db 128-1-8,32,19*4,1
        
        db 144-1,32,20*4,1
        db 104-1,88,21*4,1
        db 112-1,80,22*4,1        ,0xD0

goodendtext1:
; show text. start at pos 7,16
;QUEST ACCOMPLISHED, 
      db 81+127, 85+127, 69+127, 83+127, 84+127, 255, 65+127, 67+127, 67+127, 79+127, 77+127, 80+127, 76+127, 73+127, 83+127, 72+127, 69+127, 68+127, 247 
;YOU MADE IT!
      db 89+127, 79+127, 85+127, 255   , 77+127, 65+127, 68+127, 69+127, 255, 73+127, 84+127, 249,255,255,255,255,255,255,255

; wait some time
; clear text

goodendtext2:
; show text at 4,16
;HASTELY, YOU MAKE YOUR WAY
      db 72+127, 65+127, 83+127, 84+127, 69+127, 76+127, 89+127, 247, 255, 89+127, 79+127, 85+127, 255, 77+127, 65+127, 75+127, 69+127, 255, 89+127, 79+127, 85+127, 82+127, 255, 87+127, 65+127, 89+127
;BACK OUTSIDE, CHASED BY A 
      db 66+127, 65+127, 67+127, 75+127, 255, 79+127, 85+127, 84+127, 83+127, 73+127, 68+127, 69+127, 247, 255, 67+127, 72+127, 65+127, 83+127, 69+127, 68+127, 255, 66+127, 89+127, 255, 65+127,255
;FIERCE HORDE OF YOUR     
      db 70+127, 73+127, 69+127, 82+127, 67+127, 69+127, 255, 72+127, 79+127, 82+127, 68+127, 69+127, 255, 79+127, 70+127, 255, 89+127, 79+127, 85+127, 82+127,255,255,255,255,255,255
;ENEMIES.                 
      db 69+127, 78+127, 69+127, 77+127, 73+127, 69+127, 83+127, 248
    rept 19
        db 255
    endm

goodendtext3:
; show text at 5,5
;YOU PASS THE GATE AND 
      db 89+127, 79+127, 85+127, 255, 80+127, 65+127, 83+127, 83+127, 255, 84+127, 72+127, 69+127, 255, 71+127, 65+127, 84+127, 69+127, 255, 65+127, 78+127, 68+127,255
;LEAVE THE DEEP DUNGEON
      db 76+127, 69+127, 65+127, 86+127, 69+127, 255, 84+127, 72+127, 69+127, 255, 68+127, 69+127, 69+127, 80+127, 255, 68+127, 85+127, 78+127, 71+127, 69+127, 79+127, 78+127 
;FOREVER.              
      db 70+127, 79+127, 82+127, 69+127, 86+127, 69+127, 82+127, 248
; skip a line
    rept 14+22
        db 255
    endm
;TOWARDS THE NIGHT, YOU
      db 84+127, 79+127, 87+127, 65+127, 82+127, 68+127, 83+127, 255, 84+127, 72+127, 69+127, 255, 78+127, 200, 71+127, 72+127, 84+127, 247, 255, 89+127, 79+127, 85+127
;RUN TO FREEDOM, FIRMLY 
      db 82+127, 85+127, 78+127, 255, 84+127, 79+127, 255, 70+127, 82+127, 69+127, 69+127, 68+127, 79+127, 77+127, 247, 255, 70+127, 73+127, 82+127, 77+127, 76+127, 89+127 
;CLENCHING THE AMULET 
      db 67+127, 76+127, 69+127, 78+127, 67+127, 72+127, 73+127, 78+127, 71+127, 255, 84+127, 72+127, 69+127, 255, 65+127, 77+127, 85+127, 76+127, 69+127, 84+127,255,255
;IN YOUR FIST.        
      db 73+127, 78+127, 255, 89+127, 79+127, 85+127, 82+127, 255, 70+127, 73+127, 83+127, 84+127, 248
    rept 9
        db 255
    endm

out6k:
		di
        push    de
        ld 		de,0xc000
        call 	miz._unpack
        pop     hl
        call 	setwrt

        ld hl,0xc000
        ld bc,0x98
		ld	a,8*3
1:      otir
        dec	a
		jr	nz,1b
		ei
        ret	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endsequence:
goodend:

; no need to load tilesets
;[silence]

        di
		ld	hl,MUSIC6			; hl <- initial address of module 
		call	PT3_INIT			; Inits PT3 player

        call    disscr
        
        call cls

       
; show sprite 6 at 104,64 and sprite 7 at 104,80 and sprite 8 at 104,96
; shpw sprite 9 at 144,64 and sprite 10 at 144,80 and sprite 11 at 144,96

        ld hl,0x1b00
        call setwrt

        ld   hl,spritemask3
        ld   bc,(6*4+1)*256+0x98
        otir


; show Exit start pos 11,6 (x,y) width 9 tiles and height 10

        ld      de,exitpnt
        ld      hl,0x1800+6*32+11
        ld      bc,9*256+0x98
1:
        push    bc

        call setwrt

        ld      bc,32
        add     hl,bc
        push    hl

        ex      de,hl
        ld      bc,9*256+0x98
        otir
        ex      de,hl

        pop     hl
        pop     bc
        djnz    1b


; Draw text 1
; show text. start at pos 6,16

        ld      hl,0x1800+16*32+7
        ld      de,goodendtext1
        ld      b,2
        ld      a,19
        call    printtext

        call    enascr

        ld  b,250
1:      halt
        djnz    1b        
       
        
 
; Draw text 2
; show text. start at pos 4,16

        ld      hl,0x1800+16*32+4
        ld      de,goodendtext2
        ld      b,4
        ld      a,26
        call    printtext

        ld  b,255
1:      halt
        djnz    1b        
        ld  b,50
1:      halt
        djnz    1b            
        call    cls
        

        ld hl,0x1b00
        call setwrt
        ld  a,0xD0
        out (0x98),a
       
; Draw text 3
; show text. start at pos 5,5

        ld      hl,0x1800+5*32+5
        ld      de,goodendtext3
        ld      b,8
        ld      a,22
        call    printtext

        ld  b,255
1:      halt
        djnz    1b        
        ld  b,150
1:      halt
        djnz    1b         
        

        
        ld a,2
        call 05Fh       ; screen 2

        call    disscr
 
        ld hl,0x1800
        call setwrt
        ld  b,0
        ld  a,255
1:      out (0x98),a
        djnz    1b
1:      out (0x98),a
        djnz    1b
1:      out (0x98),a
        djnz    1b

         ; ld hl,endpat123
         ; ld de,0x0000
         ; call    out6k

         ; ld hl,endcol123
         ; ld de,0x2000
         ; call    out6k
		 

        ld hl,endpat123
        ld de,0x0000
        call    out6k
		
        ld hl,endcol123
        ld de,0x2000
        call    out6k
		
        ; ld hl,endpat2
        ; ld de,0x0000+256*8
        ; call    out2k

        ; ld hl,endcol2
        ; ld de,0x2000+256*8
        ; call    out2k

        ; ld hl,endpat3
        ; ld de,0x0000+256*8*2
        ; call    out2k

        ; ld hl,endcol3
        ; ld de,0x2000+256*8*2
        ; call    out2k



        ld hl,0x1800
        ld  b,24
        xor a
2:      push    af
        call    setwrt
        pop     af
        push    bc
        
        ld      b,16
1:      out     (0x98),a
        inc     a
        and     127
        djnz    1b
        
        ld      c,32
        add     hl,bc
        pop     bc
        djnz    2b

   

; show sprite 12 at 96,24
; show sprite 13 at 96,40
; show sprite 14 at 112,24
; show sprite 15 at 16,96
; show sprite 16 at 16,120
; show sprite 17 at 32,88
; show sprite 18 at 32,104
; show sprite 19 at 32,128-8
; show sprite 20 at 32,144
; show sprite 21 at 88,104
; show sprite 22 at 80,112


        ld hl,0x1b00
        call setwrt

        ld   hl,spritemaskend
        ld   bc,(11*4+1)*256+0x98
        otir

        call    enascr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        

        push    ix
        push    hl
		ld	hl,MUSIC5			; hl <- initial address of module 
		call	PT3_INIT			; Inits PT3 player
        pop     hl
        pop     ix

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        call goodendcls

        ld  b,3*50
1:      halt
        djnz    1b

        call endtext

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wait a key while music is looping 
;
        ld   bc,10*60
1:
        dec     bc
        ld      a,b
        or      c
        call    z,texthint

        call    _joy
        and     00010000B
        ret     z

        halt
        ld      a,8
        push    bc
        call    0x0141 ; getin ending
        pop     bc
        inc     a
        jr      z,1b

		ld	hl,MUSIC6			; hl <- initial address of module 
		call	PT3_INIT			; Inits PT3 player
		halt
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   clear the screen
;
goodendcls:
        ld      hl,0x1800+16
        ld      b,24
2:      push    bc
        call    setwrt
        ld      a,255
        ld      b,16
1:      out     (0x98),a
        djnz    1b
        ld      bc,32
        add     hl,bc
        pop     bc
        djnz    2b
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display hints on the secret game
;
texthint:
        call    goodendcls

        ld      hl,0x1800+1*32+16
        ld      de,goodendtext18
        ld      b,11
        ld      a,16
        call    _printtext

        ld      bc,0
        ret

        include textdata.asm



 
