		; --- PT3 REPLAYER WORKING ON ROM ---
		; --- Can be assembled with sjasm ---
		; --- ROM version: MSX-KUN        ---
		; --- sjasm version: ArtRag       ---

; Based on MSX version of PT3 by Dioniso
;
; This version of the replayer uses a fixed volume and note table, if you need a 
; different note table you can copy it from TABLES.TXT file, distributed with the
; original PT3 distribution. This version also allows the use of PT3 commands.
;
; PLAY and PSG WRITE routines seperated to allow independent calls
;
; ROM LENGTH: 1528 bytes
; RAM LENGTH:  382 bytes

		; --- CONSTANT VALUES DEFINITION ---

;ChannelsVars
;struc	CHNPRM
;reset group
CHNPRM_PsInOr	equ 0	;RESB 1
CHNPRM_PsInSm	equ 1	;RESB 1
CHNPRM_CrAmSl	equ 2	;RESB 1
CHNPRM_CrNsSl	equ 3	;RESB 1
CHNPRM_CrEnSl	equ 4	;RESB 1
CHNPRM_TSlCnt	equ 5	;RESB 1
CHNPRM_CrTnSl	equ 6	;RESW 1
CHNPRM_TnAcc	equ 8	;RESW 1
CHNPRM_COnOff	equ 10	;RESB 1
;reset group

CHNPRM_OnOffD	equ 11	;RESB 1

;IX for PTDECOD here ( +12)
CHNPRM_OffOnD	equ 12	;RESB 1
CHNPRM_OrnPtr	equ 13	;RESW 1
CHNPRM_SamPtr	equ 15	;RESW 1
CHNPRM_NNtSkp	equ 17	;RESB 1
CHNPRM_Note	equ 18	;RESB 1
CHNPRM_SlToNt	equ 19	;RESB 1
CHNPRM_Env_En	equ 20	;RESB 1
CHNPRM_Flags	equ 21	;RESB 1
 ;Enabled - 0,SimpleGliss - 2
CHNPRM_TnSlDl	equ 22	;RESB 1
CHNPRM_TSlStp	equ 23	;RESW 1
CHNPRM_TnDelt	equ 25	;RESW 1
CHNPRM_NtSkCn	equ 27	;RESB 1
CHNPRM_Volume	equ 28	;RESB 1
nsample EQU 29
CHNPRM_Size		equ 30	;RESB 1
;endstruc

;struc	AR
AR_TonA		equ 0	;RESW 1
AR_TonB		equ 2	;RESW 1
AR_TonC		equ 4	;RESW 1
AR_Noise	equ 6	;RESB 1
AR_Mixer	equ 7	;RESB 1
AR_AmplA	equ 8	;RESB 1
AR_AmplB	equ 9	;RESB 1
AR_AmplC	equ 10	;RESB 1
AR_Env		equ 11	;RESW 1
AR_EnvTp	equ 13	;RESB 1
;endstruc

		; --- CODE STARTS HERE ---

CHECKLP:	LD	HL,PT3_SETUP
		SET	7,( HL)
		BIT	0,( HL)
		RET	Z
		POP	HL
		LD	HL,DelyCnt
		INC	( HL)
		LD	HL,ChanA+CHNPRM_NtSkCn
		INC	( HL)
PT3_MUTE:	
		XOR	A
		ld	(music_flag),a
		LD	H,A
		LD	L,A
		LD	( AYREGS+AR_AmplA),A
		LD	( AYREGS+AR_AmplB),HL
		dec a
		ld  (AYREGS+AR_Mixer),a
		ld	hl,mus_mute-100+16
		call	mute_entry
		call	PT3_ROUT
		call 	en_scc
		ret	z
		ld      hl,AYREGS
		ld      de,AYREGS_CPY
		ld      bc,13
		ldir                        ; save a copy of AY register to avoid that SCCROUT get affected by AYFX
		call    probewavechanges
		call    SCCROUT	
		call 	en_slot
		ret
		
