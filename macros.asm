;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; vdp access
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_vdpReg 	equ 0xF3DF
LINL40		equ 0xF3AE
JIFFY:		equ 0xFC9E

enaslt:          equ #0024
exptbl:          equ #fcc1
slttbl:          equ #fcc5

; ------------
; macro

	macro _setVdp register,value	   ; macro definition
	ld	a,value
	out (0x99),a
	ld	a,register + 0x80
	out (0x99),a
	endmacro

	macro setVdp register,value		  ; macro definition
	di
	_setVdp register,value
	ei
	endmacro

	macro _setvdpwvram value
	if (value & 0xFF)
		ld	a,value & 0xFF
	else
		xor a
	endif
	out (0x99),a
	ld	a,0x40 + (value/256)
	out (0x99),a
	endmacro

	macro setvdpwvram value
	di
	_setvdpwvram value
	ei
	endmacro

