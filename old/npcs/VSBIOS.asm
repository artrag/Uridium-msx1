
;MEGAROM address
_bank1			equ	0x6000
_bank2			equ	0x7000

bb1	equ	0x6000	;	Bank 1: 6000h - 67FFh (6000h used)
bb2	equ	0x6800	;	Bank 2: 6800h - 6FFFh (6800h used)
bb3	equ	0x7000	;	Bank 3: 7000h - 77FFh (7000h used)
bb4	equ	0x7800	;	Bank 4: 7800h - 7FFFh (7800h used)

;VRAM Addresses
sc1tnp         equ      #1800
sc1tc          equ      #2000
sc1tgp         equ      #0000

sc2tgp         equ      #0000
sc2tnp         equ      #1800
sc2sat         equ      #1b00
sc2tc          equ      #2000
sc2tgs         equ      #3800

nbgames        equ      6

; RAM            equ      #c400
currentsel     equ      freeram
lastselpos     equ      currentsel+1
pingpong       equ      lastselpos+1
joy            equ      pingpong+1
joy_value      equ      joy+1
launch_program equ      joy_value+1

;MSX BIOS functions
dcompr: 	equ	#20	;compare hl et de
disscr:		equ	#41	;disable screen
enascr:		equ	#44	;enable screen
FILVRM		equ	0056H	
ldirmv		equ	#59	;vram -> ram
ldirvm		equ	#5c	;ram -> vram
chgmod		equ	#5f	;change graphic mode
chgclr		equ	#62	;change colors
clrspr		equ	#69	;clear sprites
init32          equ     #6f     ;set screen 1

INIGRP		equ	0072H		; set screen 2
GICINI		equ	0090H		; PSG init
WRTPSG		equ	0093H	

beep		equ	#c0	;beep!!
cls			equ	#c3	;clear screen
gtstck		equ	#d5	;get joystick
gttrig		equ	#d8	;get trigger
gtpad		equ	#db	;get pad

CHGSND		equ	0135H

snsmat      equ     #141    ;get keyboard Matrix



bigfil		equ	#16b	;fill vram
nsetrd		equ	#16e	;new set add for read
nstwrt		equ	#171	;new set add for write
nrdvrm		equ	#174	;new read vram
nwrvrm		equ	#177	;new write vram
chgcpu 	    equ	#180	;change cpu mode
getcpu      equ	#183	;get cpu mode

wrboot:		equ	#0000
bdos:		equ	#0005
rdslt:		equ	#000c
wrslt:		equ	#0014
CALSLT:		equ	#001c
enaslt:		equ	#0024
callf:		equ	#0030
setdma: 	equ     26
read:   	equ     39
open:   	equ     15
close:  	equ     16

CLIKSW: 	equ 0xF3DB
RG7SAV:		equ 0xF3e6
FORCLR:		equ 0xF3E9

subrom:		equ	#faf8		;sub rom slot
hokvld:		equ	#fb20
exttbl:		equ	#fcc1		;main rom slot
extbio:		equ	#ffca



; ------------
; macro

    macro _setVdp register,value       ; macro definition
    ld  a,value
    out (0x99),a
    ld  a,register + 0x80
    out (0x99),a
    endmacro

    macro setVdp register,value       ; macro definition
    di
    _setVdp register,value
    ei
    endmacro

    macro _setvdpwvram value
    if (value & 0xFF)
        ld  a,value & 0xFF
    else
        xor a
    endif
    out (0x99),a
    ld  a,0x40 + (value/256)
    out (0x99),a
    endmacro


