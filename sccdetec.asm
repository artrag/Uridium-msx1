;------------------------------------------------------------
; SCC-search v1.0
; by Alwin Henseler
; using method described in bulletin # 18 MSX-club Enschede
; input: none
; output: B=slot that contains SCC (=255 if no SCC found)

; enaslt:          equ #0024
; exptbl:          equ #fcc1
; slttbl:          equ #fcc5




begin:
	MAP #c000
	in a,(#a8)        ; read prim. slotregister
	rra
	rra
	rra
	rra
	and %00000011     ; A = prim.slot page 2
	ld b,0
	ld c,a
	ld hl,exptbl
	add hl,bc
	bit 7,(hl)        ; page 2-slot expanded ?
	jr z,scctest
	ld hl,slttbl
	add hl,bc
	ld a,(hl)         ; A = sec.sel.reg. of page 2-slot
	rra
	rra
	and %00001100     ; bit 1/2 = sec.slot page 2
	or c
	set 7,a           ; compose sec.slot-code
scctest:
	push af           ; save page 2-slot on the stack
	ld a,(exptbl)     ; 1st slot to test

testslot:        
	push af           ; save test-slot on the stack
	ld h,#80
	call enaslt       ; switch slot-to-test in 8000-bfffh
	ld hl,#9000
	ld b,(hl)         ; save contents of address 9000h
	ld (hl),#3f       ; activate SCC (if present)

	xor	a
	ld (0xbffe),a	  ; scc+ patch for bluemsx

	ld h,#9c          ; address of SCC-register mirrors
	ld de,#9800       ; 9800h = address of SCC-registers
testreg:         
	ld a,(de)
	ld c,a            ; save contents of address 98xxh
	ld a,(hl)         ; read byte from address 9cxxh
	cpl               ; and invert it
	ld (de),a         ; write inverted byte to 98xxh
	cp (hl)           ; same value on 9cxxh ?
	ld a,c
	ld (de),a         ; restore value on 98xxh
	jr nz,nextslot    ; unequal -> no SCC -> continue search
	inc hl
	inc de            ; next test-addresses
	bit 7,l           ; 128 addresses (registers) tested ?
	jr z,testreg      ; no -> repeat mirror-test
	ld a,b
	ld (#9000),a      ; restore value on 9000h
	pop bc            ; retrieve slotcode (=SCC-slot) from stack
	jr done           ; SCC found, restore page 2-slot & return

nextslot:
	ld a,b
	ld (#9000),a      ; restore value on 9000h
	pop bc            ; retrieve slotcode from stack
	bit 7,b           ; test-slot = sec.slot ?
	jr z,nextprim
	ld a,b
	add a,4           ; increase sec.slotnumber
	bit 4,a           ; sec.slot = 4 ?
	jr z,testslot
nextprim:
	ld a,b
	and %00000011
	cp 3              ; prim.slot = 3 ?
	jr z,noscc
	inc a             ; increase prim.slotnumber
	ld d,0
	ld e,a
	ld hl,exptbl
	add hl,de
	or (hl)           ; combine slot-expansion with slotcode
	jr testslot

noscc:           
	ld b,255          ; code for no SCC
done:            
	pop af            ; retrieve page 2-slot from stack
	push bc
	ld h,#80
	call enaslt       ; restore original page 2-slot
	pop bc
	ei
	ret
end:
	endmap				 
; -------------------------------------------------------------


; ====================
;    Initialization
; ====================
SCCINIT
	ld	hl,begin
	ld	de,0C000H
	ld	bc,end-begin+1
	ldir
	call	0C000H
	ld	a,b
	ld	(SCC),a
	ret

; SLOT            .db     0
; PAGE1RAM        .db     0
; RAMSLOT         .db     0

; SCC             .db     0
; SUB             .db     0FFH

