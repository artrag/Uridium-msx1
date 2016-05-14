
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


clr_map:
	ld	bc,255*8		; do not remap stars
	ld	hl,miz_buffer

1:	xor a

	rld
	exx
	ld	hl,(clr_table)
	ld	e,a
	ld	d,0
	add hl,de
	ld	a,(hl)
	exx
	rld
	exx
	ld	hl,(clr_table)
	ld	e,a
	ld	d,0
	add hl,de
	ld	a,(hl)
	exx
	rld

	inc hl
	dec bc
	ld	a,c
	or	b
	jr	nz,1b
	ret

clr_table0:
clr_table1:
clr_tableE:
clr_tableD:
	; BLUE
	include m1.asm
clr_table2:
clr_table9:
clr_tableC:
	; GREEN
	include m2.asm
clr_table3:
clr_table6:
clr_tableA:
	; YELLOW
	include m3.asm
clr_table4:
clr_table7:
clr_table8:
	; MAGENTA
	include m4.asm
clr_table5:
clr_tableB:
clr_tableF:
	;	RED
	include m5.asm

; clr_enemy_bullts:
	; db     1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16
	; db	11,11,11,15,11,11,15,11,11,11,15,11,11,11,11,11

	
clr_tab:
	dw clr_table0,clr_table1,clr_table2,clr_table3
	dw clr_table4,clr_table5,clr_table6,clr_table7
	dw clr_table8,clr_table9,clr_tableA,clr_tableB
	dw clr_tableC,clr_tableD,clr_tableE,clr_tableF
	