macro outvdp value,reg
	ld a,value
	out (#99),a
	ld a,reg
	out (#99),a
endmacro

macro	calslt	SLOTADD,ADD	;inter slot call macro
	ld	iy,(SLOTADD-1)
	ld	ix,ADD
	call	CALSLT
endmacro

macro wait_hbl

VA@$YM
	in a,(#99)
	and %00100000
	jp nz,VA@$YM
VB@$YM
	in a,(#99)
	and %00100000
	jp z,VB@$YM
endmacro
;Common routines

psg_off:
	call GICINI
	xor	a
	call 2f
	ld	e,0xBF
	call	WRTPSG
	inc	a
2:	ld	b,6
1:	call	WRTPSG
	inc	a
	djnz	1b
	
	ret

; Mult h by e
; result in hl
mult8:
	ld l,0
	ld d,0
	ld b,8
mulloop:
	add hl,hl
	jr nc,suite
	add hl,de
suite:
	djnz mulloop
	ret

; Hex to BCD
; converts a hex number (eg. $10) to its BCD representation (eg. $16).
; Input: a = hex number
; Output: a = BCD number
; Clobbers: b,c
HexToBCD:
  ld c,a  ; Original (hex) number
   ld b,8  ; How many bits
   xor a   ; Output (BCD) number, starts at 0
HTBLOOP: sla c   ; shift c into carry
   adc a,a
   daa     ; Decimal adjust a, so shift = BCD x2 plus carry
   djnz HTBLOOP  ; Repeat for 8 bits
; Multiply DE by A and put the result in AHL
mult_a_de
   ld	c, 0
   ld	h, c
   ld	l, h

   add	a, a		; optimised 1st iteration
   jr	nc, $+4
   ld	h,d
   ld	l,e

   ld b, 7
_loop:
   add	hl, hl
   rla
   jr	nc, $+4
   add	hl, de
   adc	a, c            ; yes this is actually adc a, 0 but since c is free we set it to zero and so we can save 1 byte and up to 3 T-states per iteration

   djnz	_loop

   ret
testspace:
	ld a,8
	call snsmat
	and 1
	ret
testesc:
	ld a,7
	call snsmat
	and 4
	ret


; Select screen mode
; in : A contains the screen mode number
setscreenmode:
	calslt	exttbl,chgmod
	ret

; Simulate RST20 (compare hl,de) under dos
simrst20:
	ld a,h
	sub d
	ret nz
	ld a,l
	sub e
	ret
; Change frequency Pal / NTSC
chfreq:
	ld a,(#ffe8)
	xor 2
	ld (#ffe8),a
	out (#99),a
	ld a,128+9
	out (#99),a
	ret

; Set color palette
; in : hl points on the palette table
setpal:
	xor a
	ld c,#9a
	out (#99),a
	ld a,128+16
	out (#99),a
	ld b,32
	otir
	ret

; Vpoke: position write address = de
; Only works in the first 64 kb of vram
vpoke:
	ld a,e
	out (#99),a
	ld a,d
	and %00111111
	or %01000000
	out (#99),a
	ret


;*******************************************************************
;
;	lecture des joystick (port 0, 1, 2) voir #d5 du bios
;
;*******************************************************************
rd_stk:	dec	a
	jp	m,keybrd	;saut si clavier (port 0)
	call	sel_stk		;selection du port joystick
	ld	hl,stick_tbl1
end_stk:
	and	#0f
	ld	e,a
	ld	d,0
	add	hl,de
	ld	a,(hl)
	or	a		;position le flag z si rien de nouveau ;-)
	ret

keybrd:	call	rd_stk0
	rrca
	rrca
	rrca
	rrca
	ld	hl,stick_tbl2
	jr	end_stk

sel_stk:			;selection du port joystick 1 ou 2
	ld	b,a		;numero de port dans b
	ld	a,#0f
	call	rd_psgport
	djnz	port2

	and	#df		;joystick port 1
	or	#03
	jp	rd_stick

port2   and	#af		;joystick port 2
	or	#03
rd_stick:
	out	(#a1),a
	call	rd_joy
	ret

	
; PSG I/O port A (r#14) – read-only
; Bit	Description	Comment
; 0	Input joystick pin 1	(up)
; 1	Input joystick pin 2	(down)
; 2	Input joystick pin 3	(left)
; 3	Input joystick pin 4	(right)
; 4	Input joystick pin 6	(trigger A)
; 5	Input joystick pin 7	(trigger B)
; 6	Japanese keyboard layout bit	(1=JIS, 0=ANSI)
; 7	Cassette input signal	

rd_joy:
	ld	a,#0e
rd_psgport:
	out	(#a0),a
	in	a,(#a2)
	ret

rd_stk0:			;lit joystick port 0
	in	a,(#aa)
	and	#f0
	add	a,8
	out	(#aa),a
	in	a,(#a9)
	ret

stick_tbl1:
	defb	0,5,1,0,3,4,2,3,7,6,8,7,0,5,1,0
stick_tbl2:
	defb	0,3,5,4,1,2,0,3,7,0,6,5,8,1,7,0


;*********************************************************
;
;	lecture des switch fire voir #d8 du bios
;
;*********************************************************
rd_stg:
	dec	a
	jp	m,kbd_stg	;si strig 0 saute
	push	af
	and	1
	call	sel_stk
	pop	bc
	dec	b
	dec	b
	ld	b,#10
	jp	m,stg1
	ld	b,#20
stg1:	
	and	b
stg2:	
	sub	1
	sbc	a,a
	or	a		;positionne le flag z si pas d'appui
	ret

kbd_stg:
	call	rd_stk0
	and	1
	jr	stg2


  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; returns 1 in a and clears z flag if vdp is 60Hz
;;
; CheckIf60Hz:

        ; in      a,(0x99)
        ; nop
        ; nop
        ; nop
; vdpSync:
         ; in      a,(0x99)
		 ; nop
         ; and     0x80
         ; jr      z,vdpSync
    
         ; ld      hl,0x900
; vdpLoop:
         ; dec     hl
         ; ld      a,h
         ; or      l
         ; jr      nz,vdpLoop
    
         ; in      a,(0x99)
         ; rlca
         ; and     1
         ; ret

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set pages and subslot
;
   
codeinit:
	call    0x138 ; Read primary slot register
	rrca
	rrca
	and     0x03  ; a = value for Page 1.
	ld      c,a
	ld      b,0
	ld      hl,0xfcc1
	add     hl,bc
	or      (hl)  ; (HL) = #80 = Slot 1 expanded, Slot 1 = not expanded.
	ld      b,a
	inc     hl
	inc     hl
	inc     hl
	inc     hl
	ld      a,(hl)
	and     0x0c
	or      b
	ld      h,0x80
	call    0x24
        ; make emulators detect correct romtype (ascii 8)
	xor	a
	ld	(bb1),a
	inc	a
	ld	(bb2),a
	inc	a
	ld	(bb3),a
	inc	a
	ld	(bb4),a
    ret
	




;  LOCATE X = H , Y = L
;
;
printathl:
        di
		
        ld a,l   ;       L= Y POSITIOn (0 to 23)
		rrca
        rrca
        rrca
        ld d,a
        and %11100000
        or h     ;       H = X Position (0 to 31)
        ld e,a   ;       lower part of address is in e

        ld a,d
        and %11  ;
        ld d,a   ;       Higher part of address is in H
        ld hl,sc1tnp
        add hl,de

        ld a,l
        out (#99),a
        ld a,h
        and %00111111
        or %01000000
        out (#99),a

print_loop:

        ld a,(bc)
        cp "!"
        ret z
		add	a,116-'!'
        out (#98),a
        inc bc
        jp print_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    struct enemy_data
y               db  0
x               dw  0
status          db  0
cntr            db  0
kind            db  0
frame			db	0
color			db	0
speed           dw  0
tmr				dw	0
    ends

max_enem	equ 8



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; NPC initialization - fake for testing
;
npc_init:
    ld  ix,enemies
    ld  b,max_enem
	ld	c,0
	ld	de,0
	ld	hl,intx_y

1:  push	bc
	ld  (ix+enemy_data.status),0
	
	ld	a,(hl)
    ld  (ix+enemy_data.x),a
    inc	hl
	ld	a,(hl)
	ld  (ix+enemy_data.x+1),a
	inc	hl
	
	ld	a,(hl)
    ld  (ix+enemy_data.y),a
	inc	hl

	ld	a,(hl)
    ld  (ix+enemy_data.kind),a
	inc	hl

	ld	(ix+enemy_data.cntr),0

	ld	a,(hl)
    ld  (ix+enemy_data.tmr),a
	inc	hl
	ld	a,(hl)
    ld  (ix+enemy_data.tmr+1),a
	inc	hl
		
    ld  bc,enemy_data
    add ix,bc
	pop	bc
    djnz    1b
	
	ret
	
intx_y:
	dw	-16				;snake
	db	192-32-8,0
	dw	5*50
	
	
	dw	255				;eyes
	db	144+40-4,1
	dw	15*50
	
	dw	255-32			;wrath
	db	192+16	,2
	dw	11*50
	
	dw	255				;skull
	db	0		,3
	dw	20*50
	
	dw	-32				;krokodil1
	db	40-2	,4
	dw	25*50
	
	dw	-16				;krokodil2
	db	40-2	,5
	dw	25*50

	dw	5*8				;plane1
	db	128		,6
	dw	30*50

	dw	256-16-5*8			;plane2
	db	128+8		,7
	dw	35*50
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   logic for enemies - fake for testing

npc_loop:
    ld  ix,enemies
    ld  b,max_enem
1:
    ld  e,(ix+enemy_data.tmr)
    ld  d,(ix+enemy_data.tmr+1)
	ld	a,e
	or	d
	jr	z,2f
	dec	de
    ld  (ix+enemy_data.tmr),e
    ld  (ix+enemy_data.tmr+1),d
	jr	3f
2:	
	set 0,(ix+enemy_data.status)
	
	ld	a,(ix+enemy_data.kind)
	cp	4
	jp nz,3f
	set 0,(ix+enemy_data.status+enemy_data)
	
3:	
    ld  de,enemy_data
    add ix,de
    djnz    1b
	

    ld  ix,enemies
    ld  b,max_enem

npc_loop2:
    ld  a,(ix+enemy_data.status)
    and 1
    jr  z,next
	
	ld	a,(ix+enemy_data.kind)
	cp	0
	jp z,snake
	cp	1
	jp z,eyes
	cp	2
	jp z,wrath
	cp	3
	jp z,skull
	cp	4
	jp z,krokodil1
	cp	6
	jp z,plane1
	cp	7
	jp z,plane2

	
next:
    ld  de,enemy_data
    add ix,de
    djnz    npc_loop2

    ret
plane1
	ld	a,(ix+enemy_data.cntr)
	inc	a
	and	63
	ld	(ix+enemy_data.cntr),a

	add	a,96
	ld	(ix+enemy_data.frame),a
	ld	(ix+enemy_data.color),14
	jp	next
plane2
	ld	a,(ix+enemy_data.cntr)
	inc	a
	and	63
	ld	(ix+enemy_data.cntr),a
	add	a,96
	ld	(ix+enemy_data.frame),a

	ld	(ix+enemy_data.color),1
	jp	next
	
krokodil1:
	ld	a,(ix+enemy_data.cntr)
	inc	a
	and	3
	ld	(ix+enemy_data.cntr),a
	jp	nz,next

	ld	a,(ix+enemy_data.frame)
	inc	a
	and	7
	add	a,88
	ld	(ix+enemy_data.frame),a
	add	a,76-88
	ld	(ix+enemy_data.frame+enemy_data),a
	ld	(ix+enemy_data.color),8
	ld	(ix+enemy_data.color+enemy_data),8
	
		
	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	inc	hl
	ld	(ix+enemy_data.x),l
	ld	(ix+enemy_data.x+1),h
	ld	de,16
	add	hl,de
	ld	(ix+enemy_data.x+enemy_data),l
	ld	(ix+enemy_data.x+1+enemy_data),h
	and a
	sbc	hl,de
	jp	m,next
	
	ld	de,256+32
	and a
	sbc	hl,de
	jp	c,next
	ld	hl,-32
	ld	(ix+enemy_data.x),l
	ld	(ix+enemy_data.x+1),h
	ld	de,16
	add	hl,de
	ld	(ix+enemy_data.x+enemy_data),l
	ld	(ix+enemy_data.x+1+enemy_data),h
	jp	next


	
skull:
    bit 6,(ix+enemy_data.status)
    jr  z,.go_right
.go_left:
	ld	a,(ix+enemy_data.frame)
	inc	a
	and	31
	ld	(ix+enemy_data.frame),a
    dec (ix+enemy_data.x)
    ld  a,128-1
    cp  (ix+enemy_data.x)
    jr  nz,1f
    res 6,(ix+enemy_data.status)
    jr  1f
.go_right:
	ld	a,(ix+enemy_data.frame)
	dec	a
	and	31
	ld	(ix+enemy_data.frame),a
    inc (ix+enemy_data.x)
    ld  a,192+16
    cp  (ix+enemy_data.x)
    jr  nz,1f
    set 6,(ix+enemy_data.status)
1:
	ld	(ix+enemy_data.color),15
	jp	next

eyes:
    bit 6,(ix+enemy_data.status)
    jr  z,.go_right
.go_left:
	ld	a,(ix+enemy_data.frame)
	inc	a
	and	15
	add	a,32
	ld	(ix+enemy_data.frame),a
    dec (ix+enemy_data.x)
    ld  a,16+16
    cp  (ix+enemy_data.x)
    jr  nz,1f
    res 6,(ix+enemy_data.status)
    jr  1f
.go_right:
	ld	a,(ix+enemy_data.frame)
	dec	a
	and	15
	add	a,32
	ld	(ix+enemy_data.frame),a
    inc (ix+enemy_data.x)
    ld  a,256-32-16
    cp  (ix+enemy_data.x)
    jr  nz,1f
    set 6,(ix+enemy_data.status)
1:
	ld	(ix+enemy_data.color),8
	jp	next


; snake:
    ; bit 6,(ix+enemy_data.status)
    ; jr  z,.go_down
; .go_up:
    ; dec (ix+enemy_data.y)
    ; ld  a,64-1
    ; cp  (ix+enemy_data.y)
    ; jr  nz,1f
    ; res 6,(ix+enemy_data.status)
    ; jr  1f
; .go_down:
    ; inc (ix+enemy_data.y)
    ; ld  a,192-16
    ; cp  (ix+enemy_data.y)
    ; jr  nz,1f
    ; set 6,(ix+enemy_data.status)
; 1:
	; ld	a,(ix+enemy_data.frame)
	; inc	a
	; and	7
	; add	a,48
	; ld	(ix+enemy_data.frame),a
	; ld	(ix+enemy_data.color),2
	; jp	next

snake:
	ld	a,(ix+enemy_data.frame)
	inc	a
	and	7
	add	a,48
	ld	(ix+enemy_data.frame),a
	ld	(ix+enemy_data.color),2
	
	ld	a,(ix+enemy_data.cntr)
	inc	a
	and	1
	ld	(ix+enemy_data.cntr),a
	jp	nz,next
		
	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	inc	hl
	ld	(ix+enemy_data.x),l
	ld	(ix+enemy_data.x+1),h
	ld	de,0
	and	a
	sbc	hl,de
	jp	m,next

	ld	a,h
	and	a
	jp	z,next
	
	ld	hl,-16
	ld	(ix+enemy_data.x),l
	ld	(ix+enemy_data.x+1),h
	jp	next

	
wrath
    bit 6,(ix+enemy_data.status)
    jr  z,.go_down
.go_up:
    dec (ix+enemy_data.y)
    ld  a,64-1
    cp  (ix+enemy_data.y)
    jr  nz,1f
    res 6,(ix+enemy_data.status)
    jr  1f
.go_down:
    inc (ix+enemy_data.y)
    ld  a,192-16
    cp  (ix+enemy_data.y)
    jr  nz,1f
    set 6,(ix+enemy_data.status)
1:
	ld	a,(ix+enemy_data.frame)
	inc	a
	and	7
	add	a,68
	ld	(ix+enemy_data.frame),a
	ld	(ix+enemy_data.color),4
	jp	next

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   put enemies if visible in the sat
;
plot_enemy:

    ld  iy,ram_sat
    ld  ix,enemies
    ld  b,max_enem
    ld  c,0             ; main ship and its shadow

npc_loop1:
    ld  a,(ix+enemy_data.status)
    and 1
    jr  z,.next

    ld  l,(ix+enemy_data.x+0)
    ld  h,(ix+enemy_data.x+1)
    ld  de,32
    add hl,de
    ld  de,0
    and a
    sbc hl,de       ; dx = enemy.x + 32 - xmap
    jp  c,.next     ; dx <-32
    ld  de,32
    sbc hl,de
    jp c,.ecset     ; -32<dx<0

    ld  a,h
    and a
    jp  nz,.next    ; dx >255

    res 7,(iy+3)

.cont:
    ld  a,l
    ld  (iy+1),a                ; write X

    ld  a,(ix+enemy_data.y)     ; write Y
    ld  (iy+0),a

    ld  a,(ix+enemy_data.frame)
    ld  (iy+2),a                ; write shape

    ld  a,(iy+3)
    and 0xF0
    or  (ix+enemy_data.color)
    ld  (iy+3),a                ; write colour

    inc c

    ld  de,4
    add iy,de

.next:
    ld  de,enemy_data
    add ix,de
    djnz    npc_loop1

    ld  a,c
    add a,a             ; x4 -> sat data
    add a,a
    ld  (visible_sprts),a
    ret
.ecset:
    add hl,de
    set 7,(iy+3)
    jp  .cont


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   sprite multiplexing
;
_sat_update:
    ld  a,(reverse_sat)
    xor 1
    ld  (reverse_sat),a
    jp  nz,_reverse_sat

_directsat:
    ld  a,(visible_sprts)
    and 0xFC
    ret z
    ld  b,a
    ld  c,0x98
    ld  hl,ram_sat
    _setvdpwvram 0x1b00
1:  outi
    outi
    outi
    outi
    jp  nz,1b
    ld  a,0xD0
    out (0x98),a
    ret

_reverse_sat
    ld  a,(visible_sprts)
    and 0xFC
    ret z
    ld  b,a
    ld  c,0x98
    ld  hl,ram_sat-4+8

    ld  e,b
    ld  d,0
    add hl,de
    ld  de,-8

    _setvdpwvram 0x1b00
1:  add hl,de
    outi
    outi
    outi
    outi
    jp  nz,1b
    ld  a,0xD0
    out (0x98),a
    ret