PT3_INIT:	;HL - AddressOfModule - 100
		ld	a,0xff
		ld	(music_flag),a

; call unpack with hl pointing to some compressed data, and de pointing to the destination.
		ld  de,100
		add hl,de
		ld  de,music_miz_buffer
		call mom_depack_rom
		ld  hl,music_miz_buffer-100
mute_entry:		
		LD ( PT3_MODADDR),HL
		PUSH HL
		LD DE,100
		ADD HL,DE
		LD A,( HL)
		LD ( PT3_Delay),A
		PUSH HL
		POP IX
		ADD HL,DE
		LD ( PT3_CrPsPtr),HL
		LD E,( IX+102-100)
		ADD HL,DE
		INC HL
		LD ( PT3_LPosPtr),HL
		POP DE
		LD L,( IX+103-100)
		LD H,( IX+104-100)
		ADD HL,DE
		LD ( PT3_PatsPtr),HL
		LD HL,169
		ADD HL,DE
		LD ( PT3_OrnPtrs),HL
		LD HL,105
		ADD HL,DE
		LD ( PT3_SAMPTRS),HL
		LD HL,PT3_SETUP
		RES 7,( HL)

		; --- CREATE PT3 VOLUME TABLE (c) Ivan Roshin, adapted by SapphiRe ---
		ld	hl,0x11
		ld	d,h
		ld	e,h
		ld	IX,VT_+16
		ld	b,15
_INITV1:	push	hl
		add	hl,de
		ex	de,hl
		sbc	hl,hl
		ld	c,b
		ld	b,16
_INITV2:	ld	a,l
		rla
		ld	a,h
		adc	a,0
		ld	( ix),a
		inc	ix
		add	hl,de
		djnz	_INITV2
		pop	hl
		ld	a,e
		cp	0x77
		jr	nz,_INITV3
		inc	e
_INITV3:	ld	b,c
		djnz	_INITV1

		; --- INITIALIZE PT3 VARIABLES ---
		XOR A
		LD HL,VARS
		LD ( HL),A
		LD DE,VARS+1
		LD BC,VAR0END-VARS-1
		LDIR

		INC A
		LD ( DelyCnt),A
		LD HL,0xF001 ;H - CHNPRM_Volume, L - CHNPRM_NtSkCn
		LD ( ChanA+CHNPRM_NtSkCn),HL
		LD ( ChanB+CHNPRM_NtSkCn),HL
		LD ( ChanC+CHNPRM_NtSkCn),HL

		LD HL,EMPTYSAMORN
		LD ( PT3_AdInPtA),HL ;ptr to zero
		LD ( ChanA+CHNPRM_OrnPtr),HL ;ornament 0 is "0,1,0"
		LD ( ChanB+CHNPRM_OrnPtr),HL ;in all versions from
		LD ( ChanC+CHNPRM_OrnPtr),HL ;3.xx to 3.6x and VTII

		LD ( ChanA+CHNPRM_SamPtr),HL ;S1 There is no default
		LD ( ChanB+CHNPRM_SamPtr),HL ;S2 sample in PT3, so, you
		LD ( ChanC+CHNPRM_SamPtr),HL ;S3 can comment S1,2,3; see
					    ;also EMPTYSAMORN comment
		RET

		;pattern decoder
PD_OrSm:	
		LD ( IX+(CHNPRM_Env_En-12)),0
		CALL SETORN
		LD A,( BC)
		INC BC
		RRCA

PD_SAM:		ADD A,A
PD_SAM_:	LD E,A
		LD D,0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SCC patch
;
		LD (IX-12+ nsample),A

		LD HL,( PT3_SAMPTRS)
		ADD HL,DE
		LD E,( HL)
		INC HL
		LD D,( HL)
		LD HL,( PT3_MODADDR)
		ADD HL,DE
		LD ( IX+(CHNPRM_SamPtr-12)),L
		LD ( IX+(CHNPRM_SamPtr+1-12)),H
		JR PD_LOOP

