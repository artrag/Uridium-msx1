
	
text:
	db	"HEWSON & Trilobyte",13
	db	"presents",13
	db	127,128,129,130,131,132,133,134,13
	db	135,136,137,138,136,139,140,141,13
	db	"@ Graftgold Ltd.",13
	db	"Original C64 design:",13
	db	"Andrew Braybrook",13
	db	"MSX remake:",13
	db	"ARTRAG - code",13
	db	"Toni Galvez - graphic & sfx",13
	db	"John Hassink - music",13
	db	"Eric Boez - cover & testing",13
	db	"Bieno Marti - testing",13

	
	

prstr:
	ex de,hl
	call setwrtvram
	ex de,hl
1:	ld   a,(de)
	inc  de
	cp	13
	ret  z
	add	a,-'!'+1
	out (0x98),a
	jr   1b

cls:
	_setvdpwvram 0x1800
	xor	a
	ld	b,192
1:	call set4
	djnz	1b
	ret
	
print_page:
	di
	call	cls
	
	ld	de,text
	ld	hl,0x1800+32*1+7
	call	prstr
	ld	hl,0x1800+32*3+12
	call	prstr
	ld	hl,0x1800+32*5+12
	call	prstr
	ld	hl,0x1800+32*6+12
	call	prstr
	ld	hl,0x1800+32*8+8
	call	prstr
	ld	hl,0x1800+32*10+1
	call	prstr
	ld	hl,0x1800+32*11+9
	call	prstr
	ld	hl,0x1800+32*13+1
	call	prstr
	ld	hl,0x1800+32*14+8
	call	prstr
	ld	hl,0x1800+32*15+3
	call	prstr
	ld	hl,0x1800+32*16+2
	call	prstr
	ld	hl,0x1800+32*17+5
	call	prstr
	ld	hl,0x1800+32*18+3
	call	prstr
	ret
	
	; ld	a,(victory)
	; and	a
	; ret	z
	
	; _setvdpwvram (0x1800+32*10)
	; xor	a
	; ld	(victory),a		; avoid greetings if you play another time and die
	; ld	b,a
; 1:	out	(0x98),a
	; djnz	1b
	; ld	b,32
; 1:	out	(0x98),a
	; djnz	1b
	
	; ld	de,greetings
	; ld	hl,0x1800+32*10+5
	; call	prstr
	; ld	hl,0x1800+32*12+3
	; call	prstr
	; ld	hl,0x1800+32*13+2
	; call	prstr
	; ld	hl,0x1800+32*14+7
	; call	prstr
	; ld	hl,0x1800+32*15+8
	; call	prstr
	; ld	hl,0x1800+32*16+8
	; call	prstr
	; ld	hl,0x1800+32*17+6
	; call	prstr
	; ld	hl,0x1800+32*18+8
	; call	prstr
	
	; ret
	

	
set4:
	repeat	4
	out	(0x98),a
	push	af
	pop		af
	endrepeat
	ret

plot_title_screen:
	di
	call	disscr
	
	; set shapes	
	_setvdpwvram 0x0000
	repeat 3
	ld	hl,ram_tileset
	call	write_256
	endrepeat
	
	; set colours
	_setvdpwvram 0x2000
	ld	bc,0x0003
1:	ld	a,0x51
	call	set4
	ld	a,0x41
	call	set4
	djnz	1b
	dec	c
	jr	nz,1b
	
	_setvdpwvram (0x2000+95*8)
	ld	b,8*8
	ld	a,0x60
1:	out	(0x98),a
	djnz	1b
	ld	b,7*8
	ld	a,0xD0
1:	out	(0x98),a
	djnz	1b

	xor	a
	ld	(toshiba_switch),a

	; ld	a,(victory)
	; and	a
	; push	af
	; call	z,intro_music
	; pop		af
	; call	nz,ending_music

	call	intro_music

	call	menu0
	
1:	ld	a,(ayFX_PRIORITY)
	inc	a
	jr	nz,1b				; wait for last sfx
	
	call	PT3_MUTE
	ret
	


;Ln B_7 B_6 B_5 B_4 B_3 B_2 B_1 B_0
; 0 "7" "6" "5" "4" "3" "2" "1" "0"
; 1 ";" "]" "[" "\" "=" "-" "9" "8"
; 2 "B" "A" ??? "/" "." "," "'" "`"
; 3 "J" "I" "H" "G" "F" "E" "D" "C"
; 4 "R" "Q" "P" "O" "N" "M" "L" "K"
; 5 "Z" "Y" "X" "W" "V" "U" "T" "S"
; 6 F3 F2  F1 CODE CAP GRAPH CTR SHIFT
; 7 RET SEL BS STOP TAB ESC F5  F4
; 8 RIGHT DOWN UP LEFT DEL INS HOME SPACE

;;;;;;;;;;;;;;;;;;;;
; Keyboard testing
ayFX_test:

		ld	a,(ayFX_PRIORITY)
		cp      255
		ret     nz              	; play only if no sfx is active
		
		ld      e,3				; 3 "J" "I" "H" "G" "F" "E" "D" "C"
		call    checkkbd
		ld      b,8
		ld      c,a
1:
		ld      a,b
		dec     a
		ld      l,a
		ld      a,c
		add     a,a
		ld      c,a
		push    bc
		ld      a,l
		call    nc,_ayFX_INIT
		pop     bc
		djnz    1B
		
		ld      e,4				; 4 "R" "Q" "P" "O" "N" "M" "L" "K"
		call    checkkbd
		ld      b,8
		ld      c,a
1:
		ld      a,b
		dec     a
		add		a,8
		ld      l,a
		ld      a,c
		add     a,a
		ld      c,a
		push    bc
		ld      a,l
		call    nc,_ayFX_INIT
		pop     bc
		djnz    1B
		
		ld      e,5				; 5 "Z" "Y" "X" "W" "V" "U" "T" "S"
		call    checkkbd
		ld      b,8
		ld      c,a
1:
		ld      a,b
		dec     a
		add		a,16
		ld      l,a
		ld      a,c
		add     a,a
		ld      c,a
		push    bc
		ld      a,l
		call    nc,_ayFX_INIT
		pop     bc
		djnz    1B
		ret
_ayFX_INIT:
		cp	n_sfx+1
		ret	nc
		jp	AFXPLAY
		
intro_music:
	di
	call	enpage3
	ld		hl,mus_intro-100+16
	call	PT3_INIT
	ld		hl,mus_intro
	call 	wavemap_init
	call	ayFX_SETUP
	call	enpage2
	ei
	ret
ending_music:
	di
	call	enpage3
	ld		hl,mus_end-100+16
	call	PT3_INIT
	ld		hl,mus_end
	call 	wavemap_init
	call	ayFX_SETUP
	call	enpage2
	ei
	ret