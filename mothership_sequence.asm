;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; initialize the level assuming tiles and colours in place
just_level_init:
	xor	a
	ld	(anispeed),a
	xor a
	ld	(aniframe),a
	ld	(anispeed),a
	ld	(ms_state),a
	ld	a,8
	ld	(dxmap),a

	ld	hl,0
	ld	(xmap),hl
	ld	bc,xship_rel
	add hl,bc
	ld	(xship),hl
	ld	a,64+64-8
	ld	(yship),a

	call	ms_ctrl.intro
	call	put_ms_sprt
	call	npc_init
	call	plot_enemy

	
	call	 enpage2
	ei
	ld	a,(next_level)
	call	levelinit
	call	 enpage3
	
	ld	a,-1
	ld	(joystick),a	;prevent fake commands
	ei
	ret	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	initialize the mother ship sequence
;	and exit from mother ship 
;
intro_anim:
	di
	call	disscr
	
	xor	a
	ld	(ingame),a
	
	xor a
	ld	(anispeed),a
	ld	a,-2
	ld	(dxmap),a
	ld	a,ms_fly__left
	ld	(ms_state),a
	ld	a,16
	ld  (aniframe),a

	ld	hl,2
	ld	(xmap),hl
	ld	bc,xship_rel-18
	add hl,bc
	ld	(xship),hl
	
	ld	hl,dummy
	ld	de,0x1C00+8*3*32
	call	print_strf
		
	call	 enpage2
	ei
	xor	a
	ld	(cur_level),a
	call	levelinit
	call	 enpage3
	ei

	call	shuttle_init
	
	ld	a,192
	ld	(yship),a	
	call	put_ms_sprt
	call	npc_init
	call	plot_enemy

	call ayFX_SETUP
	
	ld	a,-1
	ld	(joystick),a	;prevent fake commands
	ld	a,1
	ld	(reverse_sat),a
	ld	a,-1
	ld	(ingame),a
	call 	_sat_update
	call	enascr
	ei
	halt	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,

	ld	a,7			; start level sound
	call AFXPLAY
	
	call exit_sequence
	
	ld	hl,2
	ld	(xmap),hl
	ld	bc,xship_rel
	add hl,bc
	ld	(xship),hl
	
fake_main:		
	
	call	test_lev1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run ms FSM and place its sprites in the SAT in RAM
	call	ms_ctrl.intro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; test for game restart
	ld	a,(ms_state)
	cp	ms_reset
	ret	z

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; place MS in the SAT and test for collision
	call	put_ms_sprt

	ld hl,JIFFY
	xor	a
1:
	cp (hl)
	jr z,1b
	ld	(hl),a

	ld	a,(dxmap)
	cp	9
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

	jr fake_main
	

test_lev1:
	ld	ix,runways
	ld	e,(ix+obj_data.x)
	ld	d,(ix+obj_data.x+1)
	ld	c,(ix+obj_data.xsize)
	
	ld	hl,(xship)
	ld	b,16
	
	call CalcCollision
	ret	nc

	ld	hl,warping
	ld	de,0x1C00+8*3*32
	call	print_strf
	
	; set stripes instead of stars
	call	warp_tile

	ld	a,20 	; warping sound
	call AFXPLAY
	
	call	 enpage2
	ei
	ld	a,(next_level)
	call	levelinit

	call	 enpage3
	ei

	call	tile_init
	
	ld	a,ms_reset
	ld	(ms_state),a
	ret	
	
warp_tile:
	ld	de,0x0800+255*8+0x4000
	call	1f
	ld	de,0x1000+255*8+0x4000
	; call	1f
	; ret
	
1:
	di
	ld	a,e
	out (0x99),a
	ld	a,d 
	out (0x99),a
	
	ld	bc,0x398
	ld	a,-1
1:	out (c),a
	nop
	djnz 1b
	ei
	ret

exit_sequence:
	ld  ix,enemies
	ld  de,enemy_data

	ld  (ix+enemy_data.status),1
	ld	(ix+enemy_data.frame),2*4
	ld  (ix+enemy_data.kind),254
	ld	(ix+enemy_data.color),4
	ld  (ix+enemy_data.y),56+64-1
	ld  (ix+enemy_data.x),104-2
	ld  (ix+enemy_data.x+1),0
	add ix,de
	ld  (ix+enemy_data.status),1
	ld	(ix+enemy_data.frame),2*4
	ld  (ix+enemy_data.kind),254
	ld	(ix+enemy_data.color),5
	ld  (ix+enemy_data.y),56+64-1
	ld  (ix+enemy_data.x),104-8-2
	ld  (ix+enemy_data.x+1),0
	
	ld	a,64+64-8
	ld	(yship),a

	ld	hl,(xmap)
	ld	de,xship_rel-18
	add hl,de
	ld	(xship),hl

	ld	b,18
1:	ld	hl,(xmap)
	add hl,de
	ld	(xship),hl
	inc	de
	exx
	ld	b,64
	call	put_ms_sprt.landing
[6]	call 	99f
	exx
	djnz 1b
	
	ld  ix,enemies
	ld  (ix+enemy_data.status),0
	ld  (ix+enemy_data+enemy_data.status),0
	call 	test_runway.fakemain
	ret
	
99:	call 	test_runway.fakemain
	di
	_setvdpwvram (0x3800+2*32)
	ld	b,32
	ld	a,-1
2:	out (0x98),a
	nop
	djnz	2b
	ei	
	ret
	

