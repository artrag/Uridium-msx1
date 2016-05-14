;;;;;;;;;;;;;;;;based on Shiru's, modified by Artrag in April 6 2014
	; map  0C000h
; DATA_AREA:		#
; afxNoisePeriod	#	1
; afxBnkAdr		#	2
; AYREGS:     	#	14


; descriptors channels 11 bytes to the channel:
; 0 (2) the current address (the channel is free, if the high byte = # 00)
; 2 (2) Time effect
; 4 (1) the volume
; 5 (1) bits of the mixer
; 6 (2) pitch period
; 8 (1) looping effect if != #00
; 9 (2) starting point if looping

; afxChData       #	3*11
; END_DATA_AREA:	#
	; endmap
	
TonA	EQU 0
TonB	EQU 2
TonC	EQU 4
Noise	EQU 6
Mixer	EQU 7
AmplA	EQU 8
AmplB	EQU 9
AmplC	EQU 10




loopingsfx	equ	0		;	sfx with # up to loopingsfx (excluded) will loop, the higher # will go once

; ------------------------------------------------- ------------- ;
; Initialization player effects. ;
; Turns off all channels , sets variables . ;
; ------------------------------------------------- ------------- ;

AFXINIT
	
	ld	hl,	sfxBank_miz
	ld	de,miz_buffer
	call	mom_depack_rom

AFXSTOP
	LD HL,DATA_AREA
	LD (HL),0
	LD DE,DATA_AREA+1
	LD BC,END_DATA_AREA-DATA_AREA+1
	LDIR

	ld hl,miz_buffer
	inc	hl
	ld (afxBnkAdr), hl; reserve table address offsets

	xor a
	ld (afxNoisePeriod), a

	ld hl, afxChData; mark all channels as empty
	ld de, #00ff
	ld b, 3
afxInit0
	ld (hl), d
	inc hl
	ld (hl), d
	inc hl
	ld (hl), e
	inc hl
	ld (hl), e
	inc hl
	ld (hl), d
	inc hl
	ld (hl), e
	inc hl
	ld (hl), d
	inc hl
	ld (hl), d
	inc hl
	ld (hl), d
	inc hl
	ld (hl), d
	inc hl
	ld (hl), d
	inc hl
	djnz afxInit0
	ret
	
; ------------------------------------------------- ------------- ;
; Playback of the current frame . ;
; With no parameters . ;
; ------------------------------------------------- ------------- ;

AFXFRAME
	ld ix, afxChData
	ld b, 3
afxFrameLoop
	ld a, (ix +1)		; significant byte addresses effect
	or a				; if 0, the channel is not active
	jr z, afxFrameChSkip
	ld h, a
	ld l, (ix +0)		; low byte address effect

	ld a, (hl)			; read information bytes
	inc hl

	ld c, a
	ld (ix +5), a		; remember bits mixer
	and 15
	ld (ix +4), a		; remember volume

	bit 5 , c			; changing pitch period
	jr z, afxFrameNoTone

	ld a, (hl)			; remember period
	inc hl
	ld (ix +6), a
	ld a, (hl)
	inc hl
	ld (ix +7), a

afxFrameNoTone
	bit 6 , c			; period change noise
	jr z, afxFrameNoNoise
	ld a, (hl)			; period obtain
	cp #20 				; if it is more than 31 , the effect is over
	jr c, afxFrameNoise

	ld	a,(ix+ 8)
	and a
	jr	z,1f
						; looping effect
	ld	l,(ix+ 9)		; restart the effect from the beginning
	ld	h,(ix+ 10)
	
	ld (ix +0), l		; remember address
	ld (ix +1), h

	inc (ix +2)			; increment the playing time
	jr nz, afxFrameLoop
	inc (ix +3)
	jr afxFrameLoop
	
1:						; no loop
	xor a				; vanishes high byte address and the volume
	ld (ix +1), a
	ld (ix +4), a
	jr afxFrameChSkip

afxFrameNoise
	inc hl				; remember period noise
	ld (afxNoisePeriod), a

afxFrameNoNoise

	ld (ix +0), l		; remember address
	ld (ix +1), h

	inc (ix +2)			; increment the playing time
	jr nz, afxFrameChSkip
	inc (ix +3)

afxFrameChSkip
	ld de, 11			; the next channel
	add ix, de
	djnz afxFrameLoop

	; ld a, (AYREGS + AmplA)
	; ld c, a
	ld a, (afxChData +0 * 11 +4)
	; cp c
	; jr c, afxSkipCh0
	ld (AYREGS + AmplA), a
	ld a, (afxChData +0 * 11 + 6 )
	ld (AYREGS + TonA +0), a
	ld a, (afxChData +0 * 11 +7 )
	ld (AYREGS + TonA +1), a

	ld a, (AYREGS + Mixer)
	and %11110110
	ld c, a
	ld a, (afxChData +0 * 11 + 5 )
	rra
	rra
	rra
	rra
	and %00001001
	or c
	ld (AYREGS + Mixer), a

afxSkipCh0

	; ld a, (AYREGS + AmplB)
	; ld c, a
	ld a, (afxChData +1 * 11 +4)
	; cp c
	; jr c, afxSkipCh1
	ld (AYREGS + AmplB), a
	ld a, (afxChData +1 * 11 + 6 )
	ld (AYREGS + TonB +0), a
	ld a, (afxChData +1 * 11 +7 )
	ld (AYREGS + TonB +1), a

	ld a, (AYREGS + Mixer)
	and %11101101
	ld c, a
	ld a, (afxChData +1 * 11 + 5 )
	rra
	rra
	rra
	and %00010010
	or c
	ld (AYREGS + Mixer), a

afxSkipCh1

	; ld a, (AYREGS + AmplC)
	; ld c, a
	ld a, (afxChData +2 * 11 +4)
	; cp c
	; jr c, afxSkipCh2
	ld (AYREGS + AmplC), a
	ld a, (afxChData +2 * 11 + 6 )
	ld (AYREGS + TonC +0), a
	ld a, (afxChData +2 * 11 +7 )
	ld (AYREGS + TonC +1), a

	ld a, (AYREGS + Mixer)
	and %11011011
	ld c, a
	ld a, (afxChData +2 * 11 + 5 )
	rra
	rra
	and %00100100
	or c
	ld (AYREGS + Mixer), a

afxSkipCh2

	ld ix, afxChData
	ld a,(ix +0 * 11 +5)
	and  (ix +1 * 11 +5)
	and  (ix +2 * 11 +5)
	rla
	jr c, afxNoNoise
	ld a, (afxNoisePeriod)
	ld (AYREGS + Noise), a
afxNoNoise

	ret

; ------------------------------------------------- ------------- ;
; Running effect on the free channel. In the absence ;
; free channels selects the most long -sounding . ;
; Input : A = number of effect 0 .. 255 ;
; ------------------------------------------------- ------------- ;
AFXPLAY
	push	ix
	push	iy
	ex af,af'

	ld ix, afxChData	; empty channel search
	ld	de,11
	ld	b,3
1:	ld	a,(ix +1)
	or	a
	jr	z,freechan
	add	ix,de
	djnz	1b
						; no free channels
						
	ld iy, afxChData	; search the channel that plays from more time 
	ld ix, afxChData	; in case of 3 looping channels use channel A
	ld de, 0 			; in de the longest time while searching
	ld bc,11
	ld a, 3
afxPlay0
	inc (iy+8)
	dec (iy+8)
	jr nz, afxPlay1		; skip channels with looping effects
	ld l, (iy+2)		; compare time channel with the highest
	ld h, (iy+3)
	sbc	hl,de
	jr c, afxPlay1
	add	hl,de			; remember the longest time
	ex	de,hl
	push iy				; remember the address of the channel in ix
	pop ix
afxPlay1
	add	iy,bc
	dec	a
	jr	nz,afxPlay0
						; expect to address the effect
freechan
	ld h, a
	ex af,af' 			
	ld l, a
	add hl, hl
	ld bc, (afxBnkAdr)	; address offset table effects
	add hl, bc
	ld c, (hl)
	inc hl
	ld b, (hl)
	add hl, bc			; effect address obtained in hl

	ld (ix+0), l		; record in the channel descriptor
	ld (ix+1), h
	ld (ix+2), 0		; reset execution Time
	ld (ix+3), 0
	
	ld (ix+8), 0		; reset looping flag
	
	cp	loopingsfx	; up to sfx #loopingsfx-1 will loop
	jr	nc,1f

	ld	(ix+ 8), -1		; set looping flag
	ld 	(ix+ 9), l		; record in the channel descriptor for later use
	ld 	(ix+10), h

1:
	pop	iy
	pop	ix
	ret

ROUT:
		xor A				; --- FIXES BITS 6 AND 7 OF MIXER ---
		LD	HL,AYREGS+Mixer
		set	7,( hl)
		res	6,( hl)

		LD C,0xA1
		LD HL,AYREGS
1:		OUT (0xA0),A
		INC A
		OUTI 
		CP 13
		JR NZ,1b
		RET
