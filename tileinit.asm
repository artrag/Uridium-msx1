
;
;	load tile sets in vram
tile_init:
	
	ld	a,(next_level)
	ld	l,a
	ld	h,0
	add	hl,hl
	ld	bc,clr_tab
	add	hl,bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	(clr_table),bc
	
l1_15_init:
	; set meta pnt tables
	ld	hl,meta_pnt_table_u_miz
	ld	de,meta_pnt_table_u
	call	mom_depack_rom
	
	ld	hl,meta_pnt_table_d_miz
	ld	de,meta_pnt_table_d
	call	mom_depack_rom
	
	; fake meta-tile for explosion
	ld	hl,meta_pnt_table_u+254
	ld	b,8
1:	ld	(hl),254
	inc	h
	djnz	1b 
 
 	ld	a,(toshiba_switch)
	and	a
	jp	nz,toshiba_vram_layout
	
;  TMS
	ld	hl,chr_tileset1_common
	ld	de,miz_buffer
	call	mom_depack_rom
	ld	hl,chr_tileset1_up
	ld	de,miz_buffer+n_common_tiles1*8
	call	mom_depack_rom
	ld	de,0x0800
	call	write_2k
	ld	hl,chr_tileset1_dw
	ld	de,miz_buffer+n_common_tiles1*8
	call	mom_depack_rom
	ld	de,0x1000
	call	write_2k

	ld	de,0x0800+255*8
	call	set_star_shape
	ld	de,0x1000+255*8
	call	set_star_shape

	ld	hl,chr_tileset2_common
	ld	de,miz_buffer
	call	mom_depack_rom
	ld	hl,chr_tileset2_up
	ld	de,miz_buffer+n_common_tiles2*8
	call	mom_depack_rom
	ld	de,0x2800
	call	write_2k
	ld	hl,chr_tileset2_dw
	ld	de,miz_buffer+n_common_tiles2*8
	call	mom_depack_rom
	ld	de,0x3000
	call	write_2k

	ld	de,0x2800+255*8
	call	set_star_shape
	ld	de,0x3000+255*8
	call	set_star_shape
	
	ld	hl,clr_tileset2_common
	ld	de,miz_buffer
	call	mom_depack_rom
	ld	hl,clr_tileset2
	ld	de,miz_buffer+n_common_tiles2*8
	call	mom_depack_rom
	call	clr_map
	ld	de,0x0000
	call	write_2k
	
	ld	de,0x0000+255*8
	call	set_star_color

	ld	hl,clr_tileset1_common
	ld	de,miz_buffer
	call	mom_depack_rom
	ld	hl,clr_tileset1
	ld	de,miz_buffer+n_common_tiles1*8
	call	mom_depack_rom
	call	clr_map
	ld	de,0x2000
	call	write_2k
	
	ld	de,0x2000+255*8
	call	set_star_color

	ret

toshiba_vram_layout:

; Toshiba
	ld	hl,chr_tileset1_common
	ld	de,miz_buffer
	call	mom_depack_rom
	ld	hl,chr_tileset1_up
	ld	de,miz_buffer+n_common_tiles1*8
	call	mom_depack_rom
	ld	de,0x0800
	call	write_2k
	ld	hl,chr_tileset1_dw
	ld	de,miz_buffer+n_common_tiles1*8
	call	mom_depack_rom
	ld	de,0x1000
	call	write_2k

	ld	de,0x0800+255*8
	call	set_star_shape
	ld	de,0x1000+255*8
	call	set_star_shape
	
	ld	hl,clr_tileset1_common
	ld	de,miz_buffer
	call	mom_depack_rom
	ld	hl,clr_tileset1
	ld	de,miz_buffer+n_common_tiles1*8
	call	mom_depack_rom
	call	clr_map
	ld	de,0x2800
	call	write_2k
	ld	de,0x3000
	call	write_2k
	
	ld	de,0x2800+255*8
	call	set_star_color
	ld	de,0x3000+255*8
	call	set_star_color
	ret
	
shuttle_init:
; set meta pnt tables
	ld	hl,meta_pnt_table_u_ms_miz
	ld	de,meta_pnt_table_u
	call	mom_depack_rom
	
	ld	hl,meta_pnt_table_d_ms_miz
	ld	de,meta_pnt_table_d
	call	mom_depack_rom
	
	; fake meta-tile for explosion
	
	ld	hl,meta_pnt_table_u+254
	ld	b,8
