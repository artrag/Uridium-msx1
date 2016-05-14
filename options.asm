joy_read:
	di
	push	ix
	ld	a,(joystick)
	ld	(old_joystick),a
	call	ms_ctrl.rd_joy
	ld	a,(joystick)
	ld	b,a
	ld	a,(old_joystick)
	xor	b
	and	b
	ld	(chang_joystick),a
	pop		ix
	ei
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 0	Input joystick pin 1	(up)
; 1	Input joystick pin 2	(down)
; 2	Input joystick pin 3	(left)
; 3	Input joystick pin 4	(right)
; 4	Input joystick pin 6	(trigger A)

	struct menu_entry
vramxy			dw	0
txt_pntr		dw	0
code			dw	0
	ends

mnu0
.opt0:	db	"   Start",13
.opt1:	db 	"  Settings",13
.opt2:	db 	"Instructions",13

mnu0_data
	menu_entry 21*32+10,mnu0.opt0,game_start
	menu_entry 22*32+10,mnu0.opt1,menu1
	menu_entry 23*32+10,mnu0.opt2,instructions
	menu_entry -1,-1,-1

mnu1:
.opt0:	db	"    Game mode",13		
.opt1:	db	"   VDP Type",13
.opt2:	db	"  Enhanced enemies ",13
.opt3:	db	"  SCC on/off",13
.opt4:	db	"  SCC volume",13
.opt5:	db	"  PSG volume",13
.opt6:	db	"  SFX volume",13
.opt7:	db	"    Music",13
.optA:	db	"  SFX test",13
.opt8:	db	"  God  Mode",13
.opt9:	db	"    Exit",13
	
mnu1_data
	menu_entry  8*32+8,mnu1.opt0,set_difficulty
	menu_entry 10*32+9,mnu1.opt1,set_compatibility
	menu_entry 12*32+6,mnu1.opt2,set_enemies
	menu_entry 14*32+9,mnu1.opt3,set_scc
	menu_entry 15*32+9,mnu1.opt4,set_scc_volume
	menu_entry 16*32+9,mnu1.opt5,set_psg_volume
	menu_entry 17*32+9,mnu1.opt6,set_sfx_volume
	menu_entry 18*32+9,mnu1.opt7,set_music
	menu_entry 19*32+9,mnu1.optA,set_sfx
	menu_entry 20*32+9,mnu1.opt8,set_god_mode
	menu_entry 22*32+9,mnu1.opt9,return
	menu_entry -1,-1,-1

select_menu:
	ld	l,(ix+menu_entry.code)
	ld	h,(ix+menu_entry.code+1)
	jp	(hl)
		
print_menu:
	ld	de,text
	ld	hl,0x1800+32*1+7
	call	prstr
	ld	hl,0x1800+32*3+12
	call	prstr
	ld	hl,0x1800+32*5+12
	call	prstr
	ld	hl,0x1800+32*6+12
	call	prstr

1:	ld	l,(ix+menu_entry.vramxy)
	ld	h,(ix+menu_entry.vramxy+1)
	ld	de,0x1800
	add	hl,de
	ld	e,(ix+menu_entry.txt_pntr)
	ld	d,(ix+menu_entry.txt_pntr+1)
	call	prstr
	ld	de,menu_entry
	add	ix,de
	ld	a,(ix)
	inc	a
	jr	nz,1b
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
return:
	pop		af
	pop		af
	jp	menu0
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
menu1:
	ld	a,1
	ld	(menu_level),a
	call	cls
	ld	ix,mnu1_data
	jp	_menu
menu0:
	xor	a
	ld	(menu_level),a
	call	print_page	

	di	
	ld	a,4
	ld		(next_level),a
	xor	a
	ld	(JIFFY),a
	ld	(PT3_SETUP),a
	dec	a
	ld	(joystick),a
	ld	(old_joystick),a
	call	enascr
	ei	

	ld	ix,mnu0_data
_menu:
	push	ix
	call	print_menu
	xor	a
	ld	(menu_item),a
	pop		ix
	ld	de,cursr
	call	print_cursor
