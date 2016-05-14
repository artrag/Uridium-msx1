    ; global _ayFX_PRIORITY
_ayFX_PRIORITY:
ayFX_PRIORITY:	ds	1			; Current ayFX stream priority

		; --- THIS FILE MUST BE COMPILED IN RAM ---

ayFX_PLAYING:	ds	1			; There's an ayFX stream to be played?
ayFX_CURRENT:	ds	1			; Current ayFX stream playing
ayFX_POINTER:	ds	2			; Pointer to the current ayFX stream
ayFX_TONE:	    ds	2			; Current tone of the ayFX stream
ayFX_NOISE: 	ds	1			; Current noise of the ayFX stream
ayFX_VOLUME:	ds	1			; Current volume of the ayFX stream
ayFX_CHANNEL:	ds	1			; PSG channel to play the ayFX stream
ayFX_VT:		ds	2			; ayFX relative volume table pointer

_psg_vol_fix:	ds	1

				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

vsf:         ds 1          ; 0 if 50Hz, !0 if 60Hz
cnt:         ds 1          ; counter to compensate NTSC machines

; AYREGS:		ds	14
ayend: