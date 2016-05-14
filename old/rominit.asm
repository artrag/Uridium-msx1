
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set pages and subslot
;


ENASLT:			equ		024h
RSLREG:			equ		0138h
EXPTBL:			equ		0FCC1h	; Bios Slot / Expansion Slot



; -----------------------
; SEARCH_SLOTSET
; set in page  2
; our ROM.
; -----------------------

rominit:
search_slotset:
	di
	call	search_slot
	jp		ENASLT

; -----------------------
; SEARCH_SLOT
; look for the slot of our rom
; -----------------------

search_slot:
	call	RSLREG
	rrca
	rrca
	and		3
	ld		c,a
	ld		b,0
	ld		hl,EXPTBL
	add		hl,bc
	ld		a,(hl)
	and		080h
	or		c
	ld		c,a
	inc		hl
	inc		hl
	inc		hl
	inc		hl
	ld		a,(hl)
	and		0Ch
	or		c;
	ld		h,080h
	ld		(slotvar),a
	ret

; ------------------------------
; SETROMPAGE0
; Set the chart in
; Page 0
; -----------------------------

setrompage0:
	ld		a,(slotvar)
	jr		setslotpage0

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
	ld		d,a					; D = Final Value for primary slot

	; Check if expanded
	ld		a,b
	bit		7,a
	jr		z,1f	; Not Expanded

	and		3
	rrca
	rrca
	and		0xC0
	ld		c,a
	ld		a,d
	and		0x3F
	or		c
	ld		c,a					; Primary slot value with main slot in page 3

	ld		a,b
	and		0x0C
	rrca
	rrca
	and		3
	ld		b,a					; B = Expanded slot in page 3
	ld		a,c
	out		(0A8h),a			; Slot : Main Slot, xx, xx, Main slot
	ld		a,(0FFFFh)
	cpl
	and		0xFC
	or		b
	ld		(0FFFFh),a			; Expanded slot selected

1:
	ld		a,d				; A = Final value
	out		(0A8h),a		; Slot Final. Ram, rom c, rom c, Main
	ret