1:	call	joy_read
	; ld	a,(chang_joystick)
	and	0x1C				;fire, right,left ; bit 4,3,2
	call	nz,select_menu

	ld	a,(chang_joystick)
	bit	0,a					; up
	call	nz,decrease_menu_item
	ld	a,(chang_joystick)
	bit	1,a					; down
	call	nz,increase_menu_item
	
	ld	a,(menu_level)
	and	1
	jr	nz,1b				; attract mode starts only in menu0
	ld	a,(PT3_SETUP)
	and	128
	jp	nz,attract_mode		; when music ends or loops
	; call ayFX_test
	jr	1b

increase_menu_item:
	ld	a,(ix+menu_entry)
	inc	a
	ret	z
	ld	de,space
	call	print_cursor
	ld	bc,menu_entry
	add	ix,bc
	ld	de,cursr
	call	print_cursor
	ld	a,(menu_item)
	inc	a
	ld	(menu_item),a
	ret
decrease_menu_item:
	ld	a,(menu_item)
	dec	a
	ret	m
	ld	(menu_item),a
	ld	de,space
	call	print_cursor
	ld	bc,-menu_entry
	add	ix,bc
	ld	de,cursr
	call	print_cursor
	ret

print_cursor:
	ld	l,(ix+menu_entry.vramxy)
	ld	h,(ix+menu_entry.vramxy+1)
	ld	bc,0x1800-2
	add	hl,bc
	call	prstr
	ld	l,(ix+menu_entry.vramxy)
	ld	h,(ix+menu_entry.vramxy+1)
	ld	bc,0x1800-2
	add	hl,bc
	ld	a,l
	and	31
	ld	b,a
	ld	a,31
	sub	a,b
	ld	b,a
	ld	a,l
	and	0xE0
	or	b
	ld	l,a
	call	prstr
	ret
space:
	db 	" ",13
	db 	" ",13
cursr:
	db 	">",13
	db 	"<",13
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

set_difficulty:
	ld      a,10			; simple shot 
	call    AFXPLAY
	call	show_difficulty
	
1:	call	joy_read
	; ld	a,(chang_joystick)
	bit	3,a			; right 
	call nz,decrease_diff
	ld	a,(chang_joystick)
	bit	2,a			; left 
	call nz,increase_diff
	ld	a,(chang_joystick)
	and	0x13		; up/down/fire
	ret	nz
	jp	1b
	
diff_txt:
	dw	hard,normal,easy
easy:	db	"Game mode: Easy ",13	;  Game mode: Easy -> Game mode: Normal -> Game mode: Hard
normal:	db	"Game mode:Normal",13
hard:	db	"Game mode: Hard ",13
	
decrease_diff:
	ld	a,(game_speed)
	inc	a
	cp	4
	jp	c,1f
	ld	a,1
	jp	 1f
increase_diff:
	ld	a,(game_speed)
	dec	a
	jp	nz,1f
	ld	a,3
1:	ld	(game_speed),a
	
show_difficulty:
	ld	a,(game_speed)
	dec	a
	ld	hl,diff_txt
plot_option:
	add	a,a
	add	a,l
	ld	l,a
	ld	a,h
	adc	a,0
	ld	h,a
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l,(ix+menu_entry.vramxy)
	ld	h,(ix+menu_entry.vramxy+1)
	ld	bc,0x1800
	add	hl,bc
	call	prstr
	ei
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_compatibility:
	ld      a,10			; simple shot 
	call    AFXPLAY
	call	show_compatibility
1:	call	joy_read
	; ld	a,(chang_joystick)
	and	0x1c				; right/left/fire
	call	nz,_set_compatibility
	ld	a,(chang_joystick)
	and	0x03				; up/down
	ret	nz
	jp	1b
comp_txt:
	dw	.tms,.toshiba
.tms:		db	" VDP:TMS99x8A",13
.toshiba:	db	" VDP: Toshiba",13

_set_compatibility:
	ld	a,(toshiba_switch)
	xor	1
	ld	(toshiba_switch),a