PD_VOL:		RLCA
		RLCA
		RLCA
		RLCA
		LD ( IX+(CHNPRM_Volume-12)),A
		JR PD_LP2
	
PD_EOff:	LD ( IX+(CHNPRM_Env_En-12)),A
		LD ( IX+(CHNPRM_PsInOr-12)),A
		JR PD_LP2

PD_SorE:	DEC A
		JR NZ,PD_ENV
		LD A,( BC)
		INC BC
		LD ( IX+(CHNPRM_NNtSkp-12)),A
		JR PD_LP2

PD_ENV:		CALL SETENV
		JR PD_LP2

PD_ORN:		CALL SETORN
		JR PD_LOOP
       
PD_ESAM:	LD ( IX+(CHNPRM_Env_En-12)),A
		LD ( IX+(CHNPRM_PsInOr-12)),A
		CALL NZ,SETENV
		LD A,( BC)
		INC BC
		JR PD_SAM_

PTDECOD:	LD A,( IX+(CHNPRM_Note-12))
		LD ( PT3_PrNote),A
		LD L,( IX+(CHNPRM_CrTnSl-12))
		LD H,( IX+(CHNPRM_CrTnSl+1-12))
		LD ( PT3_PrSlide),HL

PD_LOOP:	LD DE,0x2010
PD_LP2:		LD A,( BC)
		INC BC
		ADD A,E
		JR C,PD_OrSm
		ADD A,D
		JR Z,PD_FIN
		JR C,PD_SAM
		ADD A,E
		JR Z,PD_REL
		JR C,PD_VOL
		ADD A,E
		JR Z,PD_EOff
		JR C,PD_SorE
		ADD A,96
		JR C,PD_NOTE
		ADD A,E
		JR C,PD_ORN
		ADD A,D
		JR C,PD_NOIS
		ADD A,E
		JR C,PD_ESAM
		ADD A,A
		LD E,A
		LD HL,0xFFFF & (SPCCOMS+0xFF20-0x2000)
		ADD HL,DE
		LD E,( HL)
		INC HL
		LD D,( HL)
		PUSH DE
		JR PD_LOOP

PD_NOIS:	LD ( Ns_Base),A
		JR PD_LP2

PD_REL:		RES 0,( IX+(CHNPRM_Flags-12))
		JR PD_RES
	
PD_NOTE:	LD ( IX+(CHNPRM_Note-12)),A
		SET 0,( IX+(CHNPRM_Flags-12))
		XOR A

PD_RES:		LD ( PT3_PDSP),SP
		LD SP,IX
		LD H,A
		LD L,A
		PUSH HL
		PUSH HL
		PUSH HL
		PUSH HL
		PUSH HL
		PUSH HL
		LD SP,( PT3_PDSP)

PD_FIN:		LD A,( IX+(CHNPRM_NNtSkp-12))
		LD ( IX+(CHNPRM_NtSkCn-12)),A
		RET

C_PORTM:	RES 2,( IX+(CHNPRM_Flags-12))
		LD A,( BC)
		INC BC
		;SKIP PRECALCULATED TONE DELTA ( BECAUSE
		;CANNOT BE RIGHT AFTER PT3 COMPILATION)
		INC BC
		INC BC
		LD ( IX+(CHNPRM_TnSlDl-12)),A
		LD ( IX+(CHNPRM_TSlCnt-12)),A
		LD DE,NT_
		LD A,( IX+(CHNPRM_Note-12))
		LD ( IX+(CHNPRM_SlToNt-12)),A
		ADD A,A
		LD L,A
		LD H,0
		ADD HL,DE
		LD A,( HL)
		INC HL
		LD H,( HL)
		LD L,A
		PUSH HL
		LD A,( PT3_PrNote)
		LD ( IX+(CHNPRM_Note-12)),A
		ADD A,A
		LD L,A
		LD H,0
		ADD HL,DE
		LD E,( HL)
		INC HL
		LD D,( HL)
		POP HL
		SBC HL,DE
		LD ( IX+(CHNPRM_TnDelt-12)),L
		LD ( IX+(CHNPRM_TnDelt+1-12)),H
		LD DE,( PT3_PrSlide)
		LD ( IX+(CHNPRM_CrTnSl-12)),E
		LD ( IX+(CHNPRM_CrTnSl+1-12)),D
		LD A,( BC) ;SIGNED TONE STEP
		INC BC
		EX AF,AF'
		LD A,( BC)
		INC BC
		AND A
		JR Z,_NOSIG
		EX DE,HL
