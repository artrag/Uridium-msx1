		; --- ayFX REPLAYER v1.11r ---

		; --- v1.11s AFB file support
		; --- v1.11r If a frame volume is zero then no AYREGS update
		; --- v1.1r  Relative volume using PT3 Volume Table
		; --- v1.1   Explicit priority (as suggested by AR)
		; --- v1.0f  Bug fixed (error when using noise)
		; --- v1.0   Initial release

n_sfx	equ	20
	align 0x100
sfx_prio:
	;	00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20
	db	03,00,02,02,02,02,01,01,04,00,03,01,01,00,00,00,00,00,00,00,00
	
ayFX_STREAMS equ miz_buffer	

ayFX_SETUP:	; --- ayFX replayer setup ---
		ld	hl,	sfxBank_miz
		ld	de,miz_buffer
		call	mom_depack_rom
		ld	a,1				; Starting channel
		ld	(ayFX_CHANNEL),a		; Updated
	
ayFX_END:	; --- End of an ayFX stream ---
		ld	a,255				; Lowest ayFX priority
		ld	(ayFX_PRIORITY),a		; Priority saved (not playing ayFX stream)
		ret					; Return

ayFX_INIT:	; ---     INIT A NEW ayFX STREAM     ---
		; --- INPUT: A -> sound to be played ---
		; ---        C -> Volume     ---
		push	bc				; Store bc in stack
		push	de				; Store de in stack
		push	hl				; Store hl in stack
		ld	l,a					; l:=a (new ayFX stream index)
		ld	h,high sfx_prio		
		ld	h,(hl)				; h:=New priority
		
		ld	a,(ayFX_PRIORITY)	; a:=Current ayFX stream priority
		cp	h					; If new ayFX stream priority is higher than currently one...
		jp	c,_INIT_END			; ...we don't start the new ayFX stream
		; --- INITS ---
		ld	a,h
		ld	(ayFX_PRIORITY),a	; new ayFX stream priority saved in RAM
		ld	b,l					; b:=l (new ayFX stream index)
		; --- Volume adjust using PT3 volume table ---
								; c:=New volume 
		ld	a,15				; a:=15
		sub	c					; a:=15-New volume = relative volume
		jp	z,_INIT_NOSOUND		; If priority is 15 -> no sound output (volume is zero)

        ld  hl,_sfx_vol_fix
        add a,(hl)
        jp  m,_INIT_NOSOUND

		jr  nz,1f
		inc	a
1:        

		add	a,a				; a:=a*2
		add	a,a				; a:=a*4
		add	a,a				; a:=a*8
		add	a,a				; a:=a*16
		ld	e,a				; e:=a
		ld	d,0				; de:=a
		ld	hl,VT_				; hl:=PT3 volume table
		add	hl,de				; hl is a pointer to the relative volume table
		ld	(ayFX_VT),hl			; Save pointer
		; --- ayFX stream pointer ---
		ld	l,b				; l:=b (new ayFX stream index)
		ld	h,0				; hl:=b (new ayFX stream index)
		add	hl,hl				; hl:=hl*2
		ld bc, ayFX_STREAMS+1	; address offset table effects
		add hl, bc				; PATCH for AFB support
		ld c, (hl)
		inc hl
		ld b, (hl)
		add hl, bc			; new effect address obtained in hl	
		ld	(ayFX_POINTER),hl		; Pointer saved in RAM
_INIT_END:	
		pop	hl				; Retrieve hl from stack
		pop	de				; Retrieve de from stack
		pop	bc				; Retrieve bc from stack
		ret					; Return
_INIT_NOSOUND:	; --- Init a sample with relative volume zero -> no sound output ---
		ld	a,255				; Lowest ayFX priority
		ld	(ayFX_PRIORITY),a		; Priority saved (not playing ayFX stream)
		jp	_INIT_END			; Jumps to _INIT_END

ayFX_FRAME:
ayFX_PLAY:	; --- PLAY A FRAME OF AN ayFX STREAM ---
		ld	a,(ayFX_PRIORITY)		; a:=Current ayFX stream priority
		or	a				; If priority has bit 7 on...
		ret	m				; ...return
		; --- Extract control byte from stream ---
		ld	hl,(ayFX_POINTER)		; Pointer to the current ayFX stream
		ld	c,(hl)				; c:=Control byte
		inc	hl				; Increment pointer
		; --- Check if there's new tone on stream ---
		bit	5,c				; If bit 5 c is off...
		jp	z,_CHECK_NN			; ...jump to _CHECK_NN (no new tone)
		; --- Extract new tone from stream ---
		ld	e,(hl)				; e:=lower byte of new tone
		inc	hl				; Increment pointer
		ld	d,(hl)				; d:=higher byte of new tone
		inc	hl				; Increment pointer
		ld	(ayFX_TONE),de			; ayFX tone updated
_CHECK_NN:	; --- Check if there's new noise on stream ---
		bit	6,c				; if bit 6 c is off...
		jp	z,_SETPOINTER			; ...jump to _SETPOINTER (no new noise)
		; --- Extract new noise from stream ---
		ld	a,(hl)				; a:=New noise
		inc	hl				; Increment pointer
		cp	0x20				; If it's an illegal value of noise (used to mark end of stream)...
		jp	z,ayFX_END			; ...jump to ayFX_END
		ld	(ayFX_NOISE),a			; ayFX noise updated
