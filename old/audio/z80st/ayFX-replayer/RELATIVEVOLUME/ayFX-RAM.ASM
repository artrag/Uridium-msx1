		; --- ayFX REPLAYER v1.2r ---

		; --- THIS FILE MUST BE COMPILED IN RAM ---

ayFX_BANK:	.ds	2			; Current ayFX Bank
ayFX_PRIORITY:	.ds	1			; Current ayFX stream priotity
ayFX_POINTER:	.ds	2			; Pointer to the current ayFX stream
ayFX_TONE:	.ds	2			; Current tone of the ayFX stream
ayFX_NOISE:	.ds	1			; Current noise of the ayFX stream
ayFX_VOLUME:	.ds	1			; Current volume of the ayFX stream
ayFX_CHANNEL:	.ds	1			; PSG channel to play the ayFX stream
ayFX_VT:	.ds	2			; ayFX relative volume table pointer

		; --- UNCOMMENT THIS IF YOU DON'T USE THIS REPLAYER WITH PT3 REPLAYER ---
;AYREGS:		.ds	14			; Ram copy of PSG registers
		; --- UNCOMMENT THIS IF YOU DON'T USE THIS REPLAYER WITH PT3 REPLAYER ---