_NOSIG:	SBC HL,DE
		JP P,SET_STP
		CPL
		EX AF,AF'
		NEG
		EX AF,AF'
SET_STP:	LD ( IX+(CHNPRM_TSlStp+1-12)),A
		EX AF,AF'
		LD ( IX+(CHNPRM_TSlStp-12)),A
		LD ( IX+(CHNPRM_COnOff-12)),0
		RET

C_GLISS:	SET 2,( IX+(CHNPRM_Flags-12))
		LD A,( BC)
		INC BC
		LD ( IX+(CHNPRM_TnSlDl-12)),A
		LD ( IX+(CHNPRM_TSlCnt-12)),A
		LD A,( BC)
		INC BC
		EX AF,AF'
		LD A,( BC)
		INC BC
		JR SET_STP

C_SMPOS:	LD A,( BC)
		INC BC
		LD ( IX+(CHNPRM_PsInSm-12)),A
		RET

C_ORPOS:	LD A,( BC)
		INC BC
		LD ( IX+(CHNPRM_PsInOr-12)),A
		RET

C_VIBRT:	LD A,( BC)
		INC BC
		LD ( IX+(CHNPRM_OnOffD-12)),A
		LD ( IX+(CHNPRM_COnOff-12)),A
		LD A,( BC)
		INC BC
		LD ( IX+(CHNPRM_OffOnD-12)),A
		XOR A
		LD ( IX+(CHNPRM_TSlCnt-12)),A
		LD ( IX+(CHNPRM_CrTnSl-12)),A
		LD ( IX+(CHNPRM_CrTnSl+1-12)),A
		RET

C_ENGLS:	LD A,( BC)
		INC BC
		LD ( PT3_Env_Del),A
		LD ( CurEDel),A
		LD A,( BC)
		INC BC
		LD L,A
		LD A,( BC)
		INC BC
		LD H,A
		LD ( PT3_ESldAdd),HL
		RET

C_DELAY:	LD A,( BC)
		INC BC
		LD ( PT3_Delay),A
		RET
	
SETENV:		LD ( IX+(CHNPRM_Env_En-12)),E
		LD ( AYREGS+AR_EnvTp),A
		LD A,( BC)
		INC BC
		LD H,A
		LD A,( BC)
		INC BC
		LD L,A
		LD ( EnvBase),HL
		XOR A
		LD ( IX+(CHNPRM_PsInOr-12)),A
		LD ( CurEDel),A
		LD H,A
		LD L,A
		LD ( CurESld),HL
C_NOP:		RET

SETORN:		ADD A,A
		LD E,A
		LD D,0
		LD ( IX+(CHNPRM_PsInOr-12)),D
		LD HL,( PT3_OrnPtrs)
		ADD HL,DE
		LD E,( HL)
		INC HL
		LD D,( HL)
		LD HL,( PT3_MODADDR)
		ADD HL,DE
		LD ( IX+(CHNPRM_OrnPtr-12)),L
		LD ( IX+(CHNPRM_OrnPtr+1-12)),H
		RET

		;ALL 16 ADDRESSES TO PROTECT FROM BROKEN PT3 MODULES