_SETPOINTER:	; --- Update ayFX pointer ---
		ld	(ayFX_POINTER),hl		; Update ayFX stream pointer
		; --- Extract volume ---
		ld	a,c				; a:=Control byte
		and	0x0F				; lower nibble
		; --- Fix the volume using PT3 Volume Table ---
		ld	hl,(ayFX_VT)			; hl:=Pointer to relative volume table
		ld	e,a				; e:=a (ayFX volume)
		ld	d,0				; d:=0
		add	hl,de				; hl:=hl+de (hl points to the relative volume of this frame
		ld	a,(hl)				; a:=ayFX relative volume
		ld	(ayFX_VOLUME),a			; ayFX volume updated
		or	a				; If relative volume is zero...
		ret	z				; ...return (don't copy ayFX values in to AYREGS)
		; -------------------------------------
		; --- COPY ayFX VALUES IN TO AYREGS ---
		; -------------------------------------
		; --- Set noise channel ---
		bit	7,c				; If noise is off...
		jp	nz,_SETMASKS			; ...jump to _SETMASKS
		ld	a,(ayFX_NOISE)			; ayFX noise value
		ld	(AYREGS+6),a			; copied in to AYREGS (noise channel)
_SETMASKS:	; --- Set mixer masks ---
		ld	a,c				; a:=Control byte
		and	0x90				; Only bits 7 and 4 (noise and tone mask for psg reg 7)
		cp	0x90				; If no noise and no tone...
		ret	z				; ...return (don't copy ayFX values in to AYREGS)
		; --- Copy ayFX values in to ARYREGS ---
		rrc	a				; Rotate a to the right (1 TIME)
		rrc	a				; Rotate a to the right (2 TIMES) (OR mask)
		ld	d,0xDB				; d:=Mask for psg mixer (AND mask)
		; --- Calculate next ayFX channel ---
		ld	hl,ayFX_CHANNEL			; Old ayFX playing channel
		dec	(hl)				; New ayFX playing channel
		jp	nz,_SETCHAN			; If not zero jump to _SETCHAN
		ld	(hl),2				; XXX John asks 2 XXX If zero -> set channel 3
_SETCHAN:	ld	b,(hl)				; Channel counter
		inc	b					; XXX John asks for A & B XXX 
_CHK1:		; --- Check if playing channel was 1 ---
		djnz	_CHK2				; Decrement and jump if channel was not 1
_PLAY_C:	; --- Play ayFX stream on channel C ---
		call	_SETMIXER			; Set PSG mixer value (a:=ayFX volume)
		ld	(AYREGS+10),a			; Volume copied in to AYREGS (channel C volume)
		bit	2,c				; If tone is off...
		ret	nz				; ...return
		ld	hl,(ayFX_TONE)			; ayFX tone value
		ld	(AYREGS+4),hl			; copied in to AYREGS (channel C tone)
		ret					; Return
_CHK2:		; --- Check if playing channel was 2 ---
		rrc	d				; Rotate right AND mask
		rrc	a				; Rotate right OR mask
		djnz	_CHK3				; Decrement and jump if channel was not 2
_PLAY_B:	; --- Play ayFX stream on channel B ---
		call	_SETMIXER			; Set PSG mixer value (a:=ayFX volume)
		ld	(AYREGS+9),a			; Volume copied in to AYREGS (channel B volume)
		bit	1,c				; If tone is off...
		ret	nz				; ...return
		ld	hl,(ayFX_TONE)			; ayFX tone value
		ld	(AYREGS+2),hl			; copied in to AYREGS (channel B tone)
		ret					; Return
_CHK3:		; --- Check if playing channel was 3 ---
		rrc	d				; Rotate right AND mask
		rrc	a				; Rotate right OR mask
_PLAY_A:	; --- Play ayFX stream on channel A ---
		call	_SETMIXER			; Set PSG mixer value (a:=ayFX volume)
		ld	(AYREGS+8),a			; Volume copied in to AYREGS (channel A volume)
		bit	0,c				; If tone is off...
		ret	nz				; ...return
		ld	hl,(ayFX_TONE)			; ayFX tone value
		ld	(AYREGS+0),hl			; copied in to AYREGS (channel A tone)
		ret					; Return
_SETMIXER:	; --- Set PSG mixer value ---
		ld	c,a				; c:=OR mask
		ld	a,(AYREGS+7)			; a:=PSG mixer value
		and	d				; AND mask
		or	c				; OR mask
		ld	(AYREGS+7),a			; PSG mixer value updated
		ld	a,(ayFX_VOLUME)			; a:=ayFX volume value
		ret					; Return

		; --- UNCOMMENT THIS IF YOU DON'T USE THIS REPLAYER WITH PT3 REPLAYER ---
; VT_:	INCBIN	"VT.BIN"
		; --- UNCOMMENT THIS IF YOU DON'T USE THIS REPLAYER WITH PT3 REPLAYER ---
		

; ;struc	AR
; AR_TonA		equ 0	;RESW 1
; AR_TonB		equ 2	;RESW 1
; AR_TonC		equ 4	;RESW 1
; AR_Noise	equ 6	;RESB 1
; AR_Mixer	equ 7	;RESB 1
; AR_AmplA	equ 8	;RESB 1
; AR_AmplB	equ 9	;RESB 1
; AR_AmplC	equ 10	;RESB 1
; AR_Env		equ 11	;RESW 1
; AR_EnvTp	equ 13	;RESB 1
; ;endstruc



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

