;p0 = 187 
;p1 = 122 
;p2 = 139
;p3 = 132
;
; -----------------------------
; smooth scroller engine
; Uridium 64K
; Trilobyte 2014
; ------------------------------
	incdir levels/
	incdir mus/
	incdir afx/
	incdir graphic/

	output URDIUM64.rom
	
	defpage 0,0x0000,0x4000
	defpage 1,0x4000,0x4000
	defpage 2,0x8000,0x4000
	defpage 3,0x8000,0x4000

; ------------------------------
	code page 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include macros.asm	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code
checkkbd:
	in	a,(0aah)
	and 011110000B			; upper 4 bits contain info to preserve
	or	e
	out (0aah),a
	in	a,(0a9h)
	ld	l,a
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code	
write_256:
	ld	bc,0x0098
[8]	otir
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code		
enascr:
	ld	   a,(_vdpReg + 1)
	or	   #40
	jr	   1f
disscr:
	ld	   a,(_vdpReg + 1)
	and	   #bf
1:	out	   (#99),a
	ld	   (_vdpReg + 1),a
	ld	   a,1 + 128
	out	   (#99),a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code	
setwrtvram:
	di
	ld	a,e
	out (0x99),a
	ld	a,d
	or 0x40
	out (0x99),a
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; write 2K while ints are active from miz_buffer
; in: de vram address
	code	
write_2k:
	ex	de,hl
	set	6,h
	ld	c,0x99
	ld	de,16
	exx
	ld	hl,miz_buffer
	ld 	e,127
	ld	c,0x98
2:	di
	exx
	out (c),l
	out (c),h	;c' = 0x99, HL' with write setup bit set
	add hl,de	;de' = 16
	exx
	ld b,16
1:	outi		;c = 0x98
	jp nz,1b
	ei
	dec e
	jp nz,2b
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		   defb 0x02 ; Reg# 0 000000[M3][EV]
;		   defb 0x62 ; Reg# 1 [4/16k][BLANK][IE][M1][M2]0[SIZE][MAG]
;		   defb 0x06 ; Reg# 2 0000[NAME TABLE BASE ADDRESS]			 = 1800h

;		   defb 0x9F ; Reg# 3 [COLOR BASE ADDRESS]					 = 2000h ; hybrid mode for colors
;		   defb 0xFF ; Reg# 3 [COLOR BASE ADDRESS]					 = 2000h ; regular mode for colors

;		   defb 0x1F ; Reg# 3 [COLOR BASE ADDRESS]					 = 0000h ; hybrid mode for colors
;		   defb 0x7F ; Reg# 3 [COLOR BASE ADDRESS]					 = 0000h ; regular mode for colors

;		   defb 0x00 ; Reg# 4 00000[PATTERN GENERATOR BASE ADDRESS]	 = 0000h ; hybrid mode for patterns
;		   defb 0x03 ; Reg# 4 00000[PATTERN GENERATOR BASE ADDRESS]	 = 0000h ; regular mode for patterns

;		   defb 0x04 ; Reg# 4 00000[PATTERN GENERATOR BASE ADDRESS]	 = 2000h ; hybrid mode for patterns
;		   defb 0x07 ; Reg# 4 00000[PATTERN GENERATOR BASE ADDRESS]	 = 2000h ; regular mode for patterns

;		   defb 0x36 ; Reg# 5 0[SPRITE ATTRIBUTE TABLE BASE ADDRESS] = 1b00h
;		   defb 0x07 ; Reg# 6 00000[SPRITE PTRN GNRTR BASE ADDRESS]	 = 3800h
;		   defb 0x01 ; Reg# 7 [TEXT COLOR 4bts][BACKDROP COLOR 4bts]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code
disp_page1:			; page 1 active
	_setVdp 3,0x9F	;	colours at 0x2000	(hybrid)
	_setVdp 4,0x03	;	patterns at 0x0000	(regular: used 0x0800 0x1000)
	ret
	code
disp_page0:			; page 0 active
	_setVdp 3,0x1F	;	colours at 0x0000	(hybrid)
	_setVdp 4,0x07	;	patterns at 0x2000	(regular: used 0x2800 0x3000)
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include isr.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include mizer.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
; priority -  sfx number
; 0 	  - 01 Wave incoming, Player Explode, 13 Landing, 14 Landing alert,15 Take off, 16 Pause1, 17 Pause2, 18 Live Up, 19 Game over, 20 Warping.
; 1 	  - 11 ground explode,12 ground explode, 06 Exit,07 Start Level Sound
; 2 	  - 02,03,04,05 Enemy explode.
; 3 	  - 00 Ms fire,10 MS bullets hit solid wall
; 4 	  - 08 Enemy shoot.
AFXPLAY:	
	ld	c,0
	jp	ayFX_INIT	


AFXSTOP 	equ ayFX_END	; --- End of an ayFX stream ---
AFXFRAME 	equ ayFX_FRAME	; --- PLAY A FRAME OF AN ayFX STREAM ---
ROUT		equ	PT3_ROUT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sfxBank_miz:
	incbin	sfx.miz
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ms_ani:
	include ms_demo_ani.asm
ms_spt:
	incbin ms_demo_frm.bin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -----------------------------
; 	Parameters

	include parametrs.asm
maxspeed:					equ 16		; the actual speed is divided by 4
max_enem:					equ 8		; max 12
max_enem_bullets:			equ 3
max_bullets:				equ 2		; max number of enemies*2 + ms_bullets + enem_bullets + 3 for ms	<= 32 sprites
assault_wave_timer_preset:	equ	3*60	; a wave each 3 seconds
enemy_bullet_speed:			equ	2	
xship_rel:					equ (128-8)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include intro.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mus_mute:
	db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	incbin UR_mute.BIN
mus_intro:
	db 00,00,01,01,09,03,01,03,13,00,00,00,00,00,00,00
	incbin UR_TITLE.MIZ
mus_end:
	db 00,05,15,15,06,00,00,15,00,00,00,00,00,00,00,00
	incbin UR_ENDING.MIZ
mus_red:
	db 00,06,00,06,13,13,13,13,13,00,00,06,00,00,00,00
	incbin UR_RED.MIZ
mus_green:
	db 00,05,14,06,05,05,05,05,05,00,00,00,00,00,00,00
	incbin UR_GREEN.MIZ
mus_blue:
	db 00,15,14,12,15,15,15,15,15,00,00,00,06,12,08,00
	incbin UR_BLUE.MIZ
	
wavemap_init:
	ld	de,_waves			; set waves
	ld	bc,16
	ldir
	ret
n_musics equ 3
music_tables:
	dw	mus_blue,mus_red,mus_green,mus_end,mus_intro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include options.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	code  @	4000h, page 1
rom_header:
	db "AB"		; rom header
    dw initmain
    ds    12
    dz 'TRI004'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include sprtinit.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include rominit64.asm	
	include PT3-ROM.ASM
	include AYFX-ROM.ASM
	include enemies.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	INCLUDE SCCaudio.asm
	INCLUDE SCCWAVES.ASM
	INCLUDE SCCDETEC.ASM	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include show_instructions.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include attract_mode.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initmain:
	ld	a,2
	call 0x005f

	di
	call	_hb_10p_hb20p_patch	; patch for crappy msx1 machines
	call 	SCCINIT			; look for the SCC slot
	call	search_slotram	; look for the ram slot 
	call	search_slot		; look for the slot of our rom

	ld	a,(slotram)
	ld	i,a					; save for later use
	
	;---------------------
	call	setrampage2		; set ram in page 2
	ld sp,0C000h			; place manually the stack
	call	setrompage3		; set rom in page 3 <- old ram data cannot be accessed
	;---------------------

	ld	hl,0xC000			; now page 3 is in 0x8000-0xBFFF
	ld	de,0x8000
	ld	bc,0x4000
	ldir
	
	;---------------------
	ld		a,i				; recover ram in page 3
	call	setslotpage3	; NB two bytes at the end of the page get corrupted by this call!
	ld sp,0F380h			; place manually the stack
	call	setrompage2		; set rom in page 2
	;---------------------
	
enpage2 equ	setrompage2
enpage3 equ	setrampage2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; actual main
	ld	a,(_vdpReg+1)
	or 2
	ld	(_vdpReg+1),a
	
	_setVdp 7,0x00
		
	xor	a
	ld	(visible_sprts),a
	ld	(ingame),a
	ld	(PT3_SETUP),a
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ld		a,(0x002B)
	and 	0x80
	ld 		(vsf),a     	; 0=>60Hz, !0=>50Hz
	ld      a,1
	ld      (cnt),a			; reset the tic counter

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call	_set_r800		; try to set R800 rom mode on TR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call	_set_goodmode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	xor	a
	; inc	a
	ld	(victory),a			; none has completed the game yet

	call	setrompage0		; 48K of rom are active - bios is excluded
							; from here interrupts are disabled
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call	ayFX_SETUP
	
	xor	a			; range [-15,0]
	ld      (_psg_vol_fix),a
	ld      (_scc_vol_fix),a
	ld		(_sfx_vol_fix),a
	
	call 	_SCC_PSG_Volume_balance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	xor	a
	ld	(god_mode),a		; god mode trick is off
	ld	(sprite_3c),a		; the 3 colour sprite trick is off
	inc a
	ld	(game_speed),a		; valid values 1 2 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
title_screen:
	ld sp,0F380h			; place manually the stack
	
	call 	ayFX_END
	call	PT3_MUTE
	call	rand8_init
	
	di
	call	disscr
	_setVdp 3,0xFF	;	colours at 0x2000	(regular mode for colours)
	_setVdp 4,0x03	;	patterns at 0x0000	(regular: used 0x0800 0x1000)
	
	xor	a
	ld	(visible_sprts),a
	ld	(ingame),a
	dec	a
	ld	(joystick),a
	ld	(old_joystick),a
	
	call	enpage2
	ld	hl,rom_tileset_miz 	;  tile set to be expanded in ram
	ld	de,ram_tileset
	call	mom_depack_rom
	ld	a,0x80
	ld	(ram_tileset+0x0067),a	; last minute patch
	ld	a,0x30
	ld	(ram_tileset+0x0008),a	; last minute patch
	ld	(ram_tileset+0x0009),a	; last minute patch
	ld	(ram_tileset+0x000A),a	; last minute patch
	ld	(ram_tileset+0x000B),a	; last minute patch
	ld	(ram_tileset+0x000D),a	; last minute patch
	
	call	enpage3
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; plot splash screen
	; menu goes here !!	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	di
	_setvdpwvram 0x1b00
	ld	a,0xd0
	out	(0x98),a
	ei

	ld	a,(victory)
	and	a
	jr	nz,1f
	call	enpage3
	call 	show_manta
	call	enpage2
	ei
	ld		bc,5*60
	call	wait_time_or_key_bc	; only 5 secs
1:
	ld	a,(victory)
	and	a
	jr	z,1f
	di
	call	disscr
	call	victory_screen
	call	enpage2
	call	victory_text
	call	enascr
	call	ending_music
	ei	
	ld		bc,20*60
	call	wait_time_or_key_bc	; 20 secs
	call	victory_text1
	ei
	call	wait_music_or_key	; till music ends
	call	victory_text2
	ei
	call	wait_time_or_key	; 10 secs
	call	PT3_MUTE
	xor	a
	ld	(victory),a		; avoid greetings if you play another time and die
	dec	a
	ld	(enable_cheat),a	; enable cheat after any victory

1:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; menu goes here !!	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call	enpage3
	call	plot_title_screen
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; game start
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	halt
	di
	call 	cls
	call	disscr
	call	sprite_init
	
	call 	ayFX_SETUP
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ld	bc,0						; show score on screen 
	call	add_bc_score_bin
	ld	c,0							; show lives on screen 
	call	add_c_lives_bin

	xor	a
	ld	(already_dead),a	; reset at level start, set after you die
	inc	a
	ld	(next_level),a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

restart:
	ld	hl,0
	ld	(xmap),hl
	call 	ayFX_END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; warping sequence only at level start
;
	ld	a,(already_dead)
	and	a
	jr	nz,11f
	call	PT3_MUTE
	call	intro_anim
11:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; music starts AFTER the warping sequence
;	
	ld	a,(already_dead)
	and	a
	jr	nz,11f			; do not restart music if already dead

	ld		a,(cur_level)
	dec		a
1:	cp		n_musics
	jr		c,1f
	sub		3
	jr		1b

1:	call	start_song

11:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; music starts AFTER the warping sequence
;
	ld	a,(already_dead)
	and	a
	call	nz,just_level_init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ld	a,(cur_level)
	dec	a
	ld	l,a
	ld	h,0
	ld	e,l
	ld	d,h

[3]	add	hl,hl
	add	hl,de
	
	ld	de,levelnames
	add	hl,de
	ld	de,0x1C00+8*3*32
	call	print_strf

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	xor a
	ld	(aniframe),a
	ld	(anispeed),a
	ld	(ms_state),a
	ld	a,8
	ld	(dxmap),a
	ld	(old_aniframe),a		; old_aniframe!=aniframe
	
	ld	hl,0
	ld	(xmap),hl
	ld	bc,xship_rel
	add hl,bc
	ld	(xship),hl
	ld	a,64+64-8
	ld	(yship),a

	call	ayFX_SETUP	
	xor	a
	ld	(halt_game),a
	ld	(halt_gamef1),a
	ld	(JIFFY),a
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	main loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main_loop:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; test for level change
	call	test_pause
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; pause loop	
	ld	a,(halt_game)
	and	a
	jr	nz,main_loop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; end level ?
	call	test_runway

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run ms FSM and place its sprites in the SAT in RAM
	call	ms_ctrl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; test for game restart
	ld	a,(ms_state)
	cp	ms_reset
	jp	z,restart

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; place MS in the SAT and test for collision
	call	put_ms_sprt
	ld	a,(god_mode)
	and 	a
	call	z,test_obstacles

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run NCPS FSM
	call	npc_loop			; manage active enemies
	call	wave_timer			; activate new enemies

	call	enemy_bullet_loop	; manage enemy bullets
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run MS bullets FSM
	call	bullet_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; place NPCS sprites in the SAT in RAM
	call	plot_enemy

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wait refresh and update map position

	; setVdp 7,0x04
	;	halt

	ld hl,JIFFY
	; ld	a,1
	; cp	(hl)
	; jp	nc,111f
	; setVdp 7,0x04
; 111:
	ld	a,(game_speed)
	dec	a
wait:
	cp (hl)
	jr nc,wait
	xor	a
	ld	(hl),a

	; setVdp 7,0x00

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Manage map limits

	ld	hl,(xmap)
	inc h
	ld	de,8*(LvlWidth)+256
	and a
	sbc hl,de
	ld	a,-10
	jp	nc,.endmap	; bounce right

	add hl,de
	ld	bc,-256-8
	add hl,bc

	jp	c,main_loop
	
	ld	a,10		; bounce left
	
.endmap:
	ld	(dxmap),a
	jp	main_loop
;
; main loop end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
test_level:
	ld e,6
	call	checkkbd
	rrc	l				; shift
	jp	nc,levels_8_16
levels_0_8:
	ld	d,0
	jr	1f
levels_8_16
	ld	d,8
1:
	ld e,0
	call	checkkbd
	ld	a,d
	repeat 8
11:	rrc	l				 ; <- '0','1','2','3','4','5','6','7'
	jr	nc,1f
	inc	a
	endrepeat
	ret
	
1:
	ld	(next_level),a
	ld	a,ms_reset
	ld	(ms_state),a
	
	xor	a
	ld	(halt_game),a
	ld	(already_dead),a	; reset tiles and colours

	ld	a,17				; jump to a new level
	call AFXPLAY
	ld	b,0x4f
1:	halt
	djnz	1b
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
test_pause:
	ld e,7
	call	checkkbd
	and 0x20				; <-	BS
	jr	nz,_no_gameover
	ld	a,1								; game over
	ld	(lives_bin),a
	call	test_obstacles.found		; start ms explosion
_no_gameover:
	ld e,6
	call	checkkbd
	and 0x20				; <-	F1
	jr	nz,1f
	scf
1:	ld	a,(halt_gamef1)
	rla
	ld	(halt_gamef1),a
	and 3
	cp  2
	ret nz
	
	ld	a,16		; pause
	call AFXPLAY
	
	ld	a,(halt_game)
	xor 255
	ld	(halt_game),a
	jr	z,stop_music
start_music
	xor	a
	ld	(music_flag),a
	
	; Easter egg	
	jp	test_level
;	ret
stop_music
	dec	a	;ld	a,0xff
	ld	(music_flag),a
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include collision_tst.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include scorebar.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ms_col_win:
	include ms_demo_frm_coll_wind.asm
ms_bllts_col_win:
	include ms_bllts_frm_coll_wind.asm
	include ms_crtl.asm
	include mc_collide.asm
	include ms_bllts.asm
	include put_ms_sprt.asm
test_spt:
	incbin uridium_rev6.miz
test_spt_3c:
	incbin  uridium_rev7.miz
	include scorebar_pos.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include mothership_sequence.asm 
	include plot_enemies.asm  
	include runways.asm  
	

rdslt	equ	0x000c
CALSLT	equ	0x001c
chgcpu	equ	0x0180	; change cpu mode
exttbl	equ	0xfcc1	; main rom slot

; Detect Turbo-R
	
; _test_r800:
	; ld	a,(exttbl)	; test msx1, msx2, msx2+
	; ld	hl,0x002d
	; call	rdslt
	; ld	l,a
	; ret


; Switch to r800 rom mode
	
_set_r800:
	in	a,(0aah)
	and 011110000B			; upper 4 bits contain info to preserve
	or	6
	out (0aah),a
	in	a,(0a9h)
	ld	l,a

	ld	a,(0x002d)
	cp	3					; this is a TR
	ld	a,l
	jr	z,set_turbo_tr
							; this is anything else
	and	0x02				; CTR
	ret	nz					; if NZ, CTR is not pressed set the turbo

	ld	A,(chgcpu)
	cp	0C3h
	ld	a,81h              ; R800 ROM mode or any other turbo
	call	z,chgcpu
	ret

set_turbo_tr
	and	0x02				; CTR
	ret	z					; if Z, CTR is pressed -> do not set the turbo
	ld	a,81h              	; R800 ROM mode
	jp chgcpu
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_set_goodmode:
	xor	a
	ld	(enable_cheat),a
	in	a,(0aah)
	and 011110000B			; upper 4 bits contain info to preserve
	or	7					; 7 RET SEL BS STOP TAB ESC F5  F4
	out (0aah),a
	in	a,(0a9h)
	and	0x04
	ret	nz
	ld	a,-1
	ld	(enable_cheat),a
	ret

_hb_10p_hb20p_patch:
	in	a,(0aah)
	and 011110000B			; upper 4 bits contain info to preserve
	or	7					; 7 RET SEL BS STOP TAB ESC F5  F4
	out (0aah),a
	in	a,(0a9h)
	and	0x80
	ret	nz
	ld	a,0xF4
	out (0a8h),a
	ret
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code	page 2
message_pg2:
	db	"rom in page 2",13
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include levelinit.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include victory.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rom_tileset_miz:
	incbin	tileset_rev01.miz

endpage2: 
	db	0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code	page 3
message_pg3:	
	db	"rom in page 3 ",13
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
splash_shps:
	incbin MANTA_shps.miz
splash_clrs:
	incbin MANTA_clrs.miz
vsplash_shps:
	incbin ENDING2_chr.miz
vsplash_clrs:
	incbin ENDING2_clr.miz

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include tileinit.asm
	include clr_map.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
victory_screen:
	ld	hl,level_buffer
	ld	de,level_buffer+1
	ld	bc,256*3*8
	ld	(hl),0
	ldir

	ld	hl,vsplash_shps
 	ld	de,level_buffer+64
	call	mom_depack_rom
	_setvdpwvram (0x0000)
	ld	hl,level_buffer
[3]	call	write_256

	ld	hl,vsplash_clrs
	ld	de,level_buffer+64
	call	mom_depack_rom
	_setvdpwvram (0x2000)
	ld	hl,level_buffer
[3]	call	write_256

	_setvdpwvram 0x1800
	xor	a
	ld	b,2
1:	out	(0x98),a
	inc	a
	jr	nz,1b
	djnz	1b
	ret

show_manta:
	di
	call	disscr
 
	ld	hl,splash_shps
 	ld	de,level_buffer
	call	mom_depack_rom
	_setvdpwvram 0x0000
	ld	hl,level_buffer
[3]	call	write_256

	ld	hl,splash_clrs
	ld	de,level_buffer
	call	mom_depack_rom
	_setvdpwvram 0x2000
	ld	hl,level_buffer
[3]	call	write_256

	_setvdpwvram 0x1800
	xor	a
	ld	b,3
1:	out	(0x98),a
	inc	a
	jr	nz,1b
	djnz	1b
	call	enascr
	ei	
	
	
	; ld	bc,5*60+256
; 1:	halt
	; push	bc
	; call	joy_read
	; bit	4,a
	; pop	bc
	; ret	nz
	; dec	c
	; jr	nz,1b
	; djnz	1b
	ret

music_miz_buffer:
	ds	3429,255
endpage3: 
	db	0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
MSX_O_Mizer_buf:	equ	0xFe00	; ds	328+26 aligned at 0x100
ram_sat:			equ	0xfd09	; ds	128
ram_tileset:		equ	0xf87f	; ds	128*8 
slotvar:			equ	0xFFC5
slotram:			equ 0xFFC6
SCC:				equ	0xFFC7
curslot:			equ	0xFFC8
music_flag:			equ	0xFFC9

	map 0xC000
meta_pnt_table_u:	#	1024
meta_pnt_table_d:	#	1024
miz_buffer:			#	3*1024

level_buffer:		#	LvlWidth*16+32

toshiba_switch		#	1		; Toshiba
game_speed:			#	1		; game speed 1,2,3,4
victory:			#	1		
visible_sprts:		#	1
ingame:				#	1
aniframe:			#	1
old_aniframe:		#	1

ms_state:			#	1
anispeed:			#	1

enable_cheat		#	1

PT3_SETUP:			#	1	;set bit0 to 1, if you want to play without looping
					        ;bit7 is set each time, when loop point is passed
PT3_MODADDR:		#	2
PT3_CrPsPtr:		#	2  ; Patter# = CrPsPtr-song_buffer-101;
PT3_SAMPTRS:		#	2
PT3_OrnPtrs:		#	2
PT3_PDSP:			#	2
PT3_CSP:			#	2
PT3_PSP:			#	2
PT3_PrNote:			#	1
PT3_PrSlide:		#	2
PT3_AdInPtA:		#	2
PT3_AdInPtB:		#	2
PT3_AdInPtC:		#	2
PT3_LPosPtr:		#	2
PT3_PatsPtr:		#	2
PT3_Delay:			#	1
PT3_AddToEn:		#	1
PT3_Env_Del:		#	1
PT3_ESldAdd:		#	2

VARS: 				#	0
ChanA:				#	30			;CHNPRM_Size
ChanB:				#	30			;CHNPRM_Size
ChanC:				#	30			;CHNPRM_Size

;GlobalVars
DelyCnt:			#	1
CurESld:			#	2
CurEDel:			#	1

Ns_Base_AddToNs:	
Ns_Base:			#	1
AddToNs:			#	1

AYREGS:     		#	0
VT_:				#	14
EnvBase:			#	2
VAR0END:			#	240

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper variables from PT3 mobule
; scc patch

_psg_vol_fix:		#	1
_sfx_vol_fix:		#	1
_scc_vol_fix:		#	1

fade_psg_vol_fix:	#	1
fade_scc_vol_fix:	#	1

_psg_vol_balance:	#	2
_scc_vol_balance:	#	2

AYREGS_CPY:			#	13
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wchA:				#	1	; wave on channel A
wchB:				#	1	; wave on channel B
wchC:				#	1	; wave on channel C
; pt3 samples previously detected (times 2)
OSmplA          	#	1
OSmplB          	#	1
OSmplC          	#	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_waves				#	16

reverse_sat:		#	1


		; --- THIS FILE MUST BE COMPILED IN RAM ---

		; --- PT3 WORKAREA [self-modifying code patched] ---

    ; global _ayFX_PRIORITY
ayFX_PRIORITY:		#	1			; Current ayFX stream priority

		; --- THIS FILE MUST BE COMPILED IN RAM ---

ayFX_PLAYING:	#	1			; There's an ayFX stream to be played?
ayFX_CURRENT:	#	1			; Current ayFX stream playing
ayFX_POINTER:	#	2			; Pointer to the current ayFX stream
ayFX_TONE:	    #	2			; Current tone of the ayFX stream
ayFX_NOISE: 	#	1			; Current noise of the ayFX stream
ayFX_VOLUME:	#	1			; Current volume of the ayFX stream
ayFX_CHANNEL:	#	1			; PSG channel to play the ayFX stream
ayFX_VT:		#	2			; ayFX relative volume table pointer



				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

vsf:         		#	1          ; 0 if 50Hz, !0 if 60Hz
cnt:         		#	1          ; counter to compensate NTSC machines
ayend:				#	0
randSeed:			#	2

assault_wave_timer:	# 	2
wave_count:			#	1
landing_permission:	#	1
bullet_rate:		#	1
dxmap:				#	1
xmap:				#	2
yship:				#	1
xship:				#	2
cur_level:			#	1
next_level:			#	1
sprite_3c:			#	1
clr_table			#	2
joystick:			#	1
old_joystick:		#	1
chang_joystick:		#	1
menu_item:			#	1
already_dead:		#	1	; set after you die, reset at level start 

god_mode			#	1
halt_game:			#	1
menu_level:			#	0
halt_gamef1:		#	1
lives:				#	3
dummy_:				#	4
score:				#	7
score_bin:			#	4
lives_bin:			#	1	; BCD !!!

toggle_scc			#	1
save_SCC			#	1
	
	struct enemy_data
y				db	0
x				dw	0
xoff			db	0
yoff			db	0
xsize			db	0
ysize			db	0
status			db	0	; B7 == DWN/UP | B6 == RIGHT/LEFT | B0 == Inactive/Active
cntr			db	0
kind			db	0
frame			db	0
color			db	0
speed			dw	0
	ends
	
; [max_enem]			enemy_data
; [max_bullets]		enemy_data
; [max_enem_bullets]	enemy_data

enemies:		#	enemy_data*max_enem
ms_bullets:		#	enemy_data*max_bullets
enem_bullets:	#	enemy_data*max_enem_bullets

	
	endmap
	