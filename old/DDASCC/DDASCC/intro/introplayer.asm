ntiles     equ     256

		  
;-------------------------------------
;-------------------------------------
		
; Set VDP for writing at address CDE (17-bits) 

_vdpsetvramwr:
	ld a,c     		

	rlc d
	rla
	rlc d
	rla
	srl d 			; 1st shift, il secondo dopo la out

	out (0x99),a 	; set bits 14-16
	ld a,14+128
	out (0x99),a

	srl d 			; 2nd shift.            

	ld a,e 			; set bits 0-7
	out (0x99),a
	ld a,d 			; set bits 8-13
	and	0x3F			
	or 0x40 		; + write access
	out (0x99),a
	ret		

; Set VDP for reading at address CDE (17-bits) 

_vdpsetvramrd:
	ld a,c      

	rlc d
	rla
	rlc d
	rla
	srl d 			; 1st shift, il secondo dopo la out

	out (0x99),a 	; set bits 14-16
	ld a,14+128
	out (0x99),a

	srl d 			; 2nd shift.            

	ld a,e 			; set bits 0-7
	out (0x99),a
	ld a,d 			; set bits 8-13
	and	0x3F
	out (0x99),a
	ret		


;-------------------------------------
; INTERRUPT CODE
;-------------------------------------

          ds	$0038 - $
          push    af
          in      a,(99h)
          pop     af
          ei
          reti


;-------------------------------------
; Entry point
;-------------------------------------
intro_START:
		ld	c,0
		ld	de,0
		call	_vdpsetvramwr
		ld	a,1
		out	(0x98),a

		ld	c,1
		ld	de,0
		call	_vdpsetvramwr
		ld	a,2
		out	(0x98),a
		
		ld	c,0
		ld	de,0		
		call	_vdpsetvramrd
		in	a,(0x98)
		cp	1
		jp nz,_vdpinit
		
		ei
		halt
        call	_vdpinit
		di
		ld		a, 0x22
		out		(0x99),a
		ld		a,1+128
		out		(0x99),a

		call 	LOAD_VRAM
		ld		e,0
		call 	_SetPalet
						
		ld		a, 0xE2 
		out		(0x99),a
		ld		a,1+128
		out		(0x99),a
		ei

		ld      b,60*3
		call    wait

		ei
		halt
		
		ld		e,1
		call 	_SetPalet
		call    _vdpinit
		ld		a, 0x22
		out		(0x99),a
		ld		a,1+128
		out		(0x99),a
		
		ret



;-------------------------------------
;-------------------------------------
wait:
1:          halt
            call    skip
            djnz    1b
            ret

;
;-------------------------------------

skip:

            call MAIN._joy
            and    00010000B
            jr     z,2f        ; skip on joystick button
            ld      e,8
            call    checkkbd  ; skip on space
            and    1
            jr     z,2f
            ret
2:          ld b,1
            ret

;-------------------------------------
; Instead of CHGMOD
;-------------------------------------

_vdpinit:   di
            ld hl,_vdpregs
            ld bc,0x8099
1:          outi
            inc b
            out (c),b
            inc b
            bit 3,b
            jr z,1b
			ei
            ret

_vdpregs:
            defb 0x02 ; Reg# 0 000000[M3][EV]
            defb 0xE2 ; Reg# 1 [4/16k][BLANK][IE][M1][M2]0[SIZE][MAG]
            defb 0x06 ; Reg# 2 0000[NAME TABLE BASE ADDRESS]          = 1800h
            defb 0xFF ; Reg# 3 [COLOR BASE ADDRESS]                   = 2000h     ; regular mode for colors
            defb 0x03 ; Reg# 4 00000[PATTERN GENERATOR BASE ADDRESS]  = 0000h     ; regular mode for patterns

            defb 0x36 ; Reg# 5 0[SPRITE ATTRIBUTE TABLE BASE ADDRESS] = 1b00h
            defb 0x07 ; Reg# 6 00000[SPRITE PTRN GNRTR BASE ADDRESS]  = 3800h
            defb 0x00 ; Reg# 7 [TEXT COLOR 4bts][BACKDROP COLOR 4bts]




