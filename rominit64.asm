
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set pages and subslot
;


ENASLT:			equ		024h
RSLREG:			equ		0138h
EXPTBL:			equ		0FCC1h	; Bios Slot / Expansion Slot


; ----------------------------
; pre-set main slot for page 3
; and set sub-slot for page 3
; ----------------------------
	macro	mainslot_setup n
	and		3
[2]	rrca
	and		0xC0
	ld		c,a
	ld		a,d
	and		0x3F
	or		c
	ld		c,a					; Primary slot value with main slot in page 3

	ld		a,b
	and		0x0C
[2]	rrca
	and		3
	ld		b,a					; B = Expanded slot in page 3
	ld		a,c
	out		(0A8h),a			; Slot : Main Slot, xx, xx, Main slot
	ld		a,(0FFFFh)
	cpl
	if (n<=4)
[n]	RLCA
	else
[8-n] RRCA	
	endif
	and		0xFC
	or		b
	if (n<=4)
[n]	RRCA
	else
[8-n] RLCA
	endif
	ld		(0FFFFh),a		; Expanded slot selected
	ld		b,a				; save for later	
	endmacro
		

; ------------------------------
; SEARCH_SLOT
; look for the slot of our rom
; active in page 1
; ------------------------------

search_slot:
	call	RSLREG
[2]	rrca
	and		3
	ld		c,a
	ld		b,0
	ld		hl,EXPTBL
	add		hl,bc
	ld		a,(hl)
	and		080h
	or		c
	ld		c,a
[4]	inc		hl
	ld		a,(hl)
	and		0Ch
	or		c
	ld		(slotvar),a
	ret
	
; ------------------------------
; look for the slot of ram
; active in page 3
; ------------------------------

search_slotram:
	di
	call	RSLREG
[2]	rlca
	and		3
	ld		c,a
	ld		b,0
	ld		hl,EXPTBL
	add		hl,bc
	ld		a,(hl)
	and		080h
	jr		z,search_slotram0
	or		c
	ld		c,a
[4]	inc		hl
	ld		a,(hl)
[4]	rlca
	and		0Ch
search_slotram0:
	or		c
	ld		(slotram),a
	ret
	
; ------------------------------
; SETROMPAGE0
; Set the chart in
; Page 0
; -----------------------------

setrompage0:
	ld		a,(slotvar)
	jp		setslotpage0

setrompage2:
	ld		a,(slotvar)
	jp		setslotpage2

setrampage2:
	ld		a,(slotram)
	jp		setslotpage2
	
setrompage3:
	ld		a,(slotvar)
	jp		setslotpage3

setrampage3:
	ld		a,(slotram)
	jp		setslotpage3
	
; ------------------------------
; RECBIOS
; set the bios ROM
; -------------------------------
recbios:
	ld		a,(EXPTBL)

; ---------------------------
; SETSLOTPAGE0
; Set the slot passed in A
; at page 0 in the Z80 address space
; A: Format FxxxSSPP
; ----------------------------

setslotpage0:
	di
	ld		b,a					; B = Slot param in FxxxSSPP format
	in		a,(0A8h)
	and		0xFC
	ld		d,a					; D = Primary slot value
	ld		a,b
	and		3
	or		d
	ld		d,a		; D = Final Value for primary slot
	ld		a,b		; Check if expanded
	bit		7,a
	jr		z,1f	; Not Expanded
	mainslot_setup	0
1:	ld		a,d				; A = Final value
	out		(0A8h),a		; Slot Final. Ram, rom c, rom c, Main
	ret

; ---------------------------
; SETSLOTPAGE1
; Set the slot passed in A
; at page 1 in the Z80 address space
; A: Format FxxxSSPP
; ----------------------------

setslotpage1:
	di
	ld		b,a					; B = Slot param in FxxxSSPP format
	in		a,(0A8h)
[2]	RRCA
	and		0xFC
	ld		d,a					; D = Primary slot value
	ld		a,b
	and		3
	or		d
[2]	RLCA
	ld		d,a		; D = Final Value for primary slot
	ld		a,b		; Check if expanded
	bit		7,a
	jr		z,1f	; Not Expanded
	mainslot_setup	6
1:	ld		a,d				; A = Final value
	out		(0A8h),a		; Slot Final. Ram, rom c, rom c, Main
	ret
	

; ---------------------------
; SETSLOTPAGE2
; Set the slot passed in A
; at page 2 in the Z80 address space
; A: Format FxxxSSPP
; ----------------------------

setslotpage2:
	di
	ld		b,a					; B = Slot param in FxxxSSPP format
	in		a,(0A8h)
[4]	RLCA
	and		0xFC
	ld		d,a					; D = Primary slot value
	ld		a,b
	and		3
	or		d
[4]	RRCA
	ld		d,a		; D = Final Value for primary slot
	ld		a,b		; Check if expanded
	bit		7,a
	jr		z,1f	; Not Expanded
	mainslot_setup	4
1:	ld		a,d				; A = Final value
	out		(0A8h),a		; Slot Final. Ram, rom c, rom c, Main
	ret
	
; ---------------------------
; SETSLOTPAGE3
; Set the slot passed in A
; at page 3 in the Z80 address space
; A: Format FxxxSSPP
; ----------------------------
	
setslotpage3:
	di
	ld		b,a					; B = Slot param in FxxxSSPP format
	in		a,(0A8h)
[2]	RLCA
	and		0xFC
	ld		d,a					; D = Primary slot value
	ld		a,b
	and		3
	or		d
[2]	RRCA	
	ld		d,a		; D = Final Value for primary slot
	ld		a,b		; Check if expanded
	bit		7,a
	jr		z,1f	; Not Expanded
	mainslot_setup	2
1:	ld		a,d				; A = Final value
	out		(0A8h),a		; Slot Final. Ram, rom c, rom c, Main
	ret
