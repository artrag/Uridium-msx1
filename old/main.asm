; -----------------------------
; smooth scroller engine
; Uridium 48K
; Trilobyte 2014
; ------------------------------
	
three_colrs	equ 0

	IF three_colrs
		output URDIUM3c.rom
	ELSE
		output URDIUM48.rom
	ENDIF

	incdir data_bin/
	incdir data_miz/
	incdir audio/

	defpage 0,0x0000,0x4000
	defpage 1,0x4000,0x8000

; ------------------------------

	include macros.asm	
	code
sfxBank_miz:
	incbin   "sfx.miz"
; -----------------------------
; 	Parameters
;	LvlWidth:	equ 384
;	nphase:		equ 4
;	xstep:		equ 2
;

	include parametrs.asm

maxspeed:					equ 16		; the actual speed is divided by 4
max_enem:					equ 12
max_enem_bullets:			equ 3
max_bullets:				equ 2		; max number of enemies + ms_bullets + enem_bullets + 3 for ms	<= 32 sprites
assault_wave_timer_preset:	equ	3*60	; a wave each 3 seconds
enemy_bullet_speed:			equ	3	
xship_rel:					equ (128-8)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include isr.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	page 1
	code @	4000h
rom_header:
	db	"AB"		; rom header
	dw	initmain
	dz	'TRI004'
	ds	5
	
initmain:
	ld	a,2
	call 0x005f
	ld sp,0F380h		; place manually the stack
	call	rominit		; now the first 32KB of the rom are active
	
	ld	a,(_vdpReg+1)
	or 2
	ld	(_vdpReg+1),a
	
	_setVdp 7,0x00
		
	xor	a
	ld	(visible_sprts),a
	ld	(ingame),a
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld      a,-0	; range [-15,0]
	ld      (_psg_vol_fix),a

	call 	SCCINIT
	call 	_SCC_PSG_Volume_balance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ld		a,(0x002B)
	and 	0x80
	ld 		(vsf),a     	; 0=>60Hz, !0=>50Hz
	ld      a,1
	ld      (cnt),a			; reset the tic counter
	
	call	setrompage0		; 48K of rom are active - bios is excluded
							; from here interrupts are disabled
	call	rand8_init


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	xor	a
	ld	(victory),a			; none has completed the game yet
	
title_screen:
	di
	call	disscr
	_setVdp 3,0xFF	;	colours at 0x2000	(regular mode for colors)
	_setVdp 4,0x03	;	patterns at 0x0000	(regular: used 0x0800 0x1000)
	
	xor	a
	ld	(visible_sprts),a
	ld	(ingame),a
	
	ld	hl,rom_tileset_miz 	;  tile set to be expanded in ram
	ld	de,ram_tileset
	call	mom_depack_rom
	
	ld	a,1
	ld	(game_speed),a		; valid values 1 2 3
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; plot splash screen
	; menu goes here !!	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	di
	_setvdpwvram 0x1b00
	ld	a,0xd0
	out	(0x98),a
	ei
	
	call 	show_manta

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; menu goes here !!	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	call	plot_title_screen
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; game start
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	di
	call	disscr
	call	sprite_init
	call 	cls
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ld	bc,0						; show score on screen 
	call	add_bc_score_bin
	ld	c,0							; show lives on screen 
	call	add_c_lives_bin

	ld	a,1
	ld	(next_level),a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

restart:
	call	AFXSTOP
	call	AFXFRAME
	call	ROUT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld	hl,clr_table1
	ld	(clr_table),hl
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call	intro_anim
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


	call	npc_init
	call	plot_enemy

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

	call	AFXINIT	
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
	call	test_obstacles

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; run NCPS FSM
	call	wave_timer
	call	npc_loop
	call	enemy_bullet_loop
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; run MS bullets FSM
	call	bullet_loop

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; place NPCS sprites in the SAT in RAM
	call	plot_enemy

	; wait refresh and update map position

	; setVdp 7,0x04
	;	halt

	ld hl,JIFFY
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
	jp	nc,endmap	; bounce right

	add hl,de
	ld	bc,-256-8
	add hl,bc

	jp	c,main_loop
	
	ld	a,10	; bounce left
	ld	(dxmap),a
	jp	main_loop
	
endmap:
	ld	a,-10
	ld	(dxmap),a
	jp	main_loop
;
; main loop end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
	include mothership_sequence.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set pages and sub-slot
	;code	page 0,1
	include rominit.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; test for  Toshiba mode
	;code	page 0,1
; thosiba_mode:
	; ld	e,7
	; call	checkkbd	; press F5 for Toshiba mode
	; and	2
	; ld	a,1
	; jr	z,1f
	; xor	a
; 1:	ld	(toshiba_switch),a
	; ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
	include clr_map.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
	include enemies.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
	include intro.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
	include MSX_ShiruAFX-Play_v3.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
	include collision_tst.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
	include scorebar.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;code	page 0,1
	include runways.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
	include	mc_collide.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
	include ms_crtl.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
	include mizer.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
ms_ani:
	include ms_demo_ani.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
