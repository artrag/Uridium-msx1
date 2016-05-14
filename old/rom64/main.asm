; -----------------------------
; test 64K
; ------------------------------
	output test64.rom

	defpage 0,0x0000,0x4000
	defpage 1,0x4000,0x4000
	defpage 2,0x8000,0x4000
	defpage 3,0x8000,0x4000
	
; ------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include macros.asm	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	page 0
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
checkkbd:
	in	a,(0aah)
	and 011110000B			; upper 4 bits contain info to preserve
	or	e
	out (0aah),a
	in	a,(0a9h)
	ld	l,a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include isr.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	page 1
	code @	4000h
rom_header:
	db	"AB"		; rom header
	dw	initmain
	dz	'TRI004'
	ds	5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include rominit.asm	
	include ..\sccdetect\sccdetec.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initmain:
	ld	a,2
	call 0x005f

	di
	ld sp,0F380h			; place manually the stack
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
	
	; actual main

enpage2 equ	setrompage2
enpage3 equ	setrampage2
	
	ld		hl,0x2000
	call	wrtvram
	call	enpage2
	call	clrloop

	ld		hl,0x0000
	call	wrtvram
	call	enpage3
	call	chrloop
	

	
	call	setrompage0		; 48K of rom are active - bios is excluded
							; from here interrupts are disabled

							;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	di
	halt
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wrtvram:
	di
	ld	a,l
	out (0x99),a
	ld	a,h
	set	6,a
	out (0x99),a
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	
	code	page 2
message_pg2:
	db	"rom in page 2",13
clrloop:
	ld   e,3
2:	ld   bc,800h
1:	ld   a,0xF1
	out  (98h),a
	cpi
	jp   pe,1b
	dec  e
	jp   nz,2b
	ret

	code	page 3
message_pg3:	
	db	"rom in page 3",13
chrloop:
	ld   e,3
2:	ld   hl,(004h)
	ld   bc,800h
1:	ld   a,(hl)
	out  (98h),a
	cpi
	jp   pe,1b
	dec  e
	jp   nz,2b
	ret
	


	map 0xD000
slotvar:			#	1
slotram:			#	1
SCC:				#	1
	endmap
