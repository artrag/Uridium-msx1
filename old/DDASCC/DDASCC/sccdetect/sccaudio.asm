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

Audio_init_code:

; some ayFX init

    call	ayFX_SETUP

; some PT3 init

    call    PT3_MUTE

; some scc init

    call 	_SCC_PSG_Volume_balance
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   compute SCC/PSG Volume balance
;


_SCC_PSG_Volume_balance:

    ld  a,(_psg_vol_fix)
    add a,15
    jr  nz,1f
    ld  a,1
1:        
    add	a,a				; a:=a*2
    add	a,a				; a:=a*4
    add	a,a				; a:=a*8
    add	a,a				; a:=a*16
    ld	e,a				; e:=a
    ld	d,0				; de:=a
    ld	hl,VT_			; hl:=PT3 volume table
    add	hl,de			; hl is a pointer to the relative volume table

    ld  (VolBalance),hl
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Interrupt handler
;

    

Audio_I_O_code:

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Audio I/O
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; --- Place this instruction on interrupt --- 
	; --- or after HALT instruction to synchronize music ---

    call    PT3_ROUT		 ; Write values on PSG registers
    
    jp      nz,1f
    call    probewavechanges
    call    SCCROUT
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Audio Internal code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Audio_Internal_code:

    ld  a,010111111B
    ld  (AYREGS+7),a

; Only if musics are in ROM


    ; --- To speed up VDP writes you can place this instruction after all of them, but before next INT ---
    call    PT3_PLAY			; Calculates PSG values for next frame

    ld      hl,AYREGS
    ld      de,AYREGS_CPY
    ld      bc,13
    ldir                        ; save a copy of AY register to avoid that SCCROUT get affected by AYFX

    ; --- PSG/SCC volume balance
    ; only for music

    ld  de,(VolBalance)

    ld	ix,AYREGS+8
   
    ld  l,(ix+0)
    ld  h,0
    add hl,de
    ld  a,(hl)
    ld  (ix+0),a

    ld  l,(ix+1)
    ld  h,0
    add hl,de
    ld  a,(hl)
    ld  (ix+1),a
    
    ld  l,(ix+2)
    ld  h,0
    add hl,de
    ld  a,(hl)
    ld  (ix+2),a
    
    ; ayFX player section
 
    ; --- To speed up VDP writes you can place this instruction after all of them, but before next INT ---
    call     ayFX_FRAME			; Calculates PSG values for next frame

	ret


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
		OUT (C),A
		LD A,(HL)
		AND A
		RET M
		INC C
		OUT (C),A
		RET




;-------------------------------------