SPCCOMS:	dw C_NOP
		dw C_GLISS
		dw C_PORTM
		dw C_SMPOS
		dw C_ORPOS
		dw C_VIBRT
		dw C_NOP
		dw C_NOP
		dw C_ENGLS
		dw C_DELAY
		dw C_NOP
		dw C_NOP
		dw C_NOP
		dw C_NOP
		dw C_NOP
		dw C_NOP

CHREGS:		XOR A
		LD ( AYREGS+AR_AmplC),A
		BIT 0,( IX+CHNPRM_Flags)
		PUSH HL
		JP Z,_CH_EXIT
		LD ( PT3_CSP),SP
		LD L,( IX+CHNPRM_OrnPtr)
		LD H,( IX+CHNPRM_OrnPtr+1)
		LD SP,HL
		POP DE
		LD H,A
		LD A,( IX+CHNPRM_PsInOr)
		LD L,A
		ADD HL,SP
		INC A
		CP D
		JR C,_CH_ORPS
		LD A,E
_CH_ORPS:	LD ( IX+CHNPRM_PsInOr),A
		LD A,( IX+CHNPRM_Note)
		ADD A,( HL)
		JP P,_CH_NTP
		XOR A
_CH_NTP:	CP 96
		JR C,_CH_NOK
		LD A,95
_CH_NOK:	ADD A,A
		EX AF,AF'
		LD L,( IX+CHNPRM_SamPtr)
		LD H,( IX+CHNPRM_SamPtr+1)
		LD SP,HL
		POP DE
		LD H,0
		LD A,( IX+CHNPRM_PsInSm)
		LD B,A
		ADD A,A
		ADD A,A
		LD L,A
		ADD HL,SP
		LD SP,HL
		LD A,B
		INC A
		CP D
		JR C,_CH_SMPS
		LD A,E
_CH_SMPS:	LD ( IX+CHNPRM_PsInSm),A
		POP BC
		POP HL
		LD E,( IX+CHNPRM_TnAcc)
		LD D,( IX+CHNPRM_TnAcc+1)
		ADD HL,DE
		BIT 6,B
		JR Z,_CH_NOAC
		LD ( IX+CHNPRM_TnAcc),L
		LD ( IX+CHNPRM_TnAcc+1),H
_CH_NOAC:	EX DE,HL
		EX AF,AF'
		LD L,A
		LD H,0
		LD SP,NT_
		ADD HL,SP
		LD SP,HL
		POP HL
		ADD HL,DE
		LD E,( IX+CHNPRM_CrTnSl)
		LD D,( IX+CHNPRM_CrTnSl+1)
		ADD HL,DE
		LD SP,( PT3_CSP)
		EX ( SP),HL
		XOR A
		OR ( IX+CHNPRM_TSlCnt)
		JR Z,_CH_AMP
		DEC ( IX+CHNPRM_TSlCnt)
		JR NZ,_CH_AMP
		LD A,( IX+CHNPRM_TnSlDl)
		LD ( IX+CHNPRM_TSlCnt),A
		LD L,( IX+CHNPRM_TSlStp)
		LD H,( IX+CHNPRM_TSlStp+1)
		LD A,H
		ADD HL,DE
		LD ( IX+CHNPRM_CrTnSl),L
		LD ( IX+CHNPRM_CrTnSl+1),H
		BIT 2,( IX+CHNPRM_Flags)
		JR NZ,_CH_AMP
		LD E,( IX+CHNPRM_TnDelt)
		LD D,( IX+CHNPRM_TnDelt+1)
		AND A
		JR Z,_CH_STPP
		EX DE,HL
_CH_STPP:	SBC HL,DE
		JP M,_CH_AMP
		LD A,( IX+CHNPRM_SlToNt)
		LD ( IX+CHNPRM_Note),A
		XOR A
		LD ( IX+CHNPRM_TSlCnt),A
		LD ( IX+CHNPRM_CrTnSl),A
		LD ( IX+CHNPRM_CrTnSl+1),A