;-------------------------------------
; support i/o code
;-------------------------------------

outs768:

        ld      de,ntiles*8*3
2:
        ld      c,0x98

1:      outi
        dec     e
        jr      nz,1b
        dec     d
        jr      nz,1b

        ret



;-------------------------------------
; Load the vram
;-------------------------------------

LOAD_VRAM:
        ld      hl,pat
        xor     a
        out     (0x99),a
        ld      a,0x0000/256 + 0x40 ; PGT
        out     (0x99),a

        call    outs768

		ld      hl,col
        xor     a
        out     (0x99),a
        ld      a,0x2000/256 + 0x40 ; PCT
        out     (0x99),a

        call    outs768
		
        xor     a
        out     (0x99),a
        ld      a,0x1800/256 + 0x40 ; PNT
        out     (0x99),a

		
		xor	a
1:		out	(0x98),a
		inc	a
		jr	nz,1b
1:		out	(0x98),a
		inc	a
		jr	nz,1b
1:		out	(0x98),a
		inc	a
		jr	nz,1b

        ret

;-------------------------------------
; palette data
;-------------------------------------



levelcolors:
	dw levelcolors0,levelcolors1
levelcolors0:
	db 0,0,0
	db 5,4,4
	db 7,7,7
	db 6,4,6
	db 3,2,2
	db 6,5,4
	db 4,4,3
	db 6,4,5
	db 1,1,0
	db 5,3,4
	db 2,2,2
	db 2,1,1
	db 1,0,0
	db 3,3,2
	db 4,3,2
	db 5,5,4

 DB 0,0,0
 DB 7,7,7
 DB 6,6,6
 DB 4,3,2
 DB 6,5,5
 DB 2,1,0
 DB 5,5,5
 DB 2,2,1
 DB 4,4,3
 DB 5,5,4
 DB 3,2,1
 DB 5,3,2
 DB 1,1,0
 DB 5,4,3
 DB 3,3,2
 DB 4,3,3
	
_levelcolors0:
 ;   R,B,G
	DB  0,0,1
	DB  6,2,4
	DB  3,1,1
	DB  7,4,6
	DB  4,2,3
	DB  2,2,2
	DB  6,3,5
	DB  2,0,0
	DB  4,1,1
	DB  7,6,7
	DB  5,1,3
	DB  1,1,1
	DB  5,1,1
	DB  6,4,5
	DB  6,3,4
	DB  7,7,7
 
levelcolors1:
 ;   R,B,G
	db 0,0,0  	;0
	db 0,0,0	;1
	db 1,2,4	;2
	db 2,3,6	;3
	db 2,5,2	;4
	db 3,7,3	;5
	db 6,1,2	;6
	db 2,6,6	;7
	db 7,1,1	;8
	db 7,2,3	;9
	db 6,2,5	;10
	db 7,3,6	;11
	db 2,1,3	;12
	db 5,4,2	;13
	db 5,5,5
	db 7,7,7

	
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
_SetPalet:   

VDP_0	equ	0xF3DF
VDP_8	equ	0xFFE7
VDP_25	equ	0xFFFA

		ld	a,(VDP_8)				
		or	32						; set TP bit
		ld	(VDP_8),a
        out (0x99),a			; color 0 from the palette
        ld  a,8 + 128
        out (0x99),a
		
		xor a 						; Set pointer to zero.
        out (0x99),a        
        ld  a,16 + 128				; set palette pointer 
        out (0x99),a

		ld	l,e
		ld	h,0
		add	hl,hl
		ld  de,levelcolors			
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ex	de,hl
		
        ld c,0x9A
        ld	b,16
1:      ld	a,(hl)
		inc	hl		
		RLCA
		RLCA
		RLCA
		RLCA
		or	(hl)
		inc	hl
		out	(c),a
		outi
        jr	nz,1b
		
        ret
		
;-------------------------------------
; tile data
;-------------------------------------
pat:
	;incbin DRAGON2_.PAT
	;incbin DDA3.pat
	incbin DDA3NEW.pat,7
col:
	;incbin DRAGON2_.COL
	;incbin DDA3.col
	incbin DDA3NEW.col,7

SAMPLE_END:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



FINISH:













