
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Interrupt service routine
;
	
	code @ 	0x0038
isr:
	push   af
	push   hl
	push   de
	push   bc
	ex	   af,af'
	push   af
	push   iy
	push   ix
	
	in	a,(0x99)
	
	ld	hl,JIFFY
	inc	(hl)			; 8 bit JIFFY

	pop	   ix
	pop	   iy
	pop	   af
	ex	   af,af'
	pop	   bc
	pop	   de
	pop	   hl
	pop	   af
	ei
	ret

