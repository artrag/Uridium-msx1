
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Interrupt service routine
;
	
	code @ 	0x0038
isr:
	push   hl         
	push   de         
	push   bc         
	push   af         
	push   iy         
	push   ix         
	
	ld	a,(ingame)
	and	a
	jp	nz,1f
	in	a,(0x99)	; exit from isr
	jp	Music_only
1:
	_setVdp 5,0x37	;	SAT at 0x1b80
	_setVdp 6,0x03	;	SPT at 0x1800	(used from 0x1C00 to 0x1FF	only 32 sprites 16x16)
	; _setVdp 7,0x04

	call 	_sat_update
	call	_plot_spt
		
	ld	a,(toshiba_switch)		; Toshiba
	and	a
	jr	nz,.compatibilty
	
	ld	a,(xmap)				; TMS
	and 2
	jp	z,.other_page
	
	call	disp_page0
	
	jp	.this_page
	
.other_page:

	call	disp_page1
	
.this_page:
	
	_setvdpwvram 0x1900
	call	_plot_pnt
	jp	1f
	
.compatibilty:

	_setvdpwvram 0x1900
	call	_plot_pnt_toshiba
1:
	call	_plot_strs

	; Write values on PSG registers
	call	PT3_ROUT
	call 	en_scc
	jr	z,1f
    call    probewavechanges
    call    SCCROUT	
	call 	en_slot
1:

	_setVdp 7,0x00
	
1:	in	a,(0x99)
	and 0x5F
	cp	0x5C		; plane 28 =0x1C
	jp	nz,1b

	_setVdp 5,0x36	;	SAT at 0x1b00
	_setVdp 6,0x07	;	SPT at 0x3800	(64 sprites 16x16)
	
	; _setVdp 7,0x06
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld      a,(vsf)
	and     a
	jp      nz,.PAL		; if PAL call at any interrupt

.NTSC:
	ld      hl,cnt      ; if NTSC call 5 times out of 6
	dec     (hl)
	jp      nz,.PAL     ; skip one tic out of 6 when at 60hz
	ld      (hl),6      ; reset the tic counter
	jp	.skip_audio     ; continue

.PAL:                   ; Calculates PSG values for next frame
	in	a,(0xA8)		; Read the main slot register 
	push	af			; save it
	call	enpage3
	call 	Audio_Internal_code
	pop		af
	out (0xA8),a
.skip_audio:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
99:
	ld	hl,JIFFY
	inc	(hl)			; 8 bit JIFFY

	; _setVdp 7,0x00

	pop    ix         
	pop    iy         
	pop    af         
	pop    bc         
	pop    de         
	pop    hl         
	ei
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;
; used in title screen	
	
Music_only:
	call	PT3_ROUT
	
	call 	en_scc
	jr	z,1f
    call    probewavechanges
    call    SCCROUT	
	call 	en_slot
1:
;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld      a,(vsf)
	and     a
	jp      nz,.PAL		; if PAL call at any interrupt

.NTSC:
	ld      hl,cnt      ; if NTSC call 5 times out of 6
	dec     (hl)
	jp      nz,.PAL     ; skip one tic out of 6 when at 60hz
	ld      (hl),6      ; reset the tic counter
	jp	.skip_audio     ; continue

.PAL:                   ; Calculates PSG values for next frame
	in	a,(0xA8)		; Read the main slot register 
	push	af			; save it
	call	enpage3
	call 	Audio_Internal_code
	pop		af
	out (0xA8),a
.skip_audio:
	jp	 99b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOT FAR STARFIELD
; input : none
;
_plot_strs:
	ld	hl,(xmap)	; x position in pixels
	srl h
	rr	l
	srl h
	rr	l
	srl h
	rr	l

	ld	de,level_buffer
	add hl,de

	ld	de,x_stars
	ld	ix,0x1900 + 0x4000

	repeat 8
2:	ex de,hl
	ld   c,(hl)
	inc hl
	ld   b,(hl)
	inc hl
	ex de,hl
	add hl,bc
	add ix,bc

	ld	a,(hl)
	and a
	jr nz,1f

	ld	a,ixl
	out (0x99),a
	ld	a,ixh
	out (0x99),a

	ld	a,255
	out (0x98),a
1:
	ld	bc,2*LvlWidth-2*32
	add hl,bc
	endrepeat

	ret
x_stars:
	defw	  28, 3-28+64,19-3+64,29-19+64,18-29+64, 5-18+64,14-5+64,26-14+64
	; defw	  1-18+32,  28-1+32,4-28+32,29- 4+32,20-29+32, 3-20+32, 8-3+32,26- 8+32

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOT PNT
; input : xmap
;
_plot_pnt_toshiba:
	ld	hl,(xmap)	; x position in pixels
	ld	a,l
	rrca
	and 0x2
	jp	1f

_plot_pnt:
	ld	hl,(xmap)	; x position in pixels
	ld	a,l
	rrca
	and 0x3
1:
	add a,meta_pnt_table_u/256
	ld	ixl,a

	srl h
	rr	l
	srl h
	rr	l
	srl h
	rr	l

	ld	de,level_buffer
	add hl,de

	ex	de,hl

	call	half_screen

	ld	a,ixl
	add a,meta_pnt_table_d/256-meta_pnt_table_u/256
	ld	ixl,a

half_screen:
	ld	c,0x98
	ld	ixh,8
1:
	ld	a,ixl
	ld	h,a
	ld	a,e
	add a,32
	jp	nc,.fast_loop

.slow_loop:
	repeat 32
	ld	a,(de)
	ld	l,a
	outi
	inc de
	endrepeat

	ld	hl,LvlWidth-32
	add hl,de
	ex	de,hl

	dec ixh
	jp	nz,1b

	ret

.fast_loop:
	repeat 32
	ld	a,(de)
	ld	l,a
	outi
	inc e
	endrepeat

	ld	hl,LvlWidth-32
	add hl,de
	ex	de,hl

	dec ixh
	jp	nz,1b

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	sprite multiplexing
;
	
_sat_update:
	ld	a,(reverse_sat)
	xor 1
	ld	(reverse_sat),a
	jp	nz,_reverse_sat

_directsat:
	ld	a,(visible_sprts)
	and 0xFC
	ret z
	ld	b,a
	ld	c,0x98
	ld	hl,ram_sat
	_setvdpwvram 0x1b00
1:	outi
	outi
	outi
	outi
	jp	nz,1b
	ld	a,0xD0
	out (0x98),a
	ret

_reverse_sat:
	ld	a,(visible_sprts)
	and 0xFC
	ret z
	ld	b,a
	ld	c,0x98
	ld	hl,ram_sat-4+8

	ld	e,b
	ld	d,0
	add hl,de
	ld	de,-8

	_setvdpwvram 0x1b00
1:	add hl,de
	outi
	outi
	outi
	outi
	jp	nz,1b
	ld	a,0xD0
	out (0x98),a
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; update main ship
;
	
_plot_spt:
	ld	hl,(aniframe)
	ld	a,l
	cp	h
	ret	z
	ld	(old_aniframe),a
	ld	hl,ms_ani
	ld	c,a
	ld	b,0
	add	hl,bc
	ld	l,(hl)
	ld	h,b
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld	e,l
	ld	d,h
	add	hl,hl
	add	hl,de
	ld	de,ms_spt
	add hl,de
	_setvdpwvram 0x3800
	ld	c,0x98
[96]	outi
	ret
	