		; --- ayFX REPLAYER v1.2f ---

		; --- v1.2f  ayFX bank support
		; --- v1.11f If a frame volume is zero then no AYREGS update
		; --- v1.1f  Fixed volume for all ayFX streams
		; --- v1.1   Explicit priority (as suggested by AR)
		; --- v1.0f  Bug fixed (error when using noise)
		; --- v1.0   Initial release

ayFX_SETUP:	; ---          ayFX replayer setup          ---
		; --- INPUT: HL -> pointer to the ayFX bank ---
		ld	[ayFX_BANK],hl			; Current ayFX bank
		ld	a,1				; Starting channel
		ld	[ayFX_CHANNEL],a		; Updated
ayFX_END:	; --- End of an ayFX stream ---
		ld	a,255				; Lowest ayFX priority
		ld	[ayFX_PRIORITY],a		; Priority saved (not playing ayFX stream)
		ret					; Return

ayFX_INIT:	; ---     INIT A NEW ayFX STREAM     ---
		; --- INPUT: A -> sound to be played ---
		; ---        C -> sound priority     ---
		push	bc				; Store bc in stack
		push	de				; Store de in stack
		push	hl				; Store hl in stack
		; --- Check if the index is in the bank ---
		ld	b,a				; b:=a (new ayFX stream index)
		ld	hl,[ayFX_BANK]			; Current ayFX BANK
		ld	a,[hl]				; Number of samples in the bank
		or	a				; If zero (means 256 samples)...
		jp	z,@@CHECK_PRI			; ...goto @@CHECK_PRI
		; The bank has less than 256 samples
		ld	a,b				; a:=b (new ayFX stream index)
		cp	[hl]				; If new index is not in the bank...
		ld	a,2				; a:=2 (error 2: Sample not in the bank)
		jp	nc,@@INIT_END			; ...we can't init it
@@CHECK_PRI:	; --- Check if the new priority is lower than the current one ---
		; ---   Remember: 0 = highest priority, 15 = lowest priority  ---
		ld	a,b				; a:=b (new ayFX stream index)
		ld	a,[ayFX_PRIORITY]		; a:=Current ayFX stream priority
		cp	c				; If new ayFX stream priority is lower than current one...
		ld	a,1				; a:=1 (error 1: A sample with higher priority is being played)
		jp	c,@@INIT_END			; ...we don't start the new ayFX stream
		; --- Set new priority ---
		ld	a,c				; a:=New priority
		and	$0F				; We mask the priority
		ld	[ayFX_PRIORITY],a		; new ayFX stream priority saved in RAM
		; --- Calculate the pointer to the new ayFX stream ---
		ld	de,[ayFX_BANK]			; de:=Current ayFX bank
		inc	de				; de points to the increments table of the bank
		ld	l,b				; l:=b (new ayFX stream index)
		ld	h,0				; hl:=b (new ayFX stream index)
		add	hl,hl				; hl:=hl*2
		add	hl,de				; hl:=hl+de (hl points to the correct increment)
		ld	e,[hl]				; e:=lower byte of the increment
		inc	hl				; hl points to the higher byte of the correct increment
		ld	d,[hl]				; de:=increment
		add	hl,de				; hl:=hl+de (hl points to the new ayFX stream)
		ld	[ayFX_POINTER],hl		; Pointer saved in RAM
		xor	a				; a:=0 (no errors)
@@INIT_END:	pop	hl				; Retrieve hl from stack
		pop	de				; Retrieve de from stack
		pop	bc				; Retrieve bc from stack
		ret					; Return

ayFX_PLAY:	; --- PLAY A FRAME OF AN ayFX STREAM ---
		ld	a,[ayFX_PRIORITY]		; a:=Current ayFX stream priority
		or	a				; If priority has bit 7 on...
		ret	m				; ...return
		; --- Extract control byte from stream ---
		ld	hl,[ayFX_POINTER]		; Pointer to the current ayFX stream
		ld	c,[hl]				; c:=Control byte
		inc	hl				; Increment pointer
		; --- Check if there's new tone on stream ---
		bit	5,c				; If bit 5 c is off...
		jp	z,@@CHECK_NN			; ...jump to @@CHECK_NN (no new tone)
		; --- Extract new tone from stream ---
		ld	e,[hl]				; e:=lower byte of new tone
		inc	hl				; Increment pointer
		ld	d,[hl]				; d:=higher byte of new tone
		inc	hl				; Increment pointer
		ld	[ayFX_TONE],de			; ayFX tone updated
@@CHECK_NN:	; --- Check if there's new noise on stream ---
		bit	6,c				; if bit 6 c is off...
		jp	z,@@SETPOINTER			; ...jump to @@SETPOINTER (no new noise)
		; --- Extract new noise from stream ---
		ld	a,[hl]				; a:=New noise
		inc	hl				; Increment pointer
		cp	$20				; If it's an illegal value of noise (used to mark end of stream)...
		jp	z,ayFX_END			; ...jump to ayFX_END
		ld	[ayFX_NOISE],a			; ayFX noise updated
@@SETPOINTER:	; --- Update ayFX pointer ---
		ld	[ayFX_POINTER],hl		; Update ayFX stream pointer
		; --- Extract volume ---
		ld	a,c				; a:=Control byte
		and	$0F				; lower nibble
		ld	[ayFX_VOLUME],a			; ayFX volume updated
		ret	z				; Return if volume is zero (don't copy ayFX values in to AYREGS)
		; -------------------------------------
		; --- COPY ayFX VALUES IN TO AYREGS ---
		; -------------------------------------
		; --- Set noise channel ---
		bit	7,c				; If noise is off...
		jp	nz,@@SETMASKS			; ...jump to @@SETMASKS
		ld	a,[ayFX_NOISE]			; ayFX noise value
		ld	[AYREGS+6],a			; copied in to AYREGS (noise channel)
@@SETMASKS:	; --- Set mixer masks ---
		ld	a,c				; a:=Control byte
		and	$90				; Only bits 7 and 4 (noise and tone mask for psg reg 7)
		cp	$90				; If no noise and no tone...
		ret	z				; ...return (don't copy ayFX values in to AYREGS)
		; --- Copy ayFX values in to ARYREGS ---
		rrc	a				; Rotate a to the right (1 TIME)
		rrc	a				; Rotate a to the right (2 TIMES) (OR mask)
		ld	d,$DB				; d:=Mask for psg mixer (AND mask)
		; --- Calculate next ayFX channel ---
		ld	hl,ayFX_CHANNEL			; Old ayFX playing channel
		dec	[hl]				; New ayFX playing channel
		jp	nz,@@SETCHAN			; If not zero jump to @@SETCHAN
		ld	[hl],3				; If zero -> set channel 3
@@SETCHAN:	ld	b,[hl]				; Channel counter
@@CHK1:		; --- Check if playing channel was 1 ---
		djnz	@@CHK2				; Decrement and jump if channel was not 1
@@PLAY_C:	; --- Play ayFX stream on channel C ---
		call	@@SETMIXER			; Set PSG mixer value (a:=ayFX volume)
		ld	[AYREGS+10],a			; Volume copied in to AYREGS (channel C volume)
		bit	2,c				; If tone is off...
		ret	nz				; ...return
		ld	hl,[ayFX_TONE]			; ayFX tone value
		ld	[AYREGS+4],hl			; copied in to AYREGS (channel C tone)
		ret					; Return
@@CHK2:		; --- Check if playing channel was 2 ---
		rrc	d				; Rotate right AND mask
		rrc	a				; Rotate right OR mask
		djnz	@@CHK3				; Decrement and jump if channel was not 2
@@PLAY_B:	; --- Play ayFX stream on channel B ---
		call	@@SETMIXER			; Set PSG mixer value (a:=ayFX volume)
		ld	[AYREGS+9],a			; Volume copied in to AYREGS (channel B volume)
		bit	1,c				; If tone is off...
		ret	nz				; ...return
		ld	hl,[ayFX_TONE]			; ayFX tone value
		ld	[AYREGS+2],hl			; copied in to AYREGS (channel B tone)
		ret					; Return
@@CHK3:		; --- Check if playing channel was 3 ---
		rrc	d				; Rotate right AND mask
		rrc	a				; Rotate right OR mask
@@PLAY_A:	; --- Play ayFX stream on channel A ---
		call	@@SETMIXER			; Set PSG mixer value (a:=ayFX volume)
		ld	[AYREGS+8],a			; Volume copied in to AYREGS (channel A volume)
		bit	0,c				; If tone is off...
		ret	nz				; ...return
		ld	hl,[ayFX_TONE]			; ayFX tone value
		ld	[AYREGS+0],hl			; copied in to AYREGS (channel A tone)
		ret					; Return
@@SETMIXER:	; --- Set PSG mixer value ---
		ld	c,a				; c:=OR mask
		ld	a,[AYREGS+7]			; a:=PSG mixer value
		and	d				; AND mask
		or	c				; OR mask
		ld	[AYREGS+7],a			; PSG mixer value updated
		ld	a,[ayFX_VOLUME]			; a:=ayFX volume value
		ret					; Return