show_compatibility:
	ld	a,(toshiba_switch)
	ld	hl,comp_txt
	jp	plot_option
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_scc:
	ld      a,10			; simple shot 
	call    AFXPLAY
	
	ld	a,(SCC)
	inc	a				; 255 == off
	jr	z, 1f		
	dec	a				; save SCC slot only if SCC is present
	ld	(save_SCC),a
	ld	a,1				; other == on
1:	ld 	(toggle_scc),a	; 0 = off, 1 == on
	
	call	show_scc
	ld	a,(save_SCC)
	inc	a
	ret	z		; if	SCC is not present return
	
1:	call	joy_read
	; ld	a,(chang_joystick)
	and	0x1c		; right/left/fire
	call	nz,_set_scc
	ld	a,(chang_joystick)
	and	0x03		; up/down
	ret	nz
	jp	1b
scc_txt:
	dw	.scc_off,.scc_on
.scc_off:	db	"    SCC off ",13
.scc_on:	db	"    SCC on  ",13
				
_set_scc:
	ld	a,(toggle_scc)
	xor 1
	ld	(toggle_scc),a
	push	af
	call	nz,set_scc_on
	pop	af
	call	z,set_scc_off
show_scc:
	ld	a,(toggle_scc)
	ld	hl,scc_txt
	jp	plot_option
	
set_scc_off
	call 	en_scc
	XOR	A
	LD	H,A
	LD	L,A
	LD	( AYREGS_CPY+AR_AmplA),A
	LD	( AYREGS_CPY+AR_AmplB),HL
	call    SCCROUT	
	call 	en_slot
	ld	a,255
	ld	(SCC),a
	ret
set_scc_on
	ld	a,(save_SCC)
	ld	(SCC),a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
game_start:		
	pop	af
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instructions:
	call show_instructions
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
set_god_mode:
	ld	a,(enable_cheat)
	and	a
	ld	a,14
	jp	z,AFXPLAY
	ld      a,10			; simple shot 
	call    AFXPLAY
	call	show_god_mode
1:	call	joy_read
	; ld	a,(chang_joystick)
	and	0x1c		; right/left/fire
	call	nz,_set_god_mode
	ld	a,(chang_joystick)
	and	0x03		; up/down
	ret	nz
	jp	1b
god_txt:
	dw	.op1,.op2
.op1:	db	" God mode off",13
.op2:	db	" God mode on ",13

_set_god_mode:
	ld	a,(god_mode)
	xor	1
	ld	(god_mode),a
show_god_mode:
	ld	a,(god_mode)
	ld	hl,god_txt
	jp	plot_option
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
set_enemies:
	ld      a,10			; simple shot 
	call    AFXPLAY
	call	show_3clr
1:	call	joy_read
	; ld	a,(chang_joystick)
	and	0x1c		; right/left/fire
	call	nz,_set_3clr
	ld	a,(chang_joystick)
	and	0x03		; up/down
	ret	nz
	jp	1b
sprite_3c_txt:
	dw	.op1,.op2
.op1:	db	"Enhanced enemies OFF",13		; Enhanced enemies ON/OFF
.op2:	db	"Enhanced enemies ON ",13

_set_3clr:
	ld	a,(sprite_3c)
	xor	1
	ld	(sprite_3c),a
show_3clr:
	ld	a,(sprite_3c)
	ld	hl,sprite_3c_txt
	jp	plot_option
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

set_scc_volume:
	ld      a,10			; simple shot 
	call    AFXPLAY
	call	.show_volume
	
1:	call	joy_read
	; ld	a,(chang_joystick)
	bit	3,a				; right 
	call nz,.decrease_volume
	ld	a,(chang_joystick)
	bit	2,a				; left 
	call nz,.increase_volume
	ld	a,(chang_joystick)
	and	0x13			; up/down/fire
	ret	nz
	jp	1b

.decrease_volume:
	ld	a,(_scc_vol_fix)
	dec	a
	cp	-16
	jr	nz,1f
	xor	a
	jp	 1f
.increase_volume:
	ld	a,(_scc_vol_fix)
	inc	a
	cp	1
	jp	nz,1f
	ld	a,-15
1:	ld	(_scc_vol_fix),a
	
.show_volume:
	call 	_SCC_PSG_Volume_balance
	ld	a,(_scc_vol_fix)
	add	a,15
	ld	hl,set_scc_volume.volume
	jp	plot_option
	
.volume:
	dw	.optF,.optE,.optD,.optC,.optB,.optA,.opt9,.opt8
	dw	.opt7,.opt6,.opt5,.opt4,.opt3,.opt2,.opt1,.opt0
.opt0:	db	"SCC volume: 0 ",13
.opt1:	db	"SCC volume:-1 ",13
.opt2:	db	"SCC volume:-2 ",13
.opt3:	db	"SCC volume:-3 ",13
.opt4:	db	"SCC volume:-4 ",13
.opt5:	db	"SCC volume:-5 ",13
.opt6:	db	"SCC volume:-6 ",13
.opt7:	db	"SCC volume:-7 ",13
.opt8:	db	"SCC volume:-8 ",13
.opt9:	db	"SCC volume:-9 ",13
.optA:	db	"SCC volume:-10",13
.optB:	db	"SCC volume:-11",13
.optC:	db	"SCC volume:-12",13
.optD:	db	"SCC volume:-13",13
.optE:	db	"SCC volume:-14",13
.optF:	db	"SCC volume:-15",13
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

set_psg_volume:
	ld      a,10			; simple shot 
	call    AFXPLAY
	call	.show_volume
	
1:	call	joy_read
	; ld	a,(chang_joystick)
	bit	3,a				; right 
	call nz,.decrease_volume
	ld	a,(chang_joystick)
	bit	2,a				; left 
	call nz,.increase_volume
	ld	a,(chang_joystick)
	and	0x13			; up/down/fire
	ret	nz
	jp	1b
	
.decrease_volume:
	ld	a,(_psg_vol_fix)
	dec	a
	cp	-16
	jr	nz,1f
	xor	a
	jp	 1f
.increase_volume:
	ld	a,(_psg_vol_fix)
	inc	a
	cp	1
	jp	nz,1f
	ld	a,-15
1:	ld	(_psg_vol_fix),a
	
.show_volume:
	call 	_SCC_PSG_Volume_balance
	ld	a,(_psg_vol_fix)
	add	a,15
	ld	hl,set_psg_volume.volume
	jp	plot_option

.volume:
	dw	.optF,.optE,.optD,.optC,.optB,.optA,.opt9,.opt8
	dw	.opt7,.opt6,.opt5,.opt4,.opt3,.opt2,.opt1,.opt0
.opt0:	db	"PSG volume: 0 ",13
.opt1:	db	"PSG volume:-1 ",13
.opt2:	db	"PSG volume:-2 ",13
.opt3:	db	"PSG volume:-3 ",13
.opt4:	db	"PSG volume:-4 ",13
.opt5:	db	"PSG volume:-5 ",13
.opt6:	db	"PSG volume:-6 ",13
.opt7:	db	"PSG volume:-7 ",13
.opt8:	db	"PSG volume:-8 ",13
.opt9:	db	"PSG volume:-9 ",13
.optA:	db	"PSG volume:-10",13
.optB:	db	"PSG volume:-11",13
.optC:	db	"PSG volume:-12",13
.optD:	db	"PSG volume:-13",13
.optE:	db	"PSG volume:-14",13
.optF:	db	"PSG volume:-15",13

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

set_sfx_volume:
	ld      a,10			; simple shot 
	call    AFXPLAY
	call	.show_volume
	
1:	call	joy_read
	; ld	a,(chang_joystick)
	bit	3,a				; right 
	call nz,.decrease_volume
	ld	a,(chang_joystick)
	bit	2,a				; left 
	call nz,.increase_volume
	ld	a,(chang_joystick)
	and	0x13			; up/down/fire
	ret	nz
	jp	1b

	
.decrease_volume:
	ld	a,(_sfx_vol_fix)
	dec	a
	cp	-16
	jr	nz,1f
	xor	a
	jp	 1f
.increase_volume:
	ld	a,(_sfx_vol_fix)
	inc	a
	cp	1
	jp	nz,1f
	ld	a,-15
1:	ld	(_sfx_vol_fix),a
	
.show_volume:
	ld	a,(_sfx_vol_fix)
	add	a,15
	ld	hl,set_sfx_volume.volume
	jp	plot_option

	
.volume:
	dw	.optF,.optE,.optD,.optC,.optB,.optA,.opt9,.opt8
	dw	.opt7,.opt6,.opt5,.opt4,.opt3,.opt2,.opt1,.opt0
.opt0:	db	"SFX volume: 0 ",13
.opt1:	db	"SFX volume:-1 ",13
.opt2:	db	"SFX volume:-2 ",13
.opt3:	db	"SFX volume:-3 ",13
.opt4:	db	"SFX volume:-4 ",13
.opt5:	db	"SFX volume:-5 ",13
.opt6:	db	"SFX volume:-6 ",13
.opt7:	db	"SFX volume:-7 ",13
.opt8:	db	"SFX volume:-8 ",13
.opt9:	db	"SFX volume:-9 ",13
.optA:	db	"SFX volume:-10",13
.optB:	db	"SFX volume:-11",13
.optC:	db	"SFX volume:-12",13
.optD:	db	"SFX volume:-13",13
.optE:	db	"SFX volume:-14",13
.optF:	db	"SFX volume:-15",13

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_music:
	; ld	a,(enable_cheat)
	; and	a
	; jp	nz,jukebox
	; push	ix
	; call	PT3_MUTE
	; call	intro_music
	; pop		ix
	; ret
; jukebox:
	; ld	a,4
	; ld		(next_level),a
	call	.show_music
	
1:	call	joy_read
	; ld	a,(chang_joystick)
	bit	3,a			; right 
	call nz,.decrease
	ld	a,(chang_joystick)
	bit	2,a			; left 
	call nz,.increase
	ld	a,(chang_joystick)
	and	0x13		; up/down/fire
	jp	nz,.start_mus
	jp	1b
.decrease:
	ld	a,(next_level)
	inc	a
	cp	5
	jp	nz,1f
	xor	a
	jp	 1f
.increase
	ld	a,(next_level)
	dec	a
	cp	255
	jp	nz,1f
	ld	a,4
1:	ld	(next_level),a	

.show_music:
	ld	a,(next_level)
	ld	hl,.music_names
	jp	plot_option
.music_names:
	dw	.opt0,.opt1,.opt2,.opt3,.opt4
.opt0:	db	"  Blue theme ",13
.opt1:	db	"  Red theme  ",13	
.opt2:	db	" Green theme ",13	
.opt3:	db	" Ending theme",13	
.opt4:	db	" Intro theme ",13	

.start_mus:
	push	ix
	call	PT3_MUTE
	pop		ix
	ld		a,(next_level)
start_song:
	push	ix
	push	af
	call	enpage3
	ei
	pop		af
	add		a,a
	ld		e,a
	ld		d,0
	ld		hl,music_tables
	add		hl,de
	ld		a,(hl)
	inc		hl
	ld		h,(hl)
	ld		l,a
	call 	wavemap_init
	ld		de,-100
	add		hl,de
	call	PT3_INIT
	call	enpage2
	ei
	pop	ix
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
set_sfx:
	ld      a,10			; simple shot 
	call    AFXPLAY
	call	.show_sfx_help
1:	call	joy_read
	and	0x03		; up/down
	jp	nz,.end_sxftest
	call ayFX_test
	jp	1b
.sfx_help:
	dw	.op1,.op2
.op1:	db	" press C to W",13		
.op2:	db	"  SFX test   ",13
;"J" "I" "H" "G" "F" "E" "D" "C"
;"R" "Q" "P" "O" "N" "M" "L" "K"
;"Z" "Y" "X" "W" "V" "U" "T" "S"
.end_sxftest:
	ld	a,1
	jr  1f
.show_sfx_help:
	xor a
1:	ld	hl,.sfx_help
	jp	plot_option