_CH_AMP:	LD A,( IX+CHNPRM_CrAmSl)
		BIT 7,C
		JR Z,_CH_NOAM
		BIT 6,C
		JR Z,_CH_AMIN
		CP 15
		JR Z,_CH_NOAM
		INC A
		JR _CH_SVAM
_CH_AMIN:	CP -15
		JR Z,_CH_NOAM
		DEC A
_CH_SVAM:	LD ( IX+CHNPRM_CrAmSl),A
_CH_NOAM:	LD L,A
		LD A,B
		AND 15
		ADD A,L
		JP P,_CH_APOS
		XOR A
_CH_APOS:	CP 16
		JR C,_CH_VOL
		LD A,15
_CH_VOL:	OR ( IX+CHNPRM_Volume)
		LD L,A
		LD H,0
		LD DE,VT_
		ADD HL,DE
		LD A,( HL)
_CH_ENV:	BIT 0,C
		JR NZ,_CH_NOEN
		OR ( IX+CHNPRM_Env_En)
_CH_NOEN:	LD ( AYREGS+AR_AmplC),A
		BIT 7,B
		LD A,C
		JR Z,_NO_ENSL
		RLA
		RLA
		SRA A
		SRA A
		SRA A
		ADD A,( IX+CHNPRM_CrEnSl) ;SEE COMMENT BELOW
		BIT 5,B
		JR Z,_NO_ENAC
		LD ( IX+CHNPRM_CrEnSl),A
_NO_ENAC:	LD HL,PT3_AddToEn
		ADD A,( HL) ;BUG IN PT3 - NEED WORD HERE.
			   ;FIX IT IN NEXT VERSION?
		LD ( HL),A
		JR _CH_MIX
_NO_ENSL:	RRA
		ADD A,( IX+CHNPRM_CrNsSl)
		LD ( AddToNs),A
		BIT 5,B
		JR Z,_CH_MIX
		LD ( IX+CHNPRM_CrNsSl),A
_CH_MIX:	LD A,B
		RRA
		AND 0x48
_CH_EXIT:	LD HL,AYREGS+AR_Mixer
		OR ( HL)
		RRCA
		LD ( HL),A
		POP HL
		XOR A
		OR ( IX+CHNPRM_COnOff)
		RET Z
		DEC ( IX+CHNPRM_COnOff)
		RET NZ
		XOR ( IX+CHNPRM_Flags)
		LD ( IX+CHNPRM_Flags),A
		RRA
		LD A,( IX+CHNPRM_OnOffD)
		JR C,_CH_ONDL
		LD A,( IX+CHNPRM_OffOnD)
_CH_ONDL:	LD ( IX+CHNPRM_COnOff),A
		RET

PT3_PLAY:	XOR A
		LD ( PT3_AddToEn),A
		LD ( AYREGS+AR_Mixer),A
		DEC A
		LD ( AYREGS+AR_EnvTp),A
		LD HL,DelyCnt
		DEC ( HL)
		JP NZ,_PL2
		LD HL,ChanA+CHNPRM_NtSkCn
		DEC ( HL)
		JR NZ,_PL1B
		LD BC,( PT3_AdInPtA)
		LD A,( BC)
		AND A
		JR NZ,_PL1A
		LD D,A
		LD ( Ns_Base),A
		LD HL,( PT3_CrPsPtr)
		INC HL
		LD A,( HL)
		INC A
		JR NZ,_PLNLP
		CALL CHECKLP
		LD HL,( PT3_LPosPtr)
		LD A,( HL)
		INC A
_PLNLP:	LD ( PT3_CrPsPtr),HL
		DEC A
		ADD A,A
		LD E,A
		RL D
		LD HL,( PT3_PatsPtr)
		ADD HL,DE
		LD DE,( PT3_MODADDR)
		LD ( PT3_PSP),SP
		LD SP,HL
		POP HL
		ADD HL,DE
		LD B,H
		LD C,L
		POP HL
		ADD HL,DE
		LD ( PT3_AdInPtB),HL
		POP HL
		ADD HL,DE
		LD ( PT3_AdInPtC),HL
		LD SP,( PT3_PSP)

