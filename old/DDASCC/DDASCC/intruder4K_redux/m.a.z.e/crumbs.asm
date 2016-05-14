;; -------------------------------------------------------------------
;; 
;; -------------------------------------------------------------------

;; MSX bios calls

wrtvdp: equ $0047
rdvrm:  equ $004a
wrtvrm: equ $004d
setwrt: equ $0053
filvrm: equ $0056
ldirmv: equ $0059
ldirvm: equ $005c
clrspr: equ $0069
initxt: equ $006c
init32: equ $006f
chput:  equ $00a2
erafnk: equ $00cc
gtstck: equ $00d5
gttrig: equ $00d8
breakx: equ $00b7
cls:    equ $00c3


linl40: equ $f3ae
linl32: equ $f3af
cnsdfg: equ $f3de
csry:   equ $f3dc
csrx:   equ $f3dd
forclr: equ $f3e9
bakclr: equ $f3ea
bdrclr: equ $f3eb
rndx:   equ $f857
htimi:  equ $fd9f
rg1sav: equ $f3e0
crtcnt: equ $f3b1

;; MSX vram areas
	
t32cgp: equ $0000

	;; -------------------------------------------------------------------
	;; print number
	;; -------------------------------------------------------------------
	;; hl = number to print
	;; -------------------------------------------------------------------

prnum:
	ex   de,hl
    call prnum2
	ld   d,e
prnum2:
    ld   a,d
    rrca
    rrca
    rrca
    rrca
    and  $0f
    add  48
	call wrtvrm
	inc  hl
    ld   a,d
    and  $0f
    add  48
	call wrtvrm
	inc  hl
	ret

	;; -------------------------------------------------------------------
	;; -------------------------------------------------------------------
	;; print
	;; -------------------------------------------------------------------
	;; de = pointer to 0 terminated string
	;; hl = location in vram to print to
	;; -------------------------------------------------------------------

prstr:
	ld   a,(de)
	inc  de
	and  a
	ret  z
	call wrtvrm
	inc  hl
	jr   prstr

	;; -------------------------------------------------------------------
	;; delay
	;; -------------------------------------------------------------------

delay:
	ld  b,100
_delay:
	halt
	djnz    _delay
	ret

	
	;; -------------------------------------------------------------------
	;; rand8
	;; -------------------------------------------------------------------
	;; out:	a = 8 bits random number
	;; -------------------------------------------------------------------

rand8:
    push    hl
    ld      hl,(randSeed)
    add     hl,hl
    sbc     a,a
    and     $83
    xor     l
    ld      l,a
    rlca
    ld      (randSeed),hl
    pop     hl
    ret
    
	;; -------------------------------------------------------------------
	;; decimal increment
	;; -------------------------------------------------------------------
	;; in:  hl - number to be bcd incremented
	;; out:	hl - incremented value
	;; -------------------------------------------------------------------    

bcdInc16:
    ld      a,l
    inc     a
    daa
    ld      l,a
    ld      a,h
    adc     0
    daa
    ld      h,a
    ret


	;; -------------------------------------------------------------------
	;; decimal decrement
	;; -------------------------------------------------------------------
	;; in:  hl - number to be bcd decremented
	;;      c  - value to decrement with
	;; out:	hl - decremented value
	;; -------------------------------------------------------------------    
bcdSub16:
    ld      a,l
    sub     c
    daa
    ld      l,a
    ld      a,h
    sbc     0
    daa
    ld      h,a
    ret
