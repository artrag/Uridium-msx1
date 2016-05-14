
add16_de:
	push	hl
	ld hl,16
	add hl,de
	ex de,hl
	pop hl
	ret	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	load sprites in vram

sprite_init:
	di
	ld	hl,test_spt
	ld	a,(sprite_3c)
	and	a
	jr	z,1f
	ld	hl,test_spt_3c
1:	ld	de,level_buffer
	call	mom_depack_rom
	ld	hl,level_buffer
	_setvdpwvram 0x3800
	call	write_256
	
	_setvdpwvram 0x1B80				 ; sprites in the score bar
	ld	hl,scorebar_sat
	ld	bc,0x8098
	otir

	ld	hl,line1
	ld	de,0x1C08+32
	call	print_str

	ld	hl,0
	ld	(score_bin),hl
	ld	(score_bin+2),hl

	ld	a,7
	ld	(lives_bin),a

	ld	hl,lives
	ld	de,lives+1
	ld	(hl),13
	ld	bc,14-1				; lives and score are strings in ram
	ldir

	;	set Manta icon
	di
	_setvdpwvram  0x1C08
	ld	hl,ram_tileset+110*8
	ld	bc,0x898
	otir
	_setvdpwvram  (0x1C08+16)
	ld	b,0x8
	otir
	_setvdpwvram  (0x1C08+4*32)
	ld	b,0x8
	otir
	_setvdpwvram  (0x1C08+4*32+16)
	ld	b,0x8
	otir
	
	;	set Uridium sign

	ld	de,0x1C00+16*32+ 8*1
	ld hl,ram_tileset+95*8
	ld	b,12
1:	push	bc
	call	setwrtvram	
	ld	b,0x8 
	otir
	call	add16_de
	pop	bc
	djnz	1b
	
	ld hl,ram_tileset+104*8
	call	setwrtvram	
	ld	b,0x8 
	otir
	call	add16_de
	
	ld hl,ram_tileset+107*8
	ld	b,3	
1:	push	bc
	call	setwrtvram	
	ld	b,0x8 
	otir
	call	add16_de
	pop	bc
	djnz	1b
	
	xor a
	ld	(reverse_sat),a

	ld	hl,ram_sat
	ld	de,ram_sat+1
	ld	bc,127
	ld	(hl),a
	ldir

	ret