_PL1A:		LD IX,ChanA+12
		CALL PTDECOD
		LD ( PT3_AdInPtA),BC

_PL1B:		LD HL,ChanB+CHNPRM_NtSkCn
		DEC ( HL)
		JR NZ,_PL1C
		LD IX,ChanB+12
		LD BC,( PT3_AdInPtB)
		CALL PTDECOD
		LD ( PT3_AdInPtB),BC

_PL1C:		LD HL,ChanC+CHNPRM_NtSkCn
		DEC ( HL)
		JR NZ,_PL1D
		LD IX,ChanC+12
		LD BC,( PT3_AdInPtC)
		CALL PTDECOD
		LD ( PT3_AdInPtC),BC

_PL1D:		LD A,( PT3_Delay)
		LD ( DelyCnt),A

_PL2:		LD IX,ChanA
		LD HL,( AYREGS+AR_TonA)
		CALL CHREGS
		LD ( AYREGS+AR_TonA),HL
		LD A,( AYREGS+AR_AmplC)
		LD ( AYREGS+AR_AmplA),A
		LD IX,ChanB
		LD HL,( AYREGS+AR_TonB)
		CALL CHREGS
		LD ( AYREGS+AR_TonB),HL
		LD A,( AYREGS+AR_AmplC)
		LD ( AYREGS+AR_AmplB),A
		LD IX,ChanC
		LD HL,( AYREGS+AR_TonC)
		CALL CHREGS
		LD ( AYREGS+AR_TonC),HL

		LD HL,( Ns_Base_AddToNs)
		LD A,H
		ADD A,L
		LD ( AYREGS+AR_Noise),A

		LD A,( PT3_AddToEn)
		LD E,A
		ADD A,A
		SBC A,A
		LD D,A
		LD HL,( EnvBase)
		ADD HL,DE
		LD DE,( CurESld)
		ADD HL,DE
		LD ( AYREGS+AR_Env),HL

		XOR A
		LD HL,CurEDel
		OR ( HL)
		RET Z
		DEC ( HL)
		RET NZ
		LD A,( PT3_Env_Del)
		LD ( HL),A
		LD HL,( PT3_ESldAdd)
		ADD HL,DE
		LD ( CurESld),HL
		RET


EMPTYSAMORN: 	db 0,1,0,0x90 ;delete $90 if you don't need default sample

NT_:	;Note table 2 ( if you use another in Vortex Tracker II copy it and paste
	;it from TABLES.TXT)

	dw 0x0D10,0x0C55,0x0BA4,0x0AFC,0x0A5F,0x09CA,0x093D,0x08B8,0x083B,0x07C5,0x0755,0x06EC
	dw 0x0688,0x062A,0x05D2,0x057E,0x052F,0x04E5,0x049E,0x045C,0x041D,0x03E2,0x03AB,0x0376
	dw 0x0344,0x0315,0x02E9,0x02BF,0x0298,0x0272,0x024F,0x022E,0x020F,0x01F1,0x01D5,0x01BB
	dw 0x01A2,0x018B,0x0174,0x0160,0x014C,0x0139,0x0128,0x0117,0x0107,0x00F9,0x00EB,0x00DD
	dw 0x00D1,0x00C5,0x00BA,0x00B0,0x00A6,0x009D,0x0094,0x008C,0x0084,0x007C,0x0075,0x006F
	dw 0x0069,0x0063,0x005D,0x0058,0x0053,0x004E,0x004A,0x0046,0x0042,0x003E,0x003B,0x0037
	dw 0x0034,0x0031,0x002F,0x002C,0x0029,0x0027,0x0025,0x0023,0x0021,0x001F,0x001D,0x001C
	dw 0x001A,0x0019,0x0017,0x0016,0x0015,0x0014,0x0012,0x0011,0x0010,0x000F,0x000E,0x000D
