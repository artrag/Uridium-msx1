		; --- THIS FILE MUST BE COMPILED IN RAM ---

		; --- PT3 WORKAREA [self-modifying code patched] ---

PT3_SETUP:		FIELD	1	;set bit0 to 1, if you want to play without looping
					        ;bit7 is set each time, when loop point is passed
PT3_MODADDR:		FIELD	2
PT3_CrPsPtr:		FIELD	2  ; Patter# = CrPsPtr-song_buffer-101;
PT3_SAMPTRS:		FIELD	2
PT3_OrnPtrs:		FIELD	2
PT3_PDSP:		FIELD	2
PT3_CSP:		FIELD	2
PT3_PSP:		FIELD	2
PT3_PrNote:		FIELD	1
PT3_PrSlide:		FIELD	2
PT3_AdInPtA:		FIELD	2
PT3_AdInPtB:		FIELD	2
PT3_AdInPtC:		FIELD	2
PT3_LPosPtr:		FIELD	2
PT3_PatsPtr:		FIELD	2
PT3_Delay:		FIELD	1
PT3_AddToEn:		FIELD	1
PT3_Env_Del:		FIELD	1
PT3_ESldAdd:		FIELD	2

VARS: FIELD 0

ChanA:			FIELD	30			;CHNPRM_Size
ChanB:			FIELD	30			;CHNPRM_Size
ChanC:			FIELD	30			;CHNPRM_Size

;GlobalVars
DelyCnt:		FIELD	1
CurESld:		FIELD	2
CurEDel:		FIELD	1

Ns_Base_AddToNs:	FIELD 0
Ns_Base:		FIELD	1
AddToNs:		FIELD	1

AYREGS:     FIELD 0
VT_:			FIELD	14
EnvBase:		FIELD	2
VAR0END:		FIELD	240
