test_1up:
	and	a
	sbc	hl,de
	ret	nc
	add	hl,de	; hl = score
	add	hl,bc	; hl = score + newpts
	and	a
	sbc	hl,de
	ret	c		; if newscore < 20.000 returns
	exx
	ld	a,18	; one up
	call	AFXPLAY
	ld	c,1							; show lives on screen 
	call	add_c_lives_bin
	exx
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	in BC the score to be added
;
add_bc_score_bin:
	ld	hl,(score_bin)
	ld	de,0x4E20	; 20.000 points
	call	test_1up
	ld	hl,(score_bin)
	ld	de,0x9C40	; 40.000 points
	call	test_1up
	ld	hl,(score_bin)
	ld	de,0xEA60	; 60.000 points
	call	test_1up
	
	
	ld	hl,(score_bin)
	add	hl,bc
	ld	(score_bin),hl
	ld	e,l
	ld	d,h
	ld	hl,(score_bin+2)
	ld	bc,0
	adc	hl,bc
	ld	(score_bin+2),hl
	
	ld	bc,score-4
	call	long2ascii
	
	; ld	a,13		; CR
	; ld	(de),a
	
	ld	hl,score
	ld	de,0x1C08+9*32
	jp	print_str

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	in C the lives to be added
add_c_lives_bin:
	ld	a,(lives_bin)
	add	a,c
	jr	1f
sub_c_lives_bin:
	ld	a,(lives_bin)
	sub	a,c
1:	daa
	ld	(lives_bin),a
	ld	e,a
	ld	hl,lives
[4]	rrca
    and  $0f
	add  a,'0'
	ld	(hl),a
	inc	hl
	ld	a,e
	and  $0f
	add  a,'0'
	ld	(hl),a
	; inc	hl
	; ld	a,13		; CR
	; ld	(hl),a

	ld	hl,lives					; show lives on screen 
	ld	de,0x1C08+8*32
	jp	print_str


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

line1:
	db	"Score ",13
line2:
	db	"00",13
	
	
print_str:
	; in hl = string terminated by 13
	; in de = vram position
1:
	ld	a,(hl)
	cp	13
	ret	z
	call	print
	inc	hl
	ld	a,16
	add	a,e
	ld e,a
	ld a,d
	adc a,0
	ld d,a
	jp	1b
	

	
print:
	; in A = char
	; in de = vram position
	push	hl
	push	de
	push	af
		
	add	a,1-'!'
	
	ld	l,a
	ld	h,0
[3]	add hl,hl
	ld	bc,ram_tileset
	add hl,bc
	
	ld bc,0x0498
	call	plot_tile

	ld	a,4*32
	add	a,e
	ld e,a
	ld a,d
	adc a,0
	ld d,a

	ld bc,0x0498
	call	plot_tile

	pop	af
	pop	de
	pop	hl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
land_now:
	db	"Land now",13
dummy:
	db	"        ",13
warping:
	db	" Warping",13
defeated:
	db	"Defeated",13
GameOver:
	db	"GameOver",13
levelnames:
	db	"  Zinc  ",13
	db	"  Lead  ",13
	db	" Copper ",13
	db	" Silver ",13
	db	"  Iron  ",13
	db	"  Gold  ",13
	db	"Platinum",13
	db	"Tungsten",13
	db	" Iridon ",13
	db	"Kallisto",13
	db	"TriAlloy",13
	db	"Quadmium",13
	db	"Ergonite",13
	db	"Galactus",13
	db	"Uridium ",13
	
	
print_strf:
	; in hl = string terminated by 13
	; in de = vram position
1:
	ld	a,(hl)
	cp	13
	ret	z
	call	printf
	inc	hl
	ld	a,16
	add	a,e
	ld e,a
	ld a,d
	adc a,0
	ld d,a
	jp	1b

printf:
	; in A = char
	; in de = vram position
	push	hl
	push	de
	push	af
		
	add	a,1-'!'
	
	ld	l,a
	ld	h,0
[3]	add hl,hl
	ld	bc,ram_tileset
	add hl,bc
	
	ld bc,0x0898
	call	plot_tile

	pop	af
	pop	de
	pop	hl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
plot_tile:	
	di
	ld	a,e
	out (0x99),a
	ld	a,d 
	or	0x40
	out (0x99),a
	
	ld	c,0x98
	xor	a
1:	outi	
	nop
	nop
	nop
	out (c),a
	jp nz,1b
	ei
	ret

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IN HL:DE INPUT
; BC POINTS TO OUTPUT

long2ascii:
					; HL = HIGH WORD
	PUSH	DE
	EXX
	POP		HL		; HL' = LOW WORD
	EXX

	LD	E,C
	LD	D,B

	LD	BC,-1000000000/0x10000 -1
	EXX
	LD	BC,-1000000000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-100000000/0x10000 -1
	EXX
	LD	BC,-100000000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-10000000/0x10000 -1
	EXX
	LD	BC,-10000000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-1000000/0x10000 -1
	EXX
	LD	BC,-1000000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-100000/0x10000 -1
	EXX
	LD	BC,-100000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-10000/0x10000 -1
	EXX
	LD	BC,-10000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-1000/0x10000 -1
	EXX
	LD	BC,-1000&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-100/0x10000 -1
	EXX
	LD	BC,-100&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-10/0x10000 -1
	EXX
	LD	BC,-10&0xFFFF
	EXX
	CALL	NUM1

	LD	BC,-1/0x10000 -1
	EXX
	LD	BC,-1&0xFFFF
	EXX

NUM1:
	LD	A,'0'-1	 ; '0' IN THE TILESET

1:
	INC A
	EXX
	add HL,BC		; low word
	EXX
	ADC HL,BC		; high word
	jp	C,1b

	EXX
	SBC HL,BC		; low word
	EXX
	SBC HL,BC		; high word

	LD	(DE),A
	INC DE
	RET
