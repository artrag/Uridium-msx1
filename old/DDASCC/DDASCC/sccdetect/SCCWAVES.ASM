

;--------------------------------------------------------
_WAVESSCC:                                               ; 15 instruments



  
	ds     32;     empty
;    db     242,235,234,209,219,213,219,205,202,238,225,6,4,10,17,26,8,254,8,255,5,21,27,27,53,54,31,46,38,7,254,240			; 01_piano.wav

    db     242,235,234,209,219,213,219,205,202,238,225,6,4,10,17,26,8,254,8,255,5,21,27,27,53,54,31,46,38,7,254,240			; 01_piano.wav
    db     43,30,15,11,250,248,236,234,237,251,2,248,3,248,237,242,239,231,253,246,14,11,0,8,239,223,240,229,1,33,47,58		; 02_harpsch.wav
    db     59,59,50,38,25,15,254,234,218,205,209,223,228,233,245,3,23,45,58,57,40,13,245,223,208,200,193,199,224,254,27,49	; 03_harp.wav
    db     210,195,203,222,255,21,33,25,20,16,0,251,245,238,253,20,27,29,22,14,9,0,246,236,232,237,2,25,33,24,253,230		; 04_strgs.wav
    db     204,194,205,226,255,23,39,52,34,16,1,239,232,247,1,21,39,41,23,15,5,254,248,244,231,242,11,15,24,18,246,215		; 05_slwstr.wav
    db     49,42,33,25,18,5,238,213,196,195,214,243,10,20,16,2,245,239,239,244,250,255,2,2,254,249,244,245,255,19,40,51		; 06_flute.wav
    db     59,63,60,47,30,16,10,8,4,0,250,244,240,242,246,248,247,240,232,225,219,215,208,203,206,217,234,255,17,33,46,55	; 07_fltvib.wav
    db     0,0,254,255,1,3,6,4,255,250,240,228,219,220,250,41,192,35,1,3,4,5,0,252,252,255,2,1,248,245,248,253				; 08_trmpt.wav
    db     243,4,27,23,16,23,20,22,22,4,254,231,213,215,216,230,243,1,27,43,58,58,38,23,5,236,221,224,224,222,226,229		; 09_strpzz.wav
    db     240,7,23,31,46,35,43,24,14,5,230,228,214,207,215,221,239,3,13,32,35,45,43,32,26,0,247,228,212,214,209,221		; 10_clst.wav
    db     254,214,193,203,221,228,221,211,209,210,212,219,229,232,233,246,10,16,0,249,12,32,32,32,46,52,37,19,13,15,7,243	; 11_mrmb.wav
    db     6,216,0,15,241,219,239,3,12,46,245,23,20,229,6,21,212,228,211,211,18,1,245,49,19,246,37,32,15,19,223,244			; 12_vln.wav
    db     242,194,210,213,212,210,236,5,15,38,40,30,26,26,20,24,250,243,245,235,243,234,220,237,246,252,30,47,28,38,43,29	; 13_vlnvb.wav
    db     58,63,62,57,51,47,44,43,45,49,54,58,59,60,59,59,58,58,57,57,56,56,56,55,55,54,54,54,53,53,52,52					; 14_snrdr.wav
	db	   38,209,31,234,227,231,255,13,34,44,23,248,228,255,23,34,18,8,4,2,255,254,255,246,238,237,245,243,226,215,213,17	; 15_aaaaaaa.wav

	

;-------------------------------------
;  scc eches for PT3
;-------------------------------------
SCC_REG     EQU 009880h           ;SCC ADDRESS FUNCTION

SCCROUT:
            ;Frequencies
		call en_scc
        ld  a,03Fh
        ld  (Bank3),a

        LD  HL,(AYREGS_CPY+0)       ; A-> ch 1 
        LD  (SCC_REG+0),HL
        LD  HL,(AYREGS_CPY+2)       ; C-> ch 2
        LD  (SCC_REG+2),HL
        LD  HL,(AYREGS_CPY+4)       ; B-> ch 3
        LD  (SCC_REG+4),HL

            ;VOLUMES

        ld      a,(AYREGS_CPY+8)
        ld      (SCC_REG+0x0A),a    ; A-> ch 1 
        ld      a,(AYREGS_CPY+9)
        LD      (SCC_REG+0x0B),A    ; C-> ch 2
        ld      a,(AYREGS_CPY+10)
        LD      (SCC_REG+0x0C),A    ; B-> ch 3

            ;MIXER

        ld      a,(AYREGS_CPY+7)
        xor     7        
        and     7
        ld      (SCC_REG+0x0F),a

        ; ld  a,(__BBR)
        ; inc a
        ; ld  (Bank3),a

		call en_slot
        RET


;-------------------------------------
; A-> ch 1 
; B-> ch 2
; C-> ch 3


setsccwaves:

    di
	
	call en_scc
	
    ld      a,3fh
    ld      (Bank3),a

    ld      de,0x09800
    ld      a,(wchA)                            ; A->ch1
    call    sccchan                             

    ld      a,(wchB)                            ; B->ch2
    call    sccchan

    ld      a,(wchC)                            ; C->ch3
    call    sccchan

   	call en_slot

	ret


sccchan:
    push    hl
    ld      l,a
    ld      h,0
    rept 4
    add     hl,hl
    endm
    ld      bc, _WAVESSCC
    add     hl,bc
    ld      bc,32
    ldir
    pop     hl
    ret




probewavechanges:
   	call en_scc

     ld  hl,OSmplA

     ld  a,(ChanA+29)
     cp  (hl)
     call  nz,changeA

     inc hl
     ld  a,(ChanB+29)
     cp  (hl)
     call  nz,changeB

     inc hl
     ld  a,(ChanC+29)
     cp  (hl)
     call  nz,changeC

	call en_slot
    ret


changeA:
    ld      (hl),a
    call    samp2wav
    ld      (wchA),a
    ld      de,0x09800                      ; A->ch1
    jp      1f
    
changeB:
    ld      (hl),a
    call    samp2wav
    ld      (wchB),a
    ld      de,0x09800+32*1                 ; B->ch2
    jp      1f

changeC:
    ld      (hl),a
    call    samp2wav
    ld      (wchC),a
    ld      de,0x09800+32*2                 ; C->ch3

1:
    ld      c,a

    ld      a,3fh
    ld      (Bank3),a

    ld      a,c
    call    sccchan      
    
    ; ld      a,(__BBR)
    ; ld      (Bank2),a
    ; inc     a
    ; ld      (Bank3),a
    ; inc     a
    ; ld      (Bank4),a

    ret



samp2wav:
     exx
     ld hl,_waves
     rrca
     ld e,a
     ld d,0
     add   hl,de
     ld    a,(hl)
     add   a,a
     exx
     ret
     
en_scc:
		ld	a,[SCC]				; Recuperamos el slot
		ld	h,0x80
		call enaslt
		ret
		
		; in	a,[$0A8]			; Leemos el registro principal de slots
		; and		11001111b		; D = Valor del slot primario
		; ld		d,a
		; ld	a,[SCC]				; Recuperamos el slot
		; and	$03					; Nos fijamos en el slot primario
		; rept 4
		; add	a,a
		; endm
		; or	d				; Colocamos los bits de las paginas superiores
		; out	[$A8],a				; Slots: Seleccionado, xx, xx, Ram
		; ret
en_slot:
		ld	a,[SLOTGAME]
		ld	h,0x80
		call enaslt
		ret

		; in	a,[$0A8]			; Leemos el registro principal de slots
		; and		11001111b		; D = Valor del slot primario
		; ld		d,a
		; ld	a,[SLOTGAME]
		; and	$03					; Nos fijamos en el slot primario
		; rept 4
		; add	a,a
		; endm
		; or	d				; Colocamos los bits de las paginas superiores
		; out	[$A8],a				; Slots: Seleccionado, xx, xx, Ram
		; ret