1:	ld	(hl),254
	inc	h
	djnz	1b 
 
; set patterns
	ld	hl,chr_tileset0_u_ms
	ld	de,miz_buffer
	call	mom_depack_rom
	ld	de,0x0800
	call	write_2k
		
	ld	hl,chr_tileset0_d_ms
	ld	de,miz_buffer
	call	mom_depack_rom
	ld	de,0x1000
	call	write_2k

	ld	hl,chr_tileset1_u_ms
	ld	de,miz_buffer
	call	mom_depack_rom
	ld	de,0x2800
	call	write_2k

	ld	hl,chr_tileset1_d_ms
	ld	de,miz_buffer
	call	mom_depack_rom
	ld	de,0x3000
	call	write_2k

; set colours
	ld	hl,clr_table1
	ld	(clr_table),hl

	ld	hl,clr_tileset1_ms
	ld	de,miz_buffer
	call	mom_depack_rom
	call	clr_map
	ld	de,0x0000
	call	write_2k
	ld	de,0x0000+255*8
	call	set_star_color

	ld	hl,clr_tileset0_ms
	ld	de,miz_buffer
	call	mom_depack_rom
	call	clr_map
	ld	de,0x2000
	call	write_2k
	ld	de,0x2000+255*8
	call	set_star_color

	ld	a,(toshiba_switch)
	and	a
	jp	z,1f
	
	; Toshiba
	ld	de,0x2800
	call	write_2k
	ld	de,0x3000
	call	write_2k
	
	ld	de,0x2800+255*8
	call	set_star_color
	ld	de,0x3000+255*8
	call	set_star_color
1:

	ld	de,0x0800+255*8
	call	set_star_shape
	ld	de,0x1000+255*8
	call	set_star_shape
	
	ld	a,(toshiba_switch)
	and	a
	ret	nz
	
	ld	de,0x2800+255*8
	call	set_star_shape
	ld	de,0x3000+255*8
	call	set_star_shape
	ret
_out:
	out (c),a
	ret
set_star_shape:
	di
	ld	a,e
	out (0x99),a
	ld	a,d 
	or	0x40
	out (0x99),a
	
	ld	c,0x98
	ld	a,2
	call	_out
	ld	a,7
	call	_out
	ld	a,2
	call	_out
	xor	a
[5]	call	_out
	ei
	ret
	
set_star_color:
	di
	ld	a,e
	out (0x99),a
	ld	a,d 
	or	0x40
	out (0x99),a
	
	ld	c,0x98
	ld	a,0x70
	call	_out
	ld	a,0xf0
	call	_out
	ld	a,0x70
	call	_out
	xor a
[5]	call	_out
	ei
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; *** tile set data in rom ***
chr_tileset1_common:
	incbin chr1_common.miz
chr_tileset2_common:
	incbin chr2_common.miz

clr_tileset1_common:
	incbin clr1_common.miz
clr_tileset2_common:
	incbin clr2_common.miz

chr_tileset1_up:
	incbin chr1_up.miz
chr_tileset1_dw:
	incbin chr1_dw.miz
clr_tileset1:
	incbin clr1_ud.miz

chr_tileset2_up:
	incbin chr2_up.miz
chr_tileset2_dw:
	incbin chr2_dw.miz
clr_tileset2:
	incbin clr2_ud.miz
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
; *** shuttle tile set data in rom ***
	;code	page 0,1	
chr_tileset0_u_ms:
	incbin chr_plain1u_ms.miz
	;code	page 0,1	
chr_tileset0_d_ms:
	incbin chr_plain1d_ms.miz
	;code	page 0,1	
chr_tileset1_u_ms:
	incbin chr_plain2u_ms.miz
	;code	page 0,1	
chr_tileset1_d_ms:
	incbin chr_plain2d_ms.miz

	;code	page 0,1	
clr_tileset0_ms:
	incbin clr_plain1_ms.miz
	;code	page 0,1	
clr_tileset1_ms:
	incbin clr_plain2_ms.miz

	;code	page 0,1	
meta_pnt_table_u_miz:
	incbin meta_pnt_table_u.miz
	;code	page 0,1	
meta_pnt_table_d_miz:
	incbin meta_pnt_table_d.miz

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;code	page 0,1	
meta_pnt_table_u_ms_miz:
	incbin meta_pnt_table_u_ms.miz
	;code	page 0,1	
meta_pnt_table_d_ms_miz:
	incbin meta_pnt_table_d_ms.miz
