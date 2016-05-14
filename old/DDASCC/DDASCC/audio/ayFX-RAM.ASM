		; --- ayFX REPLAYER v1.11r ---

		; --- THIS FILE MUST BE COMPILED IN RAM ---

ayFX_PRIORITY:	FIELD	1			; Current ayFX stream priority
ayFX_POINTER:	FIELD	2			; Pointer to the current ayFX stream
ayFX_TONE:	    FIELD	2			; Current tone of the ayFX stream
ayFX_NOISE:	    FIELD	1			; Current noise of the ayFX stream
ayFX_VOLUME:	FIELD	1			; Current volume of the ayFX stream
ayFX_CHANNEL:	FIELD	1			; PSG channel to play the ayFX stream
ayFX_VT:	    FIELD	2			; ayFX relative volume table pointer

_psg_vol_fix:   FIELD	1

		; --- UNCOMMENT THIS IF YOU DON'T USE THIS REPLAYER WITH PT3 REPLAYER ---
;AYREGS:		.ds	14			; Ram copy of PSG registers
		; --- UNCOMMENT THIS IF YOU DON'T USE THIS REPLAYER WITH PT3 REPLAYER ---