ms_spt:
	; include ms_demo_frm.asm
	incbin  ms_demo_frm.bin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
ms_col_win:
	include ms_demo_frm_coll_wind.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
ms_bllts_col_win:
	include ms_bllts_frm_coll_wind.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code	
write_256:
	ld	bc,0x0098
[8]	otir
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code 
;	NB: needs DI
enascr:
	ld	   a,(_vdpReg + 1)
	or	   #40
	jr	   1f
disscr:
	ld	   a,(_vdpReg + 1)
	and	   #bf
1:
	out	   (#99),a
	ld	   (_vdpReg + 1),a
	ld	   a,1 + 128
	out	   (#99),a
	ret
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
	;code	page 0,1	
	include	ms_bllts.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1	
	include plot_enemies.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1	
	include put_ms_sprt.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1	
	include sprtinit.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; *** sprite data in rom ***
	;code	page 0,1	
test_spt:
	IF three_colrs
		incbin uridium_rev7.miz
	ELSE
		incbin uridium_rev6.miz
	ENDIF

	;code	page 1
rom_tileset_miz:
	incbin	tileset2.miz
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; place the score bar
	;code	page 0,1	
	include scorebar_pos.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1
	include	levelinit.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;code	page 0,1	
	include tileinit.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; *** tile set data in rom ***
	;code	page 0,1	
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code	
test_level:
	ld e,6
	call	checkkbd
	rrc	l
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
	ld	b,8
11:	rrc	l				 ; <- '0','1','2','3','4','5','6','7'
	jr	nc,1f
	inc	a
	djnz	11b
	ret
	
1:
	ld	(next_level),a
	ld	a,ms_reset
	ld	(ms_state),a
	
	xor	a
	ld	(halt_game),a
	ld	a,17			; jump to a new level
	call	AFXPLAY
	ld	b,0x4f
1:	halt
	djnz	1b
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code		
test_pause:
	ld e,6
	call	checkkbd
	ld	a,l
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
	
	; Easter egg	
	jp	nz,test_level
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code page 0,1
splash_shps:
	incbin MANTA_shps.miz
splash_clrs:
	incbin MANTA_clrs.miz

	
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
	
	ld	bc,1*60+256
1:	halt
	dec	c
	jr	nz,1b
	djnz	1b
	ret

	code	page 1	
	INCLUDE "sccdetect\SCCaudio.asm"
	INCLUDE "sccdetect\SCCWAVES.ASM"
	INCLUDE "sccdetect\SCCDETEC.ASM"	
	code	page 0,1	
top_rom:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
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
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MSX_O_Mizer_buf:	equ	0xFe00	; ds	328+26 aligned at 0x100
ram_sat:			equ	0xfd09	; ds	128
ram_tileset:		equ	0xf87f	; ds	128*8 
	
	code @ 0xC000
	ALIGN 0x01000
meta_pnt_table_u:	ds	1024
meta_pnt_table_d:	ds	1024
		
toshiba_switch		ds	1		; Toshiba
game_speed:			ds	1		; game speed 1,2,3,4
victory:			ds	1		
slotvar:			ds	1
visible_sprts:		ds	1
ingame:				ds	1
vsf:				ds	1
cnt:				ds	1
randSeed:			ds	2
assault_wave_timer:	ds 	2
wave_count:			ds	1
landing_permission:	ds	1
bullet_rate:		ds	1
dxmap:				ds	1
xmap:				ds	2
yship:				ds	1
aniframe:			ds	1
anispeed:			ds	1
ms_state:			ds	1
xship:				ds	2
cur_level:			ds	1
next_level:			ds	1
clr_table			ds	2
joystick:			ds	1
halt_game:			ds	1
halt_gamef1:		ds	1
lives:				ds	3
					ds	4
score:				ds	7
score_bin:			ds	4
lives_bin:			ds	1	; BCD !!!
sfx_data:
miz_buffer:			ds	3*1024+400
	include PT3-RAM.ASM
level_buffer:		ds	LvlWidth*16+32
reverse_sat:		ds	1
active_tileset		ds	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper variables from PT3 mobule
; scc patch

_psg_vol_fix:		ds	1
VolBalance:			ds	2
AYREGS_CPY:			ds	13
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wchA:				ds	1	; wave on channel A
wchB:				ds	1	; wave on channel B
wchC:				ds	1	; wave on channel C
; pt3 samples previously detected (times 2)
OSmplA          	ds	1
OSmplB          	ds	1
OSmplC          	ds	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_waves			ds	15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SLOT            ds     1
PAGE1RAM        ds     1
RAMSLOT         ds     1
SCC             ds     1
SUB             ds     1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

enemies:
[max_enem]			enemy_data

ms_bullets:
[max_bullets]		enemy_data

enem_bullets:
[max_enem_bullets]	enemy_data
	
DATA_AREA:		
afxNoisePeriod:		ds	1
afxBnkAdr:			ds	2
afxChData:  	    ds	3*11
END_DATA_AREA:

; manta_grpx:			ds	3*56*32
top_ram:
