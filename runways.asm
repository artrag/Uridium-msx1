runways:

lev0	obj_data	(5 + 0) & 127, 256  ,0,0,    64,118

lev1	obj_data	(5+96 ) & 127,2720+8,0,0,136-16,6
lev2	obj_data	(5+208) & 127,2528+8,0,0,136-16,6
lev3	obj_data	(5+312) & 127,2624+8,0,0,152-16,6
lev4	obj_data	(5+440) & 127,2568+8,0,0,152-16,6
lev5	obj_data	(5+616) & 127,2712+8,0,0,136-16,6
lev6	obj_data	(5+696) & 127,2648+8,0,0,120-16,6
lev7	obj_data	(5+824) & 127,2560+8,0,0,264-16,6
lev8	obj_data	(5+928) & 127,2440+8,0,0,184-16,6
lev9	obj_data	(5+1080)& 127,2584+8,0,0,200-16,6
levA	obj_data	(5+1208)& 127,2616+8,0,0,120-16,6
levB	obj_data	(5+1336)& 127,2624+8,0,0,136-16,6
levC	obj_data	(5+1464)& 127,2640+8,0,0,168-16,6
levD	obj_data	(5+1592)& 127,2488+8,0,0,168-16,6
levE	obj_data	(5+1720)& 127,2600+8,0,0,216-16,6
levF	obj_data	(5+1824)& 127,2600+8,0,0,200-16,6

	
test_runway:
	ld	a,(landing_permission)
	and	a
	ret	z
	ld	a,(ms_state)
	cp ms_fly__right
	ret	nz
	ld	a,(dxmap)
	cp	10
	ret	nc

	ld	a,(cur_level)
	and	a
	ld	ix,runways
	jr	z,1f
	ld	b,a
	ld	de,obj_data
2:	add	ix,de
	djnz	2b
	
1:
	ld	e,(ix+obj_data.x)
	ld	d,(ix+obj_data.x+1)
	ld	c,(ix+obj_data.xsize)
	
	ld	hl,(xship)
	ld	b,16
	
	call CalcCollision
	ret	nc

	ld	b,(ix+obj_data.y)
	ld	c,(ix+obj_data.ysize)
	
	ld	a,(yship)
	add	a,-64+6
	ld	d,a
	ld	e,4
	call	CollisionCheck_8b
	ret	nc

	ld	a,13			; landing
	call AFXPLAY
	ld	a,ms_landing
	ld	(ms_state),a
		
	ld	bc,1000		; score for completing a level
	call	add_bc_score_bin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; landing
	
	ld 	b,16
1:	call put_ms_sprt.landing
	push	bc
[3]	call	 .fakemain
	pop bc
	djnz 1b
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; enemies explode
	
	call	.kill_all
	ld 	b,32
1:	push	bc
[3]	call	 .fakemain
	pop bc
	djnz 1b
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; take off
	
	ld	a,15			; take off
	call AFXPLAY

	ld	b,0
1:	call put_ms_sprt.landing
	push	bc
[3]	call	 .fakemain
	pop bc
	inc	b
	ld	a,16
	cp	b
	jr	nz,1b
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ld	hl,defeated
	ld	de,0x1C00+8*3*32
	call	print_strf

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; fly right
		
	ld	a,ms_fly__right
	ld	(ms_state),a
	xor	a
	ld	(dxmap),a
	dec	a
	ld	(joystick),a	;prevent fake commands

	ld	a,(_psg_vol_fix)
	ld	(fade_psg_vol_fix),a
	ld	a,(_scc_vol_fix)
	ld	(fade_scc_vol_fix),a
	
	ld	iyl,6
3:	call	fade_out
	call	ms_ctrl.intro
	call	put_ms_sprt
	
	ld hl,JIFFY
	xor	a
1:	cp (hl)
	jr z,1b
	ld	(hl),a
	
	ld	a,(dxmap)
	cp	maxspeed*2
	jr	z,1f
	inc	a
	ld	(dxmap),a
1:
	ld	hl,(xmap)
	ld	a,(dxmap)
[2] sra a
	ld	e,a
	add a,a
	sbc a,a
	ld	d,a
	add hl,de
	ld	(xmap),hl

	ld	bc,xship_rel
	add hl,bc
	ld	(xship),hl
	
	ld	hl,(xmap)
	inc h
	ld	de,8*(LvlWidth-1)+256
	and a
	sbc hl,de
	jp	c,3b	

	call	PT3_MUTE
	
	ld	a,(fade_psg_vol_fix)
	ld	(_psg_vol_fix),a
	ld	a,(fade_scc_vol_fix)
	ld	(_scc_vol_fix),a
	call 	_SCC_PSG_Volume_balance

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; fly left & explosion loop 
	call	.set_colors_and_tile0	; init explosion tile and scorebar tile 0
	
3:	ld	a,-maxspeed*2
	ld	(dxmap),a

	call	ms_ctrl.intro
	call	put_ms_sprt
	call	.damage_line
	call	.explode_line
	call	.rand_tile
	call	npc_loop
	call	plot_enemy
	
	call	rand8
	and	15
	jr	nz,.noexplosion

	ld hl,JIFFY
	xor	a
1:	cp (hl)
	jr z,1b
	ld	(hl),a
	
	; ld	a,6				; exit
	ld	a,12				; exit
	call AFXPLAY
	setVdp 7,0xFF		; white flash
	call .exposion_wave
	jp	.test_level_limit
	
.noexplosion:

	ld hl,JIFFY
	xor	a
1:	cp (hl)
	jr z,1b
	ld	(hl),a
	
.test_level_limit:	
	ld	hl,(xmap)
	ld	a,(dxmap)
[2] sra a
	ld	e,a
	add a,a
	sbc a,a
	ld	d,a
	add hl,de
	ld	(xmap),hl

	ld	bc,xship_rel
	add hl,bc
	ld	(xship),hl

	ld	hl,(xmap)
	inc h
	ld	bc,-256-8
	add hl,bc
	jp	c,3b
	
	;;;;;;;;;;;;;;;;;;;;;
	; manta exits the screen
	
	ld	hl,(xmap)
	ld	de,xship_rel
	add hl,de
	ld	(xship),hl
	

	ld	de,-maxspeed*2/4
1:	ld	hl,(xship)
	add hl,de
	bit	7,h
	jp	nz,1f
	ld	(xship),hl
	exx
	ld	b,16
	call	put_ms_sprt.landing
	call 	test_runway.fakemain
	exx
	jp	1b
1:		
	ld	a,ms_reset
	ld	(ms_state),a
	
	ld	a,192
	ld	(yship),a
	call	put_ms_sprt
	halt
	
	xor	a					; reset the flag at each passage of level 
	ld	(already_dead),a
	
	ld	a,(cur_level)
	inc	a
	ld	(next_level),a
	cp	16
	ret	c
	
	; congratulations
	; you won
	pop af
	ld	a,-1
	ld	(victory),a
	jp	title_screen
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.fakemain:
	call	npc_loop
	call	enemy_bullet_loop
	call	bull_init	; turn off MS and enemy bullets
	call	bullet_loop
	call	plot_enemy
	xor a
	ld	(reverse_sat),a
	halt
	ret

.kill_all:
	ld  ix,enemies
	ld  b,max_enem
	
1:  push bc
	bit	0,(ix+enemy_data.status)
	jr	z,.next
	
	ld  (ix+enemy_data.status),1	
	ld	(ix+enemy_data.color),10	; start explosion
	ld	(ix+enemy_data.kind),255
	ld	(ix+enemy_data.cntr),2
	ld	(ix+enemy_data.frame),12

	call	rand8
	and	3
	add	a,2			; random enemy explosion
	call AFXPLAY
	
.next:
	ld	de,enemy_data
	add ix,de
	pop	bc
	djnz    1b

	call	bull_init	; turn off MS and enemy bullets

	ret
	
.explode_line:
	ld	de,96
	ld	hl,(xship)
	add	hl,de
	
	srl h
	rr	l
	srl h
	rr	l
	srl h
	rr	l
	
	ld	de,level_buffer
	add	hl,de

	ld	de,LvlWidth-1
	ld	b,16
9:	
	ld	a,(hl)
	and	a
	jr	z,2f
	cp 254
	jr	nz,3f
	ld	(hl),0
	jp 2f
3:	ld	(hl),254
2:	inc	hl
	ld	(hl),0
	add	hl,de
	djnz	9b

	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; plot two random vertical lines of exploding tiles
;
.damage_line:
	ld	de,32
	call	1f
	ld	de,64
	
1:	ld	hl,(xship)
	add	hl,de
	
	srl h
	rr	l
	srl h
	rr	l
	srl h
	rr	l
	
	ld	de,level_buffer
	add	hl,de
	push	hl
	
	ld	de,LvlWidth
	ld	b,16
9:	
	ld	a,(hl)
	and	a
	jr	z,2f
	exx
	call rand8
	exx
	and 3
	jr	nz,2f
	ld	(hl),254
2:	add	hl,de
	djnz	9b
	
	pop	hl
	ld	de,4
	add	hl,de
	
	ld	de,LvlWidth
	ld	b,16
	ld	a,254
9:	cp (hl)
	jr	nz,2f
	ld	(hl),0
2:	add	hl,de
	djnz	9b

	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; shapes
.rand_tile:
	ld	hl,(xship)			; take random data
	ld	de,0x4000
	add	hl,de
	ld	de,0x0800+254*8+0x4000
	call	1f
	ld	de,0x1000+254*8+0x4000
	call	1f
	ld	de,0x2800+254*8+0x4000
	call	1f
	ld	de,0x3000+254*8+0x4000
	
1:	di
	ld	a,e
	out (0x99),a
	ld	a,d 
	out (0x99),a
	ld	bc,0x898
1:	outi
	jp	nz,1b
	ei
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set colours and tile 0 in the score bar
;
.set_colors_and_tile0:
	ld	c,0xE0
	ld	de,0x0000+254*8+0x4000
	call	2f
	ld	de,0x2000+254*8+0x4000
	call	2f
	ld	c,0x00
	ld	de,0x0000+0*8+0x4000
	call	2f
	ld	de,0x2000+0*8+0x4000
	
2:	di
	ld	a,e
	out (0x99),a
	ld	a,d 
	out (0x99),a
	ld	b,0x08
	ld	a,c
3:	out (0x98),a
	nop
	djnz 3b
	ei
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; try to set a line of sprite explosions	
.exposion_wave:
	ld	hl,(xmap)
	ld	de,256
	and	a
	sbc	hl,de
	ret c
	
	ld	hl,(xmap)
	ld	de,8*(LvlWidth)-128
	sbc hl,de
	ret	nc

	call	rand8
	and	15
	add	a,64	; Y off set
		
	ld	de,-64
	ld	hl,(xmap)
	add	hl,de

	ld  ix,enemies
	ld	iyh,max_enem
	ld  de,enemy_data
1:
	bit	0,(ix+enemy_data.status)
	jr  nz,.next_sprt

	ld  (ix+enemy_data.status),1
	ld	(ix+enemy_data.color),10	; start explosion
	ld	(ix+enemy_data.kind),255
	ld	(ix+enemy_data.cntr),2
	ld	(ix+enemy_data.frame),12
	ld  (ix+enemy_data.y),a
	push	af
	exx
	call	rand8
	and	15
	exx
	ld	c,a
	ld	b,0

	add	hl,bc 
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h

	exx
	call	rand8
	and	63
	add	a,32
	exx
	pop	bc
	add	a,b	
	
	add ix,de
	dec	iyh
	ret	z
	cp	191-16
	jr	c,1b
	ret

.next_sprt
	add ix,de
	dec	iyh
	ret	z
	jr	1b
	
fade_out:
	dec	iyl
	ret	nz
	
	ld	iyl,6
	ld	a,(_psg_vol_fix)
	dec	a
	cp -16
	jr	z,98f
	ld      (_psg_vol_fix),a
98:
	ld      a,(_scc_vol_fix)
	dec	a
	cp -16
	jr	z,98f
	ld      (_scc_vol_fix),a
98:	call 	_SCC_PSG_Volume_balance
	
99:	ret
