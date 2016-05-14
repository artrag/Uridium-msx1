;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Mapper Konami 5 (mapper +  scc)
;
; Bank 1: 5000h - 57FFh (5000h used)
; Bank 2: 7000h - 77FFh (7000h used)
; Bank 3: 9000h - 97FFh (9000h used)
; Bank 4: B000h - B7FFh (B000h used)

Bank1   equ      0x5000
Bank2   equ      0x7000
Bank3   equ      0x9000
Bank4   equ      0xB000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

; Audio_init_code:

; ; some ayFX init

    ; call	ayFX_SETUP

; ; some PT3 init

    ; call    PT3_MUTE

; ; some scc init

    ; call 	_SCC_PSG_Volume_balance
	; ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   compute SCC/PSG Volume balance
;


_SCC_PSG_Volume_balance:

    ld  a,(_psg_vol_fix)
    add a,15
    jr  nz,1f
    inc	a
1:        
    add	a,a				; a:=a*2
    add	a,a				; a:=a*4
    add	a,a				; a:=a*8
    add	a,a				; a:=a*16
    ld	e,a				; e:=a
    ld	d,0				; de:=a
    ld	hl,VT_			; hl:=PT3 volume table
    add	hl,de			; hl is a pointer to the relative volume table

    ld  (_psg_vol_balance),hl
		
    ld  a,(_scc_vol_fix)
    add a,15
    jr  nz,1f
    inc	a
1:        
    add	a,a				; a:=a*2
    add	a,a				; a:=a*4
    add	a,a				; a:=a*8
    add	a,a				; a:=a*16
    ld	e,a				; e:=a
    ld	d,0				; de:=a
    ld	hl,VT_			; hl:=PT3 volume table
    add	hl,de			; hl is a pointer to the relative volume table

    ld  (_scc_vol_balance),hl
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Interrupt handler
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Audio I/O
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; --- Place this instruction on interrupt --- 
	; --- or after HALT instruction to synchronize music ---
no_music:
	xor	a
	LD	H,A
	LD	L,A
	LD	( AYREGS+AR_AmplA),A
	LD	( AYREGS_CPY+AR_AmplA),A
	LD	( AYREGS+AR_AmplB),HL
	LD	( AYREGS_CPY+AR_AmplB),HL
	ld  a,010111111B
	ld  (AYREGS+AR_Mixer),a
	ld  (AYREGS_CPY+AR_Mixer),a
    jp     ayFX_FRAME			; Calculates PSG values for next frame
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Audio Internal code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Audio_Internal_code:

; Only if musics are in ROM
	ld	a,(music_flag)
	and	a
	jr	z,no_music

    ld  a,010111111B
    ld  (AYREGS+7),a
	
	ex	af,af'				; preserve af'
	push	af
	call    PT3_PLAY			; Calculates PSG values for next frame
	pop		af
	ex	af,af'
	
    ld      hl,AYREGS
    ld      de,AYREGS_CPY
    ld      bc,13
    ldir                        ; save a copy of AY register to avoid that SCCROUT get affected by AYFX
1:
    ; --- PSG/SCC volume balance
    ; psg attenuation - only for music

    ld  de,(_psg_vol_balance)
   
	ld  hl,(AYREGS+8)
	ld	b,h
    ld  h,0
    add hl,de
    ld  c,(hl)

    ld  l,b
    ld  h,0
    add hl,de
    ld  b,(hl)
    ld  (AYREGS+8),bc
    
    ld  a,(AYREGS+10)
	ld	l,a
    ld  h,0
    add hl,de
    ld  a,(hl)
    ld  (AYREGS+10),a


    ; --- PSG/SCC volume balance
    ; scc attenuation - only for music

    ld  de,(_scc_vol_balance)
   
    ld  hl,(AYREGS_CPY+8)
	ld	b,h
    ld  h,0
    add hl,de
    ld  c,(hl)

    ld  l,b
    ld  h,0
    add hl,de
    ld  b,(hl)
    ld  (AYREGS_CPY+8),bc
    
    ld  a,(AYREGS_CPY+10)
	ld	l,a
    ld  h,0
    add hl,de
    ld  a,(hl)
    ld  (AYREGS_CPY+10),a
    
    ; ayFX player section
 
    ; --- To speed up VDP writes you can place this instruction after all of them, but before next INT ---
    jp     ayFX_FRAME			; Calculates PSG values for next frame

	
;-------------------------------------

PT3_ROUT:
        XOR A
        
		LD	HL,AYREGS+7
		set	7,(hl)        ; --- FIXES BITS 6 AND 7 OF MIXER ---
		res	6,(hl)        ; --- FIXES BITS 6 AND 7 OF MIXER ---

		LD C,0xA0
		LD HL,AYREGS
_LOUT:
        OUT (C),A
		INC C
		OUTI
		DEC C
		INC A
		CP 13
		JR NZ,_LOUT
		RET




;-------------------------------------




