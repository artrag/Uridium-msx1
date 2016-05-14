
;****************************************************************************
;*****
;***** Thanks to:
;*****
;***** Aleksi Eeben (http://www.cncd.fi/aeeben)
;***** for his 1K WHACK (c)2003 
;***** Rogue-like Dungeon Exploring Game for Unexpanded VIC 20
;*****
;*****
;****************************************************************************


;----- zeropage variables

addx = 0x00 ; any xy-movement
addy = 0x01

stairupx = 0x02
stairupy = 0x03

stairdownx = 0x04
stairdowny = 0x05

manx = 0x06
many = 0x07

verd = 0x08 ; vertical door check
hord = 0x09 ; horizontal door check

underman = 0x0a

gamevar = 0x0b

HITPOINTS = 0x0b ; game variables


DEF = 0x0c
ATT = 0x0d

mandir = 0x0e

GOLD = 0x11
GOLD100 = 0x12
LEVEL = 0x13
AMULET = 0x14


flip = 0x16
monx = 0x17
mony = 0x18
monster = 0x19

scr = 0x1b ; screen line pointer (2bytes)
color = 0x1d ; color memory pointer (2bytes)


seed1 = 0x1f ; pseudo-random number generator
seed2 = 0x20
prevr = 0x21

endgamevar = 0x21

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

diffparameters = 0x22

_lastlevel = 0x22    ; last dungeon level (bcd)
_dragonlevel = 0x23  ; dungeon level (bcd) where dragons are
;
_heal0 = 0x24 ; healing effect of a potion (bcd)
_heal1 = 0x25 ; healing effect of a potion (bcd)
_heal2 = 0x26 ; healing effect of a potion (bcd)
_heal3 = 0x27 ; healing effect of a potion (bcd)
;
_weap0 = 0x28 ; attack bonus
_weap1 = 0x29 ; attack bonus
_weap2 = 0x2a ; attack bonus
_weap3 = 0x2b ; attack bonus
;
_shld0 = 0x2c ; shield bonus
_shld1 = 0x2d ; shield bonus
_shld2 = 0x2e ; shield bonus
_shld3 = 0x2f ; shield bonus
;
_chests = 0x30 ; number of chests
;
_batgobac = 0x31 ; higher value = harder to kill
_dragonac = 0x32
_ghostac =  0x33
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;----- game constants

MAXGOLD = 0x17 ; max gold in one pile (and-mask)
; LASTLEVEL = 0x30    ; last dungeon level (BCD)
; DRAGONLEVEL = 0x20  ; dungeon level (BCD) where dragons are
;
; HEAL0 = 0x02 ; healing effect of a potion (BCD)
; HEAL1 = 0x03 ; healing effect of a potion (BCD)
; HEAL2 = 0x04 ; healing effect of a potion (BCD)
; HEAL3 = 0x05 ; healing effect of a potion (BCD)
;
; WEAP0 = 0x02 ; attack bonus
; WEAP1 = 0x03 ; attack bonus
; WEAP2 = 0x04 ; attack bonus
; WEAP3 = 0x05 ; attack bonus
;
; SHLD0 = 0x02 ; shield bonus
; SHLD1 = 0x03 ; shield bonus
; SHLD2 = 0x04 ; shield bonus
; SHLD3 = 0x05 ; shield bonus

; CHESTS = 0x04 ; number of chests

; BATGOBAC = 0xc0 ; higher value = harder to kill
; DRAGONAC = 0xf0
; GHOSTAC =  0xf7

CAVERUN = 0x07 ; max. cave run length (and-mask)

DOORS = 0x20 ; number of doors to try
; CAVES = 0x40 ; number of caves = 2x doors
ROOMS = 0x05 ; number of rooms


MAPW = 24 ; number of columns in the level
MAPH = 24 ; number of lines in the level

floorchr    = 32
wallchr     = 3
doorchr     = 36
amuletchr   = 43
upchr       = 34
downchr     = 35
batchr      = 96
goblinchr   = 98
dragonchr   = 106
ghostchr    = 114

chestchr    = 38 ; chest
goldchr     = 40 ; gold

potion0chr   = 39 ; potion
potion1chr   = 45 ; potion
potion2chr   = 46 ; potion
potion3chr   = 39 ; potion

sword0chr   = 41 ; small sword
sword1chr   = 49 ; middle sword
sword2chr   = 48 ; large sword
sword3chr   = 41 ; small sword

shield0chr  = 42 ; small shield
shield1chr  = 50 ; middle shield
shield2chr  = 51 ; large shield
shield3chr  = 42 ; small shield

manchr      = '@' ; man

gravechr    = 72 ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; msx bios
disscr: equ $0041
enascr: equ $0044

wrtvdp: equ $0047
rdvrm:  equ $004a
wrtvrm: equ $004d

setrd:  equ $0050

setwrt: equ $0053
filvrm: equ $0056
ldirmv: equ $0059
ldirvm: equ $005c
chgmod: equ $005F
clrspr: equ $0069
initxt: equ $006c
init32: equ $006f

forclr: equ $f3e9
bakclr: equ $f3ea
bdrclr: equ $f3eb

jiffy:  equ $fc9e

        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; input seed while entering the dungeon
;
onedigit:
1:      call     0x009F        
        cp      '0'          ; <'0'
        jr      c,1b
        cp      '9'+1        ; >'9'
        jr      nc,1b
        add     a,19-'0'
        out     (0x98),a
        sub     a,19
        ret

seedtext:
        db  "XXX"
seedtextend:        
inputhex:
        ld      hl,0x1a6E   ; 0x1800
        call    setwrt
        ld      hl,seedtext
        ld      bc,0x98 + (seedtextend-seedtext)*256
1:      ld      a,(hl)
        add     a,127
        out     (0x98),a
        inc     hl
        djnz    1b
        ld      hl,0x1a6E+(seedtextend-seedtext)-3
        call    setwrt

        call onedigit
        call    ax10
        call    ax10
        ld      l,a
        
        call onedigit        
        call    ax10
        add     a,l
        ld      l,a
                
        call onedigit        
        add     a,l
        ret

ax10:
        add     a,a
        ld      e,a        
        add     a,a
        add     a,a
        add     a,e                                
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   program code
;

startAdr

        module MAIN



;----- entry, initialization

entry:
        ld	hl,MUSIC0			; hl <- initial address of module 
        call	PT3_INIT			; Inits PT3 player

        call   openscreen

        call    init_video

        ld	hl,MUSIC1			; hl <- initial address of module 
        call	PT3_INIT			; Inits PT3 player

        ld ix,PAGE0

        ld hl,levels
        xor a
        ld b,0
_clrlp
        ld (hl),a ; set all levels to non-visited
        inc hl
        djnz _clrlp


        ld b,endgamevar-gamevar
        ld hl,PAGE0+gamevar+1
        xor a
_inilp
        ld (hl),a ; init game variables
        inc hl
        djnz _inilp

        ld (ix+HITPOINTS),0x25
;        ld (ix+DEF),0x00
;        ld (ix+ATT),0x00

; reset the number of rounds

        ld  hl,0
        ld  (nround),hl     
        ld  (nround+1),hl             

        call    initchest   ; all chests of all levels are closed

; initialize level seeds

        ld      a,(storedseed)         ; init random seed from jiffy clock or from custom entry
        ld      (PAGE0+seed1),a

        ld      hl,seeds
        ld      b,MAXLASTLEVEL
1:      call    random
        jr      z,1b
        ld      (hl),a
        inc     hl
        djnz    1b


; generate first level
        
        call _stairdown     


;----- main game loop
;
MAINLOOP:

;- draw man

         call locateman

; l = man x-coordinate
; h = man y-coordinate

         ld a,24       ; posizione del manchr
         call drawchar


;- move monsters
 
         inc (ix+flip) ; chessboard check
         ld a,(ix+flip)
         and 0x01

         ld h,MAPH-1 ; level lines
 
_monylp
         ld l,a
_monxlp
         call locate

         ld (ix+mony),h
         ld (ix+monx),l

         ld (ix+monster),a

         cp dragonchr
         jp z,_mon
         cp goblinchr
         jp z,_mon
         cp ghostchr
         jp z,_mon
         cp batchr
         jp nz,_nomon

         call randomdir ; bats move in random
         jp _movemon ; always branch

_mon

;----- direction table (0 = down; 1 = right; 2 = up; 3 = left, 4 = no move)

         ld a,(ix+seed1)
         and a
         jp m,_monv
_monh
         ld a,l
         cp (ix+manx)
         jp z,_monv
         jp c,_monn3
         ld a,0x03
         jp _monok
         ;
_monn3
         ld a,0x01
         jp _monok
_monv
         ld a,h
         cp (ix+many)
         jp z,_monh
         jp c,_monn2
         ld a,0x02
         jp _monok
          ;
_monn2
         xor a
_monok

         call setdir
 
_movemon
         ld a,floorchr ; wipe monster character
         call drawshaded

         call movedir
         cp manchr
         jp nz,_noattack ; check monster attack (man = char @)
         
         call   random
         cp     (ix+DEF)
         jp     m,_monblocked   ; man resists the attack

         push    af
         ld      a,10                       ; plyr_hit SFX
         ld      c,0                        ;   Priority
         call    ayFX_INIT
         pop     af


         ld a,(ix+HITPOINTS)                ; man hit looses hp
         dec a
         daa
         ld (ix+HITPOINTS),a
         jp nz,_monblocked

	   ; you die

         push    ix
         push    hl
         ld	hl,MUSIC4			       ; hl <- initial address of module 
        call	PT3_INIT			; Inits PT3 player
         pop     hl
         pop     ix

         ld h,(ix+mony)
         ld l,(ix+monx)
         call locate

         ld a,(ix+monster)
         call drawshaded

         ld      b,12

2:       push   bc

         call fastmanview
         
         call   locateman

         ld     hl,visible-hidden             ; move from scr to visible area
         add    hl,de

         pop    bc
         push   bc         
         ld     a,manchr+12                   ; death animation
         sub    b
         ld     (hl),a

         call   render
         
         ld      b,20
1:       halt
         djnz     1b

         pop    bc
         djnz  2b


newgame:
1:
         call _joy
         and    00010000B
         jr     z,2f

         halt
         ld a,8
         call 0x0141 ; getin for newgame
         inc a
         jr z,1b
2:
         jp entry

_noattack
         cp floorchr ; only walk on floor
         jp z,_monmoved

_monblocked ; blocked, restore coordinates
         ld h,(ix+mony)
         ld l,(ix+monx)
         call locate
_monmoved
         ld a,(ix+monster)
         call drawshaded

         ld h,(ix+mony)
         ld l,(ix+monx)
_nomon
         inc l
         inc l
         ld a,MAPW-1
         cp l
         jp nc,_monxlp

         inc l ; next line of chessboard
         ld a,l
         and 0x01

         dec h
         jp nz,_monylp


;- draw man view

         call fastmanview

;----- render screen

        call render

;----- end rendering

;- spawn monsters

         call random                    ; try to create a monster
         jp m,_nospawn                  ; not every frame (50% prob)

         and 0x01                       ; random monster type ( 6 = bat, 7 = goblin )
         or 0x06
         ld l,a

         ld a,(ix+AMULET)               ; dragons if carrying amulet
         and a
         jp nz,_dragons

         ld a,(ix+LEVEL)                ; no dragons if above DRAGONLEVEL
         cp (ix+_dragonlevel)           ; and not carrying amulet
         jp c,_nodragons
         inc l                          ; change bat in goblin and goblin in dragon
         jp  _nodragons
_dragons
         inc l                          ; change bat in dragons and dragons in ghosts
         inc l                          ; ( 8 = dragon, 9 = ghost )
_nodragons
         ld de,objchar
         ld h,0
         add hl,de
         ld a,(hl)
         ex af,af

         call randomxy                    ; find floor
                                          ; de = hidden + y-coord * MAPW + x-coord

         ld hl,visible-hidden             ; move from scr to visible area
         add hl,de
         ld a,(hl)
         and a                            ; only spawn in non-visible squares
         jp nz,_nospawn

         ex af,af
         ld (de),a

_nospawn



;- player actions


;----- keyboard
; 8 RIGHT DOWN UP LEFT DEL INS HOME SPACE
waitkey
         call _joy
         and    00011111B
         cp     00011111B
         ld     a,255
         jr     nz,somekey

         ld a,8
         call 0x0141                ; MC moves
         inc a
         jr z,waitkey               ; remve for real time!!
         dec a

somekey
         ld h,0 ; 0 DOWN
         bit 6,a
         jr z,_keyfound
         bit  1,l
         jr z,_keyfound
         
         inc h ; 1 RIGHT
         bit 7,a
         jr z,_keyfound
         bit  3,l
         jr z,_keyfound
         
         inc h ; 2 UP
         bit 5,a
         jr z,_keyfound
         bit  0,l
         jr z,_keyfound
         
         
         inc h ; 3 LEFT
         bit 4,a
         jr z,_keyfound
         bit  2,l
         jr z,_keyfound
         
         
         inc h ; 4 NO MOVE

;----- direction table (0 = down; 1 = right; 2 = up; 3 = left, 4 = no move)

_keyfound
         ld  (ix+mandir),h
         call setdirx
         call locateman             ; de = hidden + y-coord * MAPW + x-coord
          
         ld a,(ix+underman)
         ld (de),a
         
         call movedir

         push hl

         ld hl,objchar
         ld c,0
_findobj
         cp (hl)
         jp z,_objfound
         inc hl
         inc c
         jp _findobj

_objfound
        ld b,0
        ld hl,actionlist
        add hl,bc
        add hl,bc
        
        ld de,(hl)
        ld iy,de

        pop hl
        call random                 ; many actions use random value
        srl a
        call doact_

;------ update number of rounds

         ld     a,(nround)
         add    a,0x01
         daa
         ld     (nround),a
         ld     a,(nround+1)
         adc    a,0x00
         daa
         ld     (nround+1),a
         ld     a,(nround+2)
         adc    a,0x00
         daa
         ld     (nround+2),a

;----- end loop

        jp MAINLOOP

;----- do action

doact_
        jp iy

;----- write bcd number

writebcd:
         push af
         call _bcdone

         dec hl

         pop af
         rrca
         rrca
         rrca
         rrca
_bcdone
         and 0x0f
         add a,19 ; '0'

         call wrtvrm 
         ret

;----- restore precomputed seeds for new levels

newlevel:
		push	hl
		ld      e,(ix+LEVEL)
		ld	    d,0
        ld      hl,seeds
		add	    hl,de
		ld	    a,(hl)
        inc     hl
        ld      c,(hl)
		pop	    hl
		ret


;----- move to level (a = $99 up, $01 down)

movetolevel:

        add a,(ix+LEVEL)
        daa
        ld (ix+LEVEL),a
        ;
        call    setdot
        ;
;----- generate dungeon level

generatelevel:

        ld  (ix+flip),0             ; tempory meaning : 1 = new level, 0 = visited level

        ld de,levels
        ld h,0
        ld l,a
        add hl,de
        ld a,(hl)
        and a                       ; check if dungeon level visited
        jp nz,_oldlevel

        inc  (ix+flip)              ; tempory meaning : 1 = new level, 0 = visited level
        call    newlevel            ; new precomputed random seeds in a and c

        ld (hl),a                   ; newlevel does not affect hl

        push hl
        ld de,0x80
        add hl,de
        ld (hl),c
        pop hl

_oldlevel
        ld a,(hl)                   ; init pseudo-random generator
        ld (ix+seed1),a

        ld de,0x80
        add hl,de
        ld a,(hl)
        ld (ix+seed2),a

        ld a,(ix+LEVEL)
        ld (ix+prevr),a              ; use level number as previous random

;- fill map area with black wall character


        ld hl,visible
        ld de,hidden
        ld bc,MAPW*(MAPH+2) + 256
        ld a,wallchr
_imaplp:
        ld (hl),0
        ld (de),a
        inc hl
        inc de
        dec c
        jr nz, _imaplp        
        djnz   _imaplp

;
;- dungeon level generator
;- draw caves

        ld hl,MAPW/2+256*MAPH/2             ; y coord => H 
                                            ; x coord => L

; coordinate x,y del punto iniziale nel livello

; lo schermo è MAPW colonne x MAPH righe


       
       ld b,2*DOORS

_nextcave
       push bc
       call randomdir   ; random cave direction

       and CAVERUN      ; random cave run length

       ld   b,a
_cavestep
       push bc
       call movedir     ; draw one step of cave
       ld   a,floorchr
       ld   (de),a
       pop  bc
       djnz _cavestep

       pop  bc
       djnz _nextcave


;- draw rooms

        ld b,ROOMS

_nextroom
        push    bc

        call randomxy

        dec h
        dec h               ; y-=2;
        dec l               ; x--;

        ld b,0x05           ; roomsize
_drawroom
        push    bc

        call locate
        ld a,floorchr

        ld (de),a
        inc de
        ld (de),a
        inc de
        ld (de),a

        inc h               ; y++;

        pop bc
        djnz _drawroom

        pop bc
        djnz _nextroom


;- draw some doors

        ld      b,DOORS
_nextdoor
        push    bc

        xor a
        ld (ix+verd),a
        ld (ix+hord),a

        call randomxy

        dec l                       ; check surrounding blocks
        call hordcheck

        inc l
        inc l
        call hordcheck

        dec l
        dec h
        call verdcheck

        inc h
        inc h
        call verdcheck

        ld a,(ix+verd)              ; if both same then no door
        cp (ix+hord)
        jp z,_nodoor

                                    ; if sum not 2 then no door
        add a,(ix+hord)
        cp 0x02
        jp nz,_nodoor

        dec h                       ; draw door
        call locate
        
        ld a,doorchr
        ld (de),a

_nodoor
        pop     bc
        djnz _nextdoor

                
;- draw staircases and the amulet on last level

        call randomxy               ; staircase down or amulet
        ld (ix+stairdownx),l
        ld (ix+stairdowny),h

        ld a,(ix+LEVEL)             ; amulet on last level

        cp (ix+_lastlevel)
        ld a,downchr
        jp nz,_noamulet

        ld a,(ix+AMULET)            ; but only once
        and a
        jp nz,_nodown

        ld a,amuletchr
_noamulet

        ld (de),a

_nodown
        call randomxy               ; staircase up

        ld (ix+stairupx),l
        ld (ix+stairupy),h

        ld  a,upchr
        ld (de),a

;- draw some chests

        ld b,(ix+_chests)
_nextchest:
        push    bc
        call    randomxy            ; place a chest

        ld      a,chestchr          ; set chest
        ld      (de),a
       
        ld      a,(ix+flip)         ; tempory meaning : 1 = new level, 0 = visited level
        and a                       ; check if dungeon level is visited
                                    ; if NZ this is a new level
        pop     bc
        push    bc                  ; retrive b
        call    nz,storechestinfo   ; store chest position ONLY in non visited levels
1:
        pop     bc
        djnz    _nextchest

        ld      a,(ix+flip)         ; tempory meaning : 1 = new level, 0 = visited level
        and a                       ; check if dungeon level is visited
        call   z,removeopenchests   ; remove open chests only in visited levels

        ;- dungeon level done
        
        ret

        ;- doorway check

hordcheck:
        ld bc,(ix+scr)
        push hl
        ld h,0
        add hl,bc
        ld a,(hl)
        pop hl
        
        cp doorchr
        jp z,_baddoor
        cp floorchr
        ret nz
        inc (ix+hord)
        ret

verdcheck:
        call locate

        cp doorchr
        jp z,_baddoor
        cp floorchr
        ret nz
        inc (ix+verd)
        ret

_baddoor:
        ld (ix+verd),a          ; no multiple doors
        ret
        

;----- top line

hp:     db 'H'+127,'P'+127,255    ,253    ,47
gold:   db      40,253    ,'O'+127,'O'+127
att:    db 'A'+127,'T'+127,'T'+127,253    ,41     ,246
def:    db 'D'+127,'E'+127,'F'+127,253    ,42     ,246       
lv:     db 'F'+127,'L'+127,'O'+127,'O'+127,'R'+127,254
amulet: db 'A'+127,'M'+127,253

;----- direction table (0 = down; 1 = right; 2 = up; 3 = left, 4 = no move)

dirx:
        db 0 ; (,$01,$00,$ff)
diry:
        db 1,0,-1,0, 0


;----- random direction

randomdir:
        call random
        and 0x03
        
;----- set direction of (any) movement (a = direction 0-3,4)

setdir:
        ld c,h
        ld h,a
setdirx:

        push hl ; preserva hl
        
        ld d,0
        ld e,h

        ld hl,dirx
        add hl,de
        ld a,(hl)
        ld (ix+addx),a
        inc hl
        ld a,(hl)
        ld (ix+addy),a
        
        pop hl
        ld h,c
        ;
        ;
;----- generate pseudo-random number, always clear carry (for add)

random:
        inc (ix+seed2)
        ld a,(ix+seed2)
        add a,(ix+seed1)
        adc a,(ix+seed2)
        ld (ix+seed1),a
        push af
        xor (ix+seed2)
        ld (ix+seed2),a
        pop af
        ld a,(ix+seed2)
        scf
        sbc (ix+prevr)
        ld (ix+prevr),a
        and a
        ret



;----- step y,x in current direction within screen boundaries

movedir:
        ld a,h ; y-movement
        add a,(ix+addy)
        ld h,a

        dec a ; y-boundary 0x01
        jp nz,_noty01
        inc h
_noty01
        ld a,h
        cp MAPH ; y-boundary MAPH
        jp nz,_noty18
        dec h
_noty18

        ld a,l ; x-movement
        add a,(ix+addx)
        ld l,a

        jp nz,_notx00 ; x-boundary 0x00
        inc l
_notx00
        ld a,l
        cp MAPW-1 ; x-boundary MAPW-1
        jp nz,_notx13
        dec l
_notx13
        jp locate ; always branch



;----- some math helper functions 
; 
RandomVal:                  ; return a random value in 0-(E-1)
	push	de
	call	random
    pop     de
    ld      d,a
    xor     a
    ;
    ;

;Input: D = Dividend, E = Divisor, A = 0
;Output: D = Quotient, A = Remainder

div8:
    rept    8
	sla	d		; unroll 8 times
	rla			; ...
	cp	e		; ...
	jr	c,$+4		; ...
	sub	e		; ...
	inc	d		; ...
    endm
    ret

;----- random coordinates, find floor

;_randomxy:
;
;        call random ; x-coordinate, $02-(MAPW-3)
;        and 15
;        add a,0x02
;        ld l,a
;
;        call random ; y-coordinate, $05-(MAPH-4)
;        and 15
;        add 0x05
;        ld h,a
;
;        call locate
;        cp floorchr
;        jp nz,randomxy
;
;        ret

randomxy:

        ld  e,MAPW-4
        call    RandomVal
        add a,0x02  ; x-coordinate, $02-(MAPW-3)
        ld l,a

        ld  e,MAPH-6
        call    RandomVal      
        add a,0x04
        ld  h,a     ; y-coordinate, $05-(MAPH-4)

        call locate
        cp floorchr
        jp nz,randomxy

        ret


;----- locate man

locateman:
        ld l,(ix+manx)
        ld h,(ix+many)
        ;
;----- locate screen line

; l = x-coordinate
; h = y-coordinate


locate
        ex de,hl

        push    de

        ld      h,d
        ld      e,MAPW

        call    mul8
        pop     de

        ld bc,hidden
        add hl,bc

        ld (ix+scr),hl          ; scr = hidden + y-coord * MAPW

        push hl
        ld bc,visible-hidden
        add hl,bc
        ld (ix+color),hl        ; color = visible + y-coord * MAPW
        pop hl

        ld b,0
        ld c,e
        add hl,bc

        ld a,(hl)

        ex de,hl                ; de = hidden + y-coord * MAPW + x-coord
        ret

;Input: H = Multiplier, E = Multiplicand, L = 0, D = 0
;Output: HL = Product
;Note: BC is unaffected

mul8:
        ld      l,0
        ld      d,l

        sla	h		; optimised 1st iteration
        jr	nc,$+3
        ld	l,e
        rept 7
            add	hl,hl		; unroll 7 times
            jr	nc,$+3		; ...
            add	hl,de		; ...
        endm
        ret


;----- actions (2 byte jumptable)
;
stairup:
         ld      a,3                     ; stairup SFX
         ld      c,0                    ;   Priority
         call    ayFX_INIT

         call    walk
         ld a,24       ; posizione del manchr
         call drawchar
         call fastmanview  
         inc (ix+flip)                          
         call render

         ld a,0x99          ; climb up a level
         call movetolevel
         ld a,(ix+LEVEL)
         and a
         jp z,checkamulet   ; player leaving dungeon

         ld l,(ix+stairdownx)
         ld h,(ix+stairdowny)
         jp walk

checkamulet:
         ld a,(ix+AMULET)               ; throw back to dungeon if no amulet
         and a
         jp z,badend                ; (without showing level 0)

         ld a,(ix+GOLD100)              ; award 1000 gold
         add a,0x10
         daa
         ld (ix+GOLD100),a

         call   sidebar

         call   endsequence             ; SUCCESS!!!!!!

         ld     hl,MUSIC6			; hl <- initial address of module 
        call	PT3_INIT			; Inits PT3 player

         call    disscr
         halt
         call   cls
         call _nosprt
         
         call SETGAMEPAGE0
         call intro_START
         call RESTOREBIOS

        call    CheckIf60Hz
        dec a
        ld (vsf),a                ; 0=>60Hz, !0=>50Hz

        ld      hl,cnt
        ld      (hl),1               ; reset the tic counter
		
		
        ld      a,-3
        ld      (_psg_vol_fix),a
		call SCCINIT
		call 	_SCC_PSG_Volume_balance

        call    ayFX_SETUP

        xor a
        ld     [PT3_SETUP],a       ; LOOP the song

		ld	hl,MUSIC6			; hl <- initial address of module 
		call	PT3_INIT			; Inits PT3 player

         ei
         
         ld     b,5
1:       halt
         djnz   1b

         jp entry
badend:
         call badendscript

         jp _stairdown

stairdown:
         ld      a,2                     ; stairdown SFX
         ld      c,0                     ;   Priority
         call    ayFX_INIT

         call    walk
         ld a,24       ; posizione del manchr
         call drawchar
         call fastmanview                  
         inc (ix+flip)          
         call render
_stairdown:                             ; only to generate first level
         ld a,0x01                      ; climb down a level
         call movetolevel
         ld l,(ix+stairupx)
         ld h,(ix+stairupy)
walk:
         ld (ix+manx),l                 ; new coordinates to man
         ld (ix+many),h
blocked:
         ret                            ; do nothing if way blocked

hitchest:                               ; in h,l the coords of the chest
         push   hl
         xor     a                       ; openchest SFX
         ld      c,0                     ;   Priority
         call    ayFX_INIT
         call    openchest
         pop    hl

         call random

         ld  c,a
         and 0x03                       ; 0=gold,1=potion, 2=weapon, 3=shield
         jp  z,hitmonst                 ; release gold
         cp  1
         jp  z,healing
         cp  2
         jp  z,weapon

shield:  ld a,c
         rrca
         rrca
         and 0x03
         add a,20
         jp drawchar

weapon:  ld a,c
         rrca
         rrca
         and 0x03
         add a,16
         jp drawchar

healing: ld a,c
         rrca
         rrca
         and 0x03
         add a,12
         jp drawchar

;-----------
_set99:
         ld     a,0x99
         ret
;-----------

pickweapon0
         ld c,(ix+_weap0)
         jr 1f
pickweapon1
         ld c,(ix+_weap1)
         jr 1f
pickweapon2
         ld c,(ix+_weap2)
         jr 1f
pickweapon3
         ld c,(ix+_weap3)
1:
         ld a,(ix+ATT)                  ; take a new weapon
         add a,c
         daa
         call c,_set99                  ; no more if more than 99
         ld (ix+ATT),a

         push    af
         ld      a,5                     ; powerup SFX
         ld      c,0                    ;   Priority
         call    ayFX_INIT
         pop     af

         jp _pickany ; always branch

pickshield0
         ld        c,(ix+_shld0)
         jr 1f
pickshield1
         ld        c,(ix+_shld1)
         jr 1f
pickshield2
         ld        c,(ix+_shld2)
         jr 1f
pickshield3
         ld        c,(ix+_shld3)
1:
         ld a,(ix+DEF)                  ; take a new shield
         add a,c
         daa
         call c,_set99                  ; no more if more than 99
         ld (ix+DEF),a

         push    af
         ld      a,5                     ; powerup SFX
         ld      c,0                    ;   Priority
         call    ayFX_INIT
         pop     af

         jp _pickany ; always branch

getamulet:
        push    ix
        push    hl
        call    foundamulet
        call    setdot
        
		ld	hl,MUSIC3			; hl <- initial address of module 
		call	PT3_INIT			; Inits PT3 player
        pop    hl
        pop     ix

         inc (ix+AMULET)                ; picked up the amulet
         ld         c,(ix+_heal3)         
        jr  1f                          ; no sfx
         
         ;
pickpotion0:
         ld      a,6                     ; potionsm SFX
         ld      c,0                     ;   Priority
         call    ayFX_INIT

         ld         c,(ix+_heal0)
         jr 1f
pickpotion1:
         ld      a,6                     ; potionsm SFX
         ld      c,0                     ;   Priority
         call    ayFX_INIT

         ld         c,(ix+_heal1)
         jr 1f
pickpotion2:
         ld      a,7                     ; potionbg SFX
         ld      c,0                     ;   Priority
         call    ayFX_INIT

         ld         c,(ix+_heal2)
         jr 1f
pickpotion3:
         ld      a,7                     ; potionbg SFX
         ld      c,0                     ;   Priority
         call    ayFX_INIT

         ld         c,(ix+_heal3)

1:
         ld a,(ix+HITPOINTS)            ; drink potion
         add a,c
         daa
         call c,_set99                  ; no more if more than 99
         ld (ix+HITPOINTS),a

         jp _pickany ; always branch

pickgold:
         and    MAXGOLD                    ; max gold $17, $07 or $03
         or     0x01 ; at least 1 gold
         add    a,(ix+GOLD)
         daa
         ld     (ix+GOLD),a
         ld     a,(ix+GOLD100)
         adc    a,0x00
         daa
         ld     (ix+GOLD100),a

         push    hl
         ld      a,1                     ; coins SFX
         ld      c,0                     ;   Priority
         call    ayFX_INIT
         pop hl

_pickany

         call walk

         xor a              ; clear tile
         jp drawchar        ; rts there

opendoor:
         ld      a,4                     ; opendoor SFX
         ld      c,0                    ;   Priority
         call    ayFX_INIT

         xor a              ; open door
         jp drawchar        ; rts there

hitghost:
         and    0x7f
         add    a,(ix+ATT)  ; add attack bonus
         jr     c,hitmonst  ; if >255 always hit
         cp (ix+_ghostac)   ; test man's attack against Dragon's AC
         ret m              ; attack failed ?

         push    af
         ld      a,8                     ; enehit1 SFX
         ld      c,0                    ;   Priority
         call    ayFX_INIT
         pop     af

         jr hitmonst

hitdragon:
         and    0x7f
         add    a,(ix+ATT)  ; add attack bonus
         jr     c,hitmonst  ; if >255 always hit
         cp (ix+_dragonac)  ; test man's attack against Dragon's AC
         ret m              ; attack failed ?

         push    af
         ld      a,8                     ; enehit1 SFX
         ld      c,0                    ;   Priority
         call    ayFX_INIT
         pop     af

         jr hitmonst
         ;
hitbatgob:
         and    0x7f
         add    a,(ix+ATT)  ; add attack bonus
         jr     c,hitmonst  ; if >255 always hit
         cp (ix+_batgobac)  ; test man's attack against bat & goblin AC
         ret m              ; attack failed

         push    af
         ld      a,9                     ; enehit2 SFX
         ld      c,0                    ;   Priority
         call    ayFX_INIT
         pop     af

hitmonst:
         and 0x01           ; gold or small potion
         add a,11

         ;
         ;

; ----- draw char a at y,x
 
drawchar:
         push af
         call locate
         ld (ix+underman),a
         pop af

         push hl
         ld hl,objchar
         ld d,0
         ld e,a
         add hl,de
         ld a,(hl)
         pop hl
         ;
         ;
; ----- draw character and colorize if in visible (visited) area

drawshaded:
         push hl
         ld d,0
         ld e,l
         ld hl,(ix+scr)
         add hl,de
         ld (hl),a
         ld hl,(ix+color)
         add hl,de
         ex de,hl
         pop hl

         ld c,a
         ld a,(de)
         and a
         ret z ; plot only if in visible area

         ld a,c
         ld (de),a
         ret
;
;----- action jump table

actionlist:
         dw walk        ; floor
         dw blocked     ; wall
         dw getamulet   ; get amulet
         dw opendoor    ; door
         dw stairdown   ; staircase down
         dw stairup     ; staircase up
         dw hitbatgob   ; hit monster (bat)
         dw hitbatgob   ; hit monster (goblin)
         dw hitdragon   ; hit monster (dragon)
         dw hitghost    ; hit monster (ghost)
         dw hitchest    ; hit chest (no AC)
         dw pickgold    ; pick gold

         dw pickpotion0 ; pick potion
         dw pickpotion1 ; pick potion
         dw pickpotion2 ; pick potion
         dw pickpotion3 ; pick potion

         dw pickweapon0
         dw pickweapon1
         dw pickweapon2
         dw pickweapon3

         dw pickshield0
         dw pickshield1
         dw pickshield2
         dw pickshield3
         dw 0        ; placeholder



;----- objects

objchar:
        db floorchr   ; 0 floor
        db wallchr    ; 1 wall
        db amuletchr  ; 2 amulet
        db doorchr    ; 3 door
        db downchr    ; 4 staircase down
        db upchr      ; 5 staircase up
        db batchr     ; 6 bat
        db goblinchr  ; 7 goblin
        db dragonchr  ; 8 dragon
        db ghostchr   ; 9 ghost
        db chestchr   ; 10 chest
        db goldchr    ; 11 gold

        db potion0chr ; 12 potion
        db potion1chr ; 13 potion
        db potion2chr ; 14 potion
        db potion3chr ; 15 potion

        db sword0chr  ; 16 small sword
        db sword1chr  ; 17 small sword
        db sword2chr  ; 18 small sword
        db sword3chr  ; 19 small sword

        db shield0chr ; 20 small shield
        db shield1chr ; 21 small shield
        db shield2chr ; 22 small shield
        db shield3chr ; 23 small shield

        db manchr     ; 24 man
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



_3dview:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   render 3d maze
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ld ix,hidden + MAPW
        ld iy,visible + MAPW
        ld de,buffer

        ld bc,MAPH*MAPW

1:
        ld a,(iy+0)
        cp floorchr
        jp z,_rule5
        cp wallchr
        jp z,_rule1234
        cp doorchr
        jp z,_doorrule


exit
        ld (de),a
        inc ix
        inc iy
        inc de
        dec bc
        ld a,b
        or c
        jp nz,1b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ld ix,PAGE0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   2 frame animations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

         ld  de,buffer
         ld  b,MAPH
2:       ld  c,MAPW
1:
         ld  a,(de)
         cp  manchr
         jr  z,dispman

         cp dragonchr
         jp z,dispmon

         cp goblinchr
         jp z,dispmon

         cp ghostchr
         jp z,dispmon

         cp batchr
         jp nz,noanim

3:
         ld  h,a
         ld  a,(ix+flip)
         and 1
         or  h
         ld (de),a
noanim

         inc de
         dec c
         jp nz,1b
         djnz  2b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   man animations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dispman:

        ld  a,tabaniman & 255
        add a,(ix+mandir)
        ld  l,a
        ld  a,tabaniman / 256
        adc a,0
        ld  h,a
        ld  a,(hl)
        jr  3b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tabaniman
        db 68,64,68,66,64

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   monster animations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dispmon:
        ld	a,MAPW
        sub a,c
        cp (ix+manx)

        jr  z,tesv

        ld a,2                          ; set right/left
        jr  c,999f
        xor a

999:    ex  de,hl
        add a,(hl)
        ex  de,hl
        jr  3b

tesv    ld	a,MAPH
        sub a,b
        cp (ix+many)
        ld  a,4                         ; set up/down
        jr  c,999b
        ld  a,6
        jr  999b
        
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_doorrule
        ld  a,(ix-MAPW)
        cp  wallchr
        ld  a,doorchr
        jp  nz,exit
        ld  a,(ix+MAPW)
        cp  wallchr
        ld  a,doorchr        
        jp  nz,exit
        ld  hl,-MAPW
        add hl,de
        ld  (hl),wallchr
        ld  a,doorchr+1
        jp  exit


_rule5
        ld  a,(ix+-1)
        cp  wallchr
        ld  a,(iy+0)
        jp  nz,exit
        ld  a,33        ; shadowed floor
        jp  exit

_rule1234
        ld  a,(ix+MAPW)
        cp  wallchr
        jp  z,_rule34
        
_rule12
        ld  a,(ix-MAPW)
        cp  wallchr
        jp  z,_rule2

_rule1
        ld  a,2
        jp  exit

_rule2  ld   a,(ix-2*MAPW)
        cp  wallchr
        jr  nz,1f
        ld hl,-MAPW
        add hl,de
        ld (hl),wallchr
        ld a,1
        jp exit

1:      ld hl,-MAPW
        add hl,de
        ld (hl),5
        ld a,1
        jp exit
       
_rule34
        ld a,(ix-MAPW)
        cp wallchr
        jp z,_rule4

        ld a,5          ; rule3
        jp exit

_rule4
        ld a,wallchr
        jp exit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

startgametext:
; show text. start at pos 5,6
;DESCEND THE ANCIENT
      db 68+127, 69+127, 83+127, 67+127, 69+127, 78+127, 68+127, 255,    84+127, 72+127, 69+127, 255,    65+127, 78+127, 67+127, 73+127, 69+127, 78+127, 84+127, 255,255,255,255
;STAIRWAYS OF THE DEEP
      db 83+127, 84+127, 65+127, 73+127, 82+127, 87+127, 65+127, 89+127, 83+127, 255, 79+127, 70+127, 255,    84+127, 72+127, 69+127, 255,    68+127, 69+127, 69+127, 80+127,255,255
;DUNGEON!
      db 68+127, 85+127, 78+127, 71+127, 69+127, 79+127, 78+127,  248

    rept 23+15
    db 255
    endm

;RETRIEVE THE AMULET TO
      db 82+127, 69+127, 84+127, 82+127, 73+127, 69+127, 86+127, 69+127, 255, 84+127, 72+127, 69+127, 255, 65+127, 77+127, 85+127, 76+127, 69+127, 84+127, 255, 84+127, 79+127,255
;LIFT THE WIZARD'S SPELL
      db 76+127, 73+127, 70+127, 84+127, 255, 84+127, 72+127, 69+127, 255, 87+127, 73+127, 90+127, 65+127, 82+127, 68+127, 251,'S'+127, 255, 'S'+127, 'P'+127, 'E'+127, 'L'+127, 'L'+127
;AND CLAIM YOUR RIGHTFUL
      db 65+127, 78+127, 68+127, 255, 67+127, 76+127, 65+127, 73+127, 77+127, 255, 89+127, 79+127, 85+127, 82+127, 255, 82+127, 73+127, 71+127, 72+127, 84+127, 70+127, 85+127, 76+127
;PLACE ON THE THRONE!
      db 80+127, 76+127, 65+127, 67+127, 69+127, 255, 79+127, 78+127, 255, 84+127, 72+127, 69+127, 255, 84+127, 72+127, 82+127, 79+127, 78+127, 69+127, 248,255,255,255

f4message:
      db  'P'+127,'R'+127,'E'+127,'S'+127,'S'+127,255,'F'+127,23,255,'T'+127,'O'+127,255,'I'+127,'N'+127,'P'+127,'U'+127,'T'+127,255,'A'+127,255,'C'+127,'U'+127,'S'+127,'T'+127,'O'+127,'M'+127,255,'S'+127,'E'+127,'E'+127,'D'+127

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_video:

		ld	hl,MUSIC6			; hl <- initial address of module 
		call	PT3_INIT			; Inits PT3 player

        call disscr

        call _nosprt

        call cls

        ld hl,ddpatterns
        ld de,0x0000
        call    out2k
        ld hl,ddcolors
        ld de,0x2000
        call    out2k

        ld hl,ddpatterns
        ld de,0x0000+256*8
        call    out2k
        ld hl,ddcolors
        ld de,0x2000+256*8
        call    out2k

        call    enascr

        call    setdiff

        ld      de,startgametext
        ld      hl,0x1800+5*32+5
        ld      b,8
        ld      a,23
        call    _printtext


	    ld	b,30
1:      halt
        djnz    1b

        ld      b,230
1:      halt
        call _joy
        and    00010000B
        jr     z,1f


        ld      a,8
        call    0x0141 ; getin startgame
        inc     a
        jr      nz,1f
        djnz    1b
1:

drawlogo:

; - clean message

         call cls

; - logo in the sidebar

         ld hl,0x1820+24
         call setwrt
         ld hl,logo
         ld bc,8*256+0x98
         call slowotir
         ld hl,0x1840+24
         call setwrt
         ld hl,logo+8
         ld bc,8*256+0x98
         call slowotir
         ld hl,0x1860+24
         call setwrt
         ld hl,logo+16
         ld bc,8*256+0x98
         call slowotir
         
; - deepth indicator         
         ld de,32
         
         ld     hl,0x1980+28+32
         call setwrt
         ld     a,34
         out    (0x98),a
         add    hl,de
         call setwrt
         ld     a,76
         out    (0x98),a
         
         ld     b,3
1:       add    hl,de
         call setwrt
         ld     a,77
         out    (0x98),a
         djnz   1b

         add    hl,de
         call setwrt
         ld     a,78
         out    (0x98),a

         add    hl,de
         call setwrt
         ld     a,43
         out    (0x98),a

         ret

; - clean screen
cls:
        ld hl,0x1800
        call setwrt
        xor a
        ld  b,a
        rept    3
1:      out (0x98),a
        nop
        and a
        djnz    1b
        endm
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   in:
;       de = vram addreess
;       hl = compressed data
;
out2k:
        push    de
        ld de,buffer
        call miz._unpack
        pop     hl

        call setwrt
_out2k: 
        ld hl,buffer
        ld bc,0x98
_out2k2:rept 8
            otir
        endm
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   endsequence
;
        include ending.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spritemask1:
        db 160-1,56,2*4,1,152-8-1,104-8,0*4,1,160-1,88,1*4,1,0xD0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

openscreen:

;        ld a,2
;        call 05Fh       ; screen 2

introloop:
        ld bc,0xE201
        call wrtvdp

        call disscr
        
; load sprites

        ld  hl,titlesprites
        ld  de,buffer
        call    pletter._unpack
        
        halt
        ld hl,0x3800
        call setwrt
        ld  bc,(0+0x98) & 0xFFFF
        ld  hl,buffer
        ld  a,4
1:      otir
        dec a
        jr  nz,1b
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite patch for the indicator

        ld hl,0x3B60
        call setwrt
        ld  a,0x08
        out (0x98),a        
        ld  a,0x14
        out (0x98),a        
        xor a
        out (0x98),a        
        ld  a,0x14
        out (0x98),a        
        ld  a,0x08
        out (0x98),a        

;;;;;;;;;;;;;;;;;;;;;;;;;;;



;#92 -> 118,90
        ld hl,0x1B00
        call setwrt
        ld  a,90-1
        out (0x98),a
        ld  a,118
        out (0x98),a
        ld  a,92
        out (0x98),a
        ld  a,15
        out (0x98),a
;#96 -> 134,92
        ld  a,92-1
        out (0x98),a
        ld  a,134
        out (0x98),a
        ld  a,96
        out (0x98),a
        ld  a,15
        out (0x98),a
;#100 -> 150,91
        ld  a,91-1
        out (0x98),a
        ld  a,150
        out (0x98),a
        ld  a,100
        out (0x98),a
        ld  a,15
        out (0x98),a
;#104 ->166,89
        ld  a,89-1
        out (0x98),a
        ld  a,166
        out (0x98),a
        ld  a,104
        out (0x98),a
        ld  a,15
        out (0x98),a


; CLS

        ld hl,0x1800
        call setwrt
        ld  a,0
1:      out (0x98),a
        inc a
        jr nz,1b
1:      out (0x98),a
        inc a
        jr nz,1b


        ld hl,0x1800 + 32*16
        call setwrt
        ld  b,0
        xor a
1:      out (0x98),a
        djnz    1b

; load tiles
		
        ld hl,ddpat1
        ld de,0x0000
        call    out2k
		call _out2k2

        ld hl,ddcol1
        ld de,0x2000
        call    out2k
		call _out2k2
		
		
        ; ld	hl,MUSIC0-100			; hl <- initial address of module - 100
        ; call	PT3_INIT			; Inits PT3 player
		
        ; ld hl,ddpat2
        ; ld de,0x0000+256*8
        ; call    out2k

        ; ld hl,ddcol2
        ; ld de,0x2000+256*8
        ; call    out2k

        ld hl,ddpatterns
        ld de,0x0000+256*8*2
        call    out2k

        ld hl,ddcolors
        ld de,0x2000+256*8*2
        call    out2k

; Print message
        halt
        ld hl,0x1800 + 32*18 + 6
        call setwrt
        ld hl,startgamemessage
        ld b,20
        otir


        call enascr

        ; wait  seq == 4

1:      halt
        call keytest

        call    seq
        ld  a,3
        cp  l
        jr  nc,1b

        ; seq == 4

; Start INTRO SCRIPT

        call disscr

        call cls

; load patterns

        ld hl,ddpatterns
        ld de,0x0000
        call    out2k
        ld hl,ddcolors
        ld de,0x2000
        call    out2k

        ld hl,ddpatterns
        ld de,0x0000+256*8
        call    out2k
        ld hl,ddcolors
        ld de,0x2000+256*8
        call    out2k

; show sprite 0 at 56,160, sprite 1 at 104,152, sprite 2 at 88,160

        ld hl,0x1b00
        call setwrt
        halt
        ld   hl,spritemask1
        ld   bc,(3*4+1)*256+0x98
        otir




; show amulet in lower section on screen start pos 7,17 (x,y) width 18 tiles and height 4
        halt
        ld      hl,0x1800+17*32+7
        ld      bc,4*256+0x98
        ld      de,amulettiles
1:
        push    bc

        call setwrt

        ld      bc,32
        add     hl,bc
        push    hl

        ex      de,hl
        ld      bc,19*256+0x98
        call slowotir
        ex      de,hl

        pop     hl
        pop     bc
        djnz    1b

; show text. start at pos 5,3

        ld      de,introtext1
        ld      hl,0x1800+3*32+5
        ld      a,22
        ld      b,6
        call    _printtext

        call enascr

        ; wait  seq == 5
        
1:      halt
        call keytest

        call    seq
        ld  a,5
        cp  l
        jr  nc,1b

        ld      de,introtext2
        ld      hl,0x1800+3*32+5
        ld      a,22
        ld      b,7
        call    _printtext

        ; wait  seq == 7


1:      halt
        call keytest
        call    seq
        ld  a,7
        cp  l
        jr  nc,1b


        ld hl,0x1800 
        call setwrt
        ld  b,0
        xor a
1:      out (0x98),a
        nop
        and a
        djnz    1b
1:      out (0x98),a
        nop
        and a
        djnz    1b
1:      out (0x98),a
        nop
        and a
        djnz    1b
1:      out (0x98),a
        nop
        and a
        djnz    1b

        ld      de,introtext3
        ld      hl,0x1800+2*32+4
        ld      a,26
        ld      b,9
        call    _printtext


       ; wait  seq == 9
        
1:      halt
        call keytest

        call    seq
        ld  a,9
        cp  l
        jr  nc,1b

        ld      de,introtext4
        ld      hl,0x1800+2*32+4
        ld      a,26
        ld      b,10
        call    _printtext

       ; wait  seq == 11
        
1:      halt
        call keytest

        call    seq
        ld  a,11
        cp  l
        jr  nc,1b

        ld      de,introtext5
        ld      hl,0x1800+2*32+4
        ld      a,26
        ld      b,10
        call    _printtext

       ; wait  seq == 13
        
1:      halt
        call keytest

        call    seq
        ld  a,13
        cp  l
        jr  nc,1b

        ld      de,introtext6
        ld      hl,0x1800+2*32+4
        ld      a,26
        ld      b,11
        call    _printtext


        ; wait  seq == 0x0B

1:      halt
        call keytest
        call    seq
        xor a
        cp  l
        jr  nz,1b           ; wait for loop

        jp introloop




amulettiles
      db 255,255, 52, 53, 54, 55, 56, 92, 93,255,255,255,255,255,255,255,255,255,255
      db  57, 58, 59, 60, 61, 62, 63, 94, 95,154,155,156,157,158,158,159,159,186,187
      db  79, 80, 81, 82, 83, 84, 85,255, 255,188,189,190,191,220,220,220,221,222,223
      db  86, 87, 88, 89, 90, 91, 255,255,255,255,255,255,255,255,255,255,255,255,255

introtext1:
; show text. start at pos 5,3
;DOWN THE DEEP DUNGEON,
      db 68+127, 79+127, 87+127, 78+127, 255,    84+127, 72+127, 69+127, 255,    68+127, 69+127, 69+127, 80+127, 255,    68+127, 85+127, 78+127, 71+127, 69+127, 79+127, 78+127, 247
;GUARDED BY DREADFUL
      db 71+127, 85+127, 65+127, 82+127, 68+127, 69+127, 68+127, 255, 66+127, 89+127, 255,    68+127, 82+127, 69+127, 65+127, 68+127, 70+127, 85+127, 76+127, 255,255,255
;CREATURES, AWAITS AN
      db 67+127, 82+127, 69+127, 65+127, 84+127, 85+127, 82+127, 69+127, 83+127, 247,    255,    65+127, 87+127, 65+127, 73+127, 84+127, 83+127, 255, 65+127, 78+127,255,255
;AMULET ONCE STOLEN
      db 65+127, 77+127, 85+127, 76+127, 69+127, 84+127, 255,    79+127, 78+127, 67+127, 69+127, 255,    83+127, 84+127, 79+127, 76+127, 69+127, 78+127, 255,255,255,255
;FROM YOUR FAMILY BY
      db 70+127, 82+127, 79+127, 77+127, 255,    89+127, 79+127, 85+127, 82+127, 255,    70+127, 65+127, 77+127, 73+127, 76+127, 89+127, 255, 66+127, 89+127,255,255,255
;AN EVIL WIZARD.
      db 65+127, 78+127, 255,    69+127, 86+127, 73+127, 76+127, 255,    87+127, 73+127, 90+127, 65+127, 82+127, 'D'+127,255, 255,255,255,255,255,255,255


introtext2:
;IT BEARS THE ROYAL
      db 73+127, 84+127, 255,    66+127, 69+127, 65+127, 82+127, 83+127, 255,    84+127, 72+127, 69+127, 255,    82+127, 79+127, 89+127, 65+127,76+127,255,255,255,255
;CREST PROVING YOUR
      db 67+127, 82+127, 69+127, 83+127, 84+127, 255,    80+127, 82+127, 79+127, 86+127, 73+127, 78+127, 71+127, 255,    89+127, 79+127, 85+127,82+127,255,255,255,255
;HERIDITARY RIGHT TO
      db 72+127, 69+127, 82+127, 73+127, 68+127, 73+127, 84+127, 65+127, 82+127, 89+127, 255,    82+127, 73+127, 71+127, 72+127, 84+127, 255,84+127, 79+127,255,255,255
;THE COUNTRY'S THRONE.
      db 84+127, 72+127, 69+127, 255,    67+127, 79+127, 85+127, 78+127, 84+127, 82+127, 89+127,251, 83+127, 255,    84+127, 72+127, 82+127, 79+127, 78+127, 69+127, 255,255

      rept 22
      db 255
      endm

;WOULD YOU DARE TO
      db 87+127, 79+127, 85+127, 76+127, 68+127, 255,    89+127, 79+127, 85+127, 255,    68+127, 65+127, 82+127, 69+127, 255,    84+127, 79+127, 255 , 255, 255, 255, 255
;ENTER...?
      db 69+127, 78+127, 84+127, 69+127, 82+127, 248,    248,    248,    250
      rept 14
      db 255
      endm

introtext3:
; start at 2,3
;     - HOW TO PLAY -
      db 255,255,255,255,255,254,255,'H'+127,'O'+127,'W'+127,255,'T'+127,'O'+127,255,'P'+127,'L'+127,'A'+127,'Y'+127,255,254
      rept 6+26
      db 255
      endm
;DESCEND DONW INTO THE 
      db 'D'+127,'E'+127,'S'+127,'C'+127,'E'+127,'N'+127,'D'+127,255,'D'+127,'O'+127,'W'+127,'N'+127,255,'I'+127,'N'+127,'T'+127,'O'+127,255,'T'+127,'H'+127,'E'+127
      rept 5
      db 255
      endm
;DEPTHS OF THE DUNGEON TO
      db 'D'+127,'E'+127,'P'+127,'T'+127,'H'+127,'S'+127,255,'O'+127,'F'+127,255,'T'+127,'H'+127,'E'+127,255,'D'+127,'U'+127,'N'+127,'G'+127,'E'+127,'O'+127,'N'+127,255,'T'+127,'O'+127
      rept 2
      db 255
      endm
;FIND THE AMULET %.
      db 'F'+127, 'I'+127, 'N'+127, 'D'+127, 255, 'T'+127, 'H'+127, 'E'+127, 255, 'A'+127, 'M'+127, 'U'+127, 'L'+127, 'E'+127, 'T'+127, 255, 43,248
      rept 8+26
      db 255
      endm
;NAVIGATE YOUR WAY THROUGH
      db 'N'+127, 'A'+127, 'V'+127, 'I'+127, 'G'+127, 'A'+127, 'T'+127, 'E'+127, 255, 'Y'+127, 'O'+127, 'U'+127, 'R'+127, 255, 'W'+127, 'A'+127, 'Y'+127, 255, 'T'+127, 'H'+127, 'R'+127, 'O'+127, 'U'+127, 'G'+127, 'H'+127
      rept 1
      db 255
      endm
;THE DUNGEON USING THE
      db 'T'+127, 'H'+127, 'E'+127, 255, 'D'+127, 'U'+127, 'N'+127, 'G'+127, 'E'+127, 'O'+127, 'N'+127, 255, 'U'+127, 'S'+127, 'I'+127, 'N'+127, 'G'+127, 255, 'T'+127, 'H'+127, 'E'+127
      rept 5
      db 255
      endm
;STAIRS UP % AND DOWN %.
      db 'S'+127, 'T'+127, 'A'+127, 'I'+127, 'R'+127, 'S'+127, 255, 'U'+127, 'P'+127, 255, 34, 255, 'A'+127, 'N'+127, 'D'+127, 255, 'D'+127, 'O'+127, 'W'+127, 'N'+127, 255, 35, 248
      rept 3
      db 255
      endm

introtext4:
; start at 2,3
;     - HOW TO PLAY -
      db 255,255,255,255,255,254,255,'H'+127,'O'+127,'W'+127,255,'T'+127,'O'+127,255,'P'+127,'L'+127,'A'+127,'Y'+127,255,254
      rept 6+26
      db 255
      endm

;TRY TO COLLECT THE
      db 'T'+127, 'R'+127, 'Y'+127, 255, 'T'+127, 'O'+127, 255, 'C'+127, 'O'+127, 'L'+127, 'L'+127, 'E'+127, 'C'+127, 'T'+127, 255, 'T'+127, 'H'+127, 'E'+127
      rept 8
      db 255
      endm
;TREASURE % ON EACH FLOOR.
      db  'T'+127, 'R'+127, 'E'+127, 'A'+127, 'S'+127, 'U'+127, 'R'+127, 'E'+127, 255, 38, 255, 'O'+127, 'N'+127, 255, 'E'+127, 'A'+127, 'C'+127, 'H'+127, 255, 'F'+127, 'L'+127, 'O'+127, 'O'+127, 'R'+127, 255,255
;THE ITEMS WITHIN WILL 
      db 'T'+127, 'H'+127, 'E'+127, 255, 'I'+127, 'T'+127, 'E'+127, 'M'+127, 'S'+127, 255, 'W'+127, 'I'+127, 'T'+127, 'H'+127, 'I'+127, 'N'+127, 255, 'W'+127, 'I'+127, 'L'+127, 'L'+127
      rept 5
      db 255
      endm
;HELP YOU IN YOUR QUEST.
      db 'H'+127, 'E'+127, 'L'+127, 'P'+127, 255, 'Y'+127, 'O'+127, 'U'+127, 255, 'I'+127, 'N'+127, 255, 'Y'+127, 'O'+127, 'U'+127, 'R'+127, 255, 'Q'+127, 'U'+127, 'E'+127, 'S'+127, 'T'+127,255
      rept 3+26
      db 255
      endm
;BUT BEWARE! IT MIGHT BE
      db 'B'+127, 'U'+127, 'T'+127, 255, 'B'+127, 'E'+127, 'W'+127, 'A'+127, 'R'+127, 'E'+127, 249, 255, 'I'+127, 'T'+127, 255, 'M'+127, 'I'+127, 'G'+127, 'H'+127, 'T'+127, 255, 'B'+127, 'E'+127
      rept 3
      db 255
      endm
;WISE TO SAVE SOME ITEMS
      db 'W'+127, 'I'+127, 'S'+127, 'E'+127, 255, 'T'+127, 'O'+127, 255, 'S'+127, 'A'+127, 'V'+127, 'E'+127, 255, 'S'+127, 'O'+127, 'M'+127, 'E'+127, 255, 'I'+127, 'T'+127, 'E'+127, 'M'+127, 'S'+127
      rept 3
      db 255
      endm
;FOR LATER.
      db 'F'+127, 'O'+127, 'R'+127, 255, 'L'+127, 'A'+127, 'T'+127, 'E'+127, 'R'+127, 255
      rept 16
      db 255
      endm

	;low mid high
	;'L'+127,'O'+127,'W'+127
	;'M'+127,'I'+127,'D'+127
	;'H'+127,'I'+127,'G'+127,'H'+127
introtext5:
; start at 2,3
;     - HOW TO PLAY -
      db 255,255,255,255,255,254,255,'H'+127,'O'+127,'W'+127,255,'T'+127,'O'+127,255,'P'+127,'L'+127,'A'+127,'Y'+127,255,254
      rept 6+26
      db 255
      endm
;HEALTH RESTORING ITEMS:
      db 'H'+127, 'E'+127, 'A'+127, 'L'+127, 'T'+127, 'H'+127, 255, 'R'+127, 'E'+127, 'S'+127, 'T'+127, 'O'+127, 'R'+127, 'I'+127, 'N'+127, 'G'+127, 255, 'I'+127, 'T'+127, 'E'+127, 'M'+127, 'S'+127, 253
      rept 3
      db 255
      endm
;  % 00HP  % 00HP % 00HP
      db 255, 255, 39, 255, 'L'+127, 'O'+127, 'W'+127, 255, 255, 255, 45, 255, 'M'+127, 'I'+127, 'D'+127, 255, 255, 46, 255, 'H'+127, 'I'+127, 'G'+127, 'H'+127
      rept 3+26
      db 255
      endm
;ATTACK BONUS ITEMS:
      db 'A'+127, 'T'+127, 'T'+127, 'A'+127, 'C'+127, 'K'+127, 255, 'B'+127, 'O'+127, 'N'+127, 'U'+127, 'S'+127, 255, 'I'+127, 'T'+127, 'E'+127, 'M'+127, 'S'+127, 253
      rept 7
      db 255
      endm
;  % +00   % +00   % +00
      db 255, 255, 41, 255, 246, 'L'+127, 'O'+127, 'W'+127, 255, 255, 49, 255, 246, 'M'+127, 'I'+127, 'D'+127, 255, 255, 48, 255, 246, 'H'+127, 'I'+127, 'G'+127, 'H'+127
      rept 1+26
      db 255
      endm
;DEFENSE BONUS ITEMS:
      db 'D'+127, 'E'+127, 'F'+127, 'E'+127, 'N'+127, 'S'+127, 'E'+127, 255, 'B'+127, 'O'+127, 'N'+127, 'U'+127, 'S'+127, 255, 'I'+127, 'T'+127, 'E'+127, 'M'+127, 'S'+127, 253
      rept 6
      db 255
      endm
;  % +00   % +00   % +00
      db 255, 255, 42, 255, 246, 'L'+127, 'O'+127, 'W'+127, 255, 255, 50, 255, 246, 'M'+127, 'I'+127, 'D'+127, 255, 255, 51, 255, 246, 'H'+127, 'I'+127, 'G'+127, 'H'+127,255
      


introtext6:
; start at 2,3
;     - HOW TO PLAY -
      db 255,255,255,255,255,254,255,'H'+127,'O'+127,'W'+127,255,'T'+127,'O'+127,255,'P'+127,'L'+127,'A'+127,'Y'+127,255,254
      rept 6+26
      db 255
      endm
;THE DUNGEON IS CRAWLING
      db 'T'+127, 'H'+127, 'E'+127, 255, 'D'+127, 'U'+127, 'N'+127, 'G'+127, 'E'+127, 'O'+127, 'N'+127, 255, 'I'+127, 'S'+127, 255, 'C'+127, 'R'+127, 'A'+127, 'W'+127, 'L'+127, 'I'+127, 'N'+127, 'G'+127
      rept 3
      db 255
      endm
;WITH VARIOUS ENEMIES. 
      db 'W'+127, 'I'+127, 'T'+127, 'H'+127, 255, 'V'+127, 'A'+127, 'R'+127, 'I'+127, 'O'+127, 'U'+127, 'S'+127, 255, 'E'+127, 'N'+127, 'E'+127, 'M'+127, 'I'+127, 'E'+127, 'S'+127, 255
      rept 5
      db 255
      endm
;MOST OF THEM WILL STOP AT
      db 'M'+127, 'O'+127, 'S'+127, 'T'+127, 255, 'O'+127, 'F'+127, 255, 'T'+127, 'H'+127, 'E'+127, 'M'+127, 255, 'W'+127, 'I'+127, 'L'+127, 'L'+127, 255, 'S'+127, 'T'+127, 'O'+127, 'P'+127, 255, 'A'+127, 'T'+127
      rept 1
      db 255
      endm
;NOTHING TO DESTROY YOU!
      db 'N'+127, 'O'+127, 'T'+127, 'H'+127, 'I'+127, 'N'+127, 'G'+127, 255, 'T'+127, 'O'+127, 255, 'D'+127, 'E'+127, 'S'+127, 'T'+127, 'R'+127, 'O'+127, 'Y'+127, 255, 'Y'+127, 'O'+127, 'U'+127, 249
      rept 3
      db 255
      endm
;   % BAT      % DRAGON
      db 255, 255, 255, 96, 255, 'B'+127, 'A'+127, 'T'+127, 255, 255, 255, 255, 255, 255, 106, 255, 'D'+127, 'R'+127, 'A'+127, 'G'+127, 'O'+127, 'N'+127
      rept 4
      db 255
      endm
;   % GOBLIN   % GHOST
      db 255, 255, 255, 98, 255, 'G'+127, 'O'+127, 'B'+127, 'L'+127, 'I'+127, 'N'+127, 255, 255, 255,115, 255, 'G'+127, 'H'+127, 'O'+127, 'S'+127, 'T'+127
      rept 5+26
      db 255
      endm
;ATTACK BY DIRECTLY WALKING
      db 'A'+127, 'T'+127, 'T'+127, 'A'+127, 'C'+127, 'K'+127, 255, 'B'+127, 'Y'+127, 255, 'D'+127, 'I'+127, 'R'+127, 'E'+127, 'C'+127, 'T'+127, 'L'+127, 'Y'+127, 255, 'W'+127, 'A'+127, 'L'+127, 'K'+127, 'I'+127, 'N'+127, 'G'+127
;INTO THEM.
      db 'I'+127, 'N'+127, 'T'+127, 'O'+127, 255, 'T'+127, 'H'+127, 'E'+127, 'M'+127, 248
      rept 16
      db 255
      endm




keytest:        
         call _joy
         and    00010000B
         jr     z,2f

        ld a,8
        call 0x0141 ; getin keytest
        inc a
        ret z
2:      pop af  ; remove ret
        ret        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
spritemask2:
        db 72-1,80,3*4,1,72-1,120,4*4,1,80-1,128,5*4,1,0xD0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

foundamulet
		call    disscr
		ld	hl,MUSIC2			; hl <- initial address of module 
        call	PT3_INIT			; Inits PT3 player


; - clean screen

        ld hl,0x1800
        call setwrt
        xor a
        ld  b,a
        dec a
        rept    3
1:      out (0x98),a
        nop
        djnz    1b
        endm

        ld hl,ddampat
        ld de,0x0000
        call    out2k
        ld hl,ddamcol
        ld de,0x2000
        call    out2k

        ld hl,ddampat
        ld de,0x0000+256*8
        call    out2k
        ld hl,ddamcol
        ld de,0x2000+256*8
        call    out2k


      ; show sprite 3 at 80,72
      ; show sprite 4 at 120,72
      ; show sprite 5 at 128,80

        ld hl,0x1b00
        call setwrt
        halt
        ld   hl,spritemask2
        ld   bc,(3*4+1)*256+0x98
        otir


; Plot amulet picture
        halt
        ld      de,amuletpnt
        ld      hl,0x1800+5*32+7
        ld      bc,9*256+0x98
1:
        push    bc

        call setwrt

        ld      bc,32
        add     hl,bc
        push    hl

        ex      de,hl
        ld      bc,18*256+0x98
        call slowotir
        ex      de,hl

        pop     hl
        pop     bc
        djnz    1b

        call    enascr

; Draw text 1

        ld      hl,0x1800+16*32+6
        ld      de,amulettext1
        ld      b,2
        ld      a,21
        call    printtext

        ld  b,3*50
1:      halt
        djnz    1b

; Draw text 2

        ld      hl,0x1800+16*32+6
        ld      b,2
        ld      a,19
        ld      de,amulettext2
        call    printtext

        ; wait  seq == 2

1:      halt
        call keytest2

        call    seq
        ld  a,1
        cp  l
        jr  nc,1b

; Draw text 3

        ld      hl,0x1800+16*32+6
        ld      b,3
        ld      a,23
        ld      de,amulettext3
        call    printtext

        ; wait  seq == 3

1:      halt
        call keytest2

        call    seq
        ld  a,2
        cp  l
        jr  nc,1b

; Draw text 4

        ld      hl,0x1800+16*32+6
        ld      b,3
        ld      a,23
        ld      de,amulettext4
        call    printtext

        ; wait  seq == 4

1:      halt
        call keytest2

        call    seq
        ld  a,3
        cp  l
        jr  nc,1b

; restore in fame tiles

restoreingamescreen:

        call    disscr
        ld hl,ddpatterns
        ld de,0x0000
        call    out2k
        ld hl,ddcolors
        ld de,0x2000
        call    out2k

        ld hl,ddpatterns
        ld de,0x0000+256*8
        call    out2k
        ld hl,ddcolors
        ld de,0x2000+256*8
        call    out2k

        call _nosprt
        call drawlogo
        call    enascr

        ret

keytest2:
         call _joy
         and    00010000B
         jr     z,2f

        ld a,8
        call 0x0141 ; getin keytest2
        inc a
        ret z
2:      pop af  ; remove ret
        jp  restoreingamescreen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
amuletpnt:
      ; show amulet at 7,5
      db 48,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 80
      db 49, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 81
      db 50, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 82
      db 51, 96, 97, 98, 99,100,101,102,103,104,105,106,107,108,109,110,111, 83
      db 52,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143, 84
      db 53,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175, 85
      db 54,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207, 86
      db 55,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239, 87
      db 56, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 88

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       B # of line
;       A # line length
;       HL VRAM address
;       DE RAM  address

printtext:
        halt
        exx
        ex  af,af
        ld  b,0
        ld  hl,0x1800+32*16
        call setwrt         
        xor a
1:      out (0x98),a
        nop
        nop
        djnz 1b
        ex      af,af
        exx

_printtext:
        halt
1:      
        push    bc
        push    af
        call setwrt         
        pop     af

        ld      bc,64
        add     hl,bc
        push    hl
        
        ex      de,hl
        ld      b,a
        ld      c,0x98
        call slowotir
        ex      de,hl        
        
        pop     hl
        pop     bc
        djnz    1b
        ret

amulettext1:

; show text at 6,16
;WELL DONE!
      db 87+127, 69+127, 76+127, 76+127, 255, 68+127, 79+127, 78+127, 69+127, 249
      rept 11
      db 255
      endm
;YOU FOUND THE AMULET.
      db 89+127, 79+127, 85+127, 255, 70+127, 79+127, 85+127, 78+127, 68+127, 255, 84+127, 72+127, 69+127, 255, 65+127, 77+127, 85+127, 76+127, 69+127, 84+127, 255

; wait a few seconds
; clear text

amulettext2:

;pt3 seq#1
; show text at 6,16
;YET, YOU ARE ONLY 
      db 89+127, 69+127, 84+127, 247   , 255   , 89+127, 79+127, 85+127, 255,    65+127, 82+127, 69+127, 255, 'O'+127, 'N'+127, 'L'+127, 'Y'+127
      rept (19-17)
      db 255
      endm
;HALFWAY YOUR QUEST.
      db 'H'+127, 'A'+127,'L'+127, 'F'+127, 'W'+127, 'A'+127, 'Y'+127, 255,    89+127, 79+127, 85+127, 82+127, 255   , 81+127, 85+127, 69+127, 83+127, 84+127, 255

; wait a few seconds
; clear text

amulettext3

;pt3 seq#2
; show text at 5,16
;QUICKLY!
      db 81+127, 85+127, 73+127, 67+127, 75+127, 76+127, 89+127, 249
      rept (23-8)
      db 255
      endm
      
;IF YOU EVER WISH TO SEE
      db 73+127, 70+127, 255, 89+127, 79+127, 85+127, 255, 'E'+127, 'V'+127, 'E'+127, 'R'+127, 255, 'W'+127, 'I'+127, 'S'+127, 'H'+127, 255, 84+127, 79+127, 255, 83+127, 69+127, 69+127
;THE LIGHT OF DAY AGAIN,
      db 84+127, 72+127, 69+127, 255, 76+127, 73+127, 71+127, 72+127, 84+127, 255, 79+127, 70+127, 255, 68+127, 65+127, 89+127, 255, 65+127, 71+127,65+127, 73+127, 78+127, 247


amulettext4:

; wait a few seconds
; clear text
;pt3 seq#3
; show text at 5,16
;ASCEND BACK FROM THESE
      db 65+127, 83+127, 67+127, 69+127, 78+127, 68+127, 255, 66+127, 65+127, 67+127, 75+127, 255, 70+127, 82+127, 79+127, 77+127, 255, 84+127, 72+127, 69+127, 83+127, 69+127,255
;DANK DEPTHS OF THE DEEP
      db 68+127, 65+127, 78+127, 75+127, 255, 68+127, 69+127, 80+127, 84+127, 72+127, 83+127, 255, 79+127, 70+127, 255, 84+127, 72+127, 69+127, 255, 68+127, 69+127, 69+127, 80+127
;DUNGEON!
      db 68+127, 85+127, 78+127, 71+127, 69+127, 79+127, 78+127,249
      rept (23-8)
      db 255
      endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

spritemask3:
        db 64-1,104,6*4,1,80-1,104, 7*4,1,96-1,104, 8*4,1
        db 64-1,144,9*4,1,80-1,144,10*4,1,96-1,144,11*4,1,0xD0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

badendscript:

; no need to load tilesets
;[silence]


		ld	hl,MUSIC6			; hl <- initial address of module 
		call	PT3_INIT			; Inits PT3 player

        call cls
        call    disscr
		
; show sprite 6 at 104,64 and sprite 7 at 104,80 and sprite 8 at 104,96
; shpw sprite 9 at 144,64 and sprite 10 at 144,80 and sprite 11 at 144,96

        halt
        ld hl,0x1b00
        call setwrt
        halt
        ld   hl,spritemask3
        ld   bc,(6*4+1)*256+0x98
        otir


; show Exit start pos 11,6 (x,y) width 9 tiles and height 10
        
        ld      de,exitpnt
        ld      hl,0x1800+6*32+11
        ld      bc,9*256+0x98
1:      halt
        push    bc

        call setwrt

        ld      bc,32
        add     hl,bc
        push    hl

        ex      de,hl
        ld      bc,9*256+0x98
99:     outi
        nop
        nop
        jr  nz,99b
        ex      de,hl

        pop     hl
        pop     bc
        djnz    1b

; Draw text 1
; show text. start at pos 6,16

        ld      hl,0x1800+16*32+6
        ld      de,fakeendtext1
        ld      b,2
        ld      a,20
        call    printtext

        call    enascr


        ld  b,3*50
1:      halt
         call MAIN._joy
         and    00010000B
         jr     z,2f        ; skip on joystick button
         ld     a,8
         call   0x0141      ; skip on space
         and    1
         jr     z,2f
        djnz    1b
2:        

; Draw text 2
; show text at 4,16

        ld      hl,0x1800+16*32+4
        ld      de,fakeendtext2
        ld      b,4
        ld      a,26
        call    printtext

        ld  b,5*50
1:      halt
         call MAIN._joy
         and    00010000B
         jr     z,2f        ; skip on joystick button
         ld     a,8
         call   0x0141      ; skip on space
         and    1
         jr     z,2f
        djnz    1b
2:      

; Draw text 3
; show text. start at pos 6,16

        ld      hl,0x1800+16*32+6
        ld      de,fakeendtext3
        ld      b,2
        ld      a,21
        call    printtext

        ld  b,3*50
1:      halt
         call MAIN._joy
         and    00010000B
         jr     z,2f        ; skip on joystick button
         ld     a,8
         call   0x0141      ; skip on space
         and    1
         jr     z,2f
        djnz    1b
2:      

; Draw text 4
; show text at 7,16

        ld      hl,0x1800+16*32+7
        ld      de,fakeendtext4
        ld      b,2
        ld      a,18
        call    printtext

        ld  b,3*50
1:      halt
         call MAIN._joy
         and    00010000B
         jr     z,2f        ; skip on joystick button
         ld     a,8
         call   0x0141      ; skip on space
         and    1
         jr     z,2f
        djnz    1b
2:      

; return into the game. Start music again.
        call _nosprt
        call    drawlogo

		ld	hl,MUSIC1			; hl <- initial address of module 
		call	PT3_INIT			; Inits PT3 player

        ld ix,PAGE0

        ret

exitpnt:
; show Exit start pos 11,6 (x,y) width 9 tiles and height 9
  db 255,255,255,128,255,129,130,255,255
  db 255,255,131,132,133,134,135,136,255
  db 255,137,138,139,140,140,140,141,255
  db 255,142,143,140,140,140,140,144,145
  db 255,146,147,140,140,140,140,148,149
  db 255,150,151,140,140,140,140,152,153
  db 255,160,161,162,163,164,165,166,167
  db 168,169,170,171,172,173,174,175,176
  db 177,178,179,180,181,182,183,184,185

fakeendtext1:
; YOU RETURNED, ENDING
      db 89+127, 79+127, 85+127, 255, 82+127, 69+127, 84+127, 85+127, 82+127, 78+127, 69+127, 68+127,  247, 255, 69+127, 78+127, 68+127, 73+127, 78+127, 71+127
; YOUR QUEST.
      db 89+127, 79+127, 85+127, 82+127, 255, 81+127, 85+127, 69+127, 83+127, 84+127, 248
      rept (20-11)
           db 255
      endm
; wait some time
; clear text

; show text at 4,16
fakeendtext2:
;HASTELY, YOU MAKE YOUR WAY
      db 72+127, 65+127, 83+127, 84+127, 69+127, 76+127, 89+127, 247, 255, 89+127, 79+127, 85+127, 255, 77+127, 65+127, 75+127, 69+127, 255, 89+127, 79+127, 85+127, 82+127, 255, 87+127, 65+127, 89+127
;BACK OUTSIDE, CHASED BY A
      db 66+127, 65+127, 67+127, 75+127, 255, 79+127, 85+127, 84+127, 83+127, 73+127, 68+127, 69+127, 247, 255, 67+127, 72+127, 65+127, 83+127, 69+127, 68+127, 255, 66+127, 89+127, 255, 65+127,255
;FIERCE HORDE OF YOUR
      db 70+127, 73+127, 69+127, 82+127, 67+127, 69+127, 255, 72+127, 79+127, 82+127, 68+127, 69+127, 255, 79+127, 70+127, 255, 89+127, 79+127, 85+127, 82+127,255,255,255,255,255,255
;ENEMIES.
      db 'E'+127, 'N'+127, 'E'+127, 'M'+127, 'I'+127, 'E'+127, 'S'+127, 255
      rept (26-8)
           db    255
      endm
; wait some time
; clear text

fakeendtext3:
;show text at 6,16
;...BUT AREN'T YOU
      db 248, 248, 248, 66+127, 85+127, 84+127, 255, 65+127, 82+127, 69+127, 78+127, 251, 84+127, 255, 89+127, 79+127, 85+127,255,255,255,255
;FORGETTING SOMETHING?
      db 'F'+127,'O'+127,'R'+127,'G'+127,'E'+127,'T'+127,'T'+127,'I'+127,'N'+127,'G'+127,255,'S'+127,'O'+127,'M'+127,'E'+127,'T'+127,'H'+127,'I'+127,'N'+127,'G'+127,250

; wait some time
; clear text

;show text at 7,16
fakeendtext4:
;YOU FEEL SILLY AND
      db 89+127, 79+127, 85+127, 255, 70+127, 69+127, 69+127, 76+127, 255, 83+127, 73+127, 76+127, 76+127, 89+127, 255, 65+127, 78+127, 68+127
;RETURN.
      db 82+127, 69+127, 84+127, 85+127, 82+127, 78+127, 255
      rept (18-7)
           db    255
      endm



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; disable all sprites

_nosprt:
            di
            xor a
            out (0x99),a
            ld a,0x1b00/256 + 0x40 ; SAT
            out (0x99),a
            ld a,0xD0
            out (0x98),a ; disable sprites
            ei
            ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;----- text


startgamemessage:
;         db "PRESS SPACE TO START"
         db 80+127, 82+127, 69+127, 83+127, 83+127, 255, 83+127, 80+127, 65+127, 67+127, 69+127, 255, 84+127, 79+127, 255, 83+127, 84+127, 65+127, 82+127, 84+127

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

render:
         call   _3dview
         call   new_colors

         ld     hl,0x1800
         call   setwrt
         ex     de,hl
         ld     hl,buffer
         ld     bc,24*256+0x98
2:
         push   bc
         ld     b,24 ; always 24
1:       outi
         nop
         jr nz,1b
            
         ex     de,hl
         ld     bc,32
         add    hl,bc
         call   setwrt
         ex     de,hl

         pop    bc
         djnz   2b

         ;
         ;
sidebar:
;-- "Hp:10 Gold:0000 L:01"

         ld hl,0x18A0+24
         call setwrt
         ld hl,gold
         ld b,4
         call slowotir
         ld a,(ix+GOLD)
         ld hl,0x18A0+31
         call writebcd
         ld a,(ix+GOLD100)
         dec hl
         call writebcd

         ld hl,0x1900+24
         call setwrt
         ld hl,hp
         ld b,5
         call slowotir
         ld a,(ix+HITPOINTS)
         ld hl,0x1900+31
         call writebcd

         ld hl,0x1960+24-32
         call setwrt
         ld hl,att
         ld b,6
         call slowotir
         ld a,(ix+ATT)
         ld hl,0x1960+31-32
         call writebcd

         ld hl,0x1980+24-32
         call setwrt
         ld hl,def
         ld b,6
         call slowotir
         ld a,(ix+DEF)
         ld hl,0x1980+31-32
         call writebcd


         ld a,(ix+AMULET)
         and    a
         jr z,1f
         ld hl,0x1A80+24+64
         call setwrt
         ld hl,amulet
         ld b,3
         call slowotir
         ld     a,amuletchr
         ld hl,0x1A80+30+64
         call   wrtvrm
1:
         ld hl,0x1AC0+24-32
         call setwrt
         ld hl,lv
         ld b,6
         call slowotir
         ld a,(ix+LEVEL)
         ld hl,0x1AC0+31-32
         call writebcd

         ld hl,0x1AC0+24+32
         call setwrt
         ld     a,44           ;T
         out    (0x98),a
         ld     a,253           ;:
         nop
         nop
         out    (0x98),a

         ld hl,0x1AC0+31+32
         ld a,(nround)
         call writebcd
         ld a,(nround+1)
         dec hl         
         call writebcd
         ld a,(nround+2)
         dec hl         
         call writebcd

         ret
logo:
        db  224,225,226,227,228,229,230,255
        db  231,232,233,234,235,236,237,238
        db  255,239,240,241,242,243,244,245
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
setdot:
        ex  af,af
        exx

;-- displace depth indicator in the scorebar

        ld  a,(PAGE0+_lastlevel)
        call    Bcd2Hex
        dec a
        ld  c,a

        xor a
        ld  h,a
        ld  d,a
        
        ld  a,(PAGE0+LEVEL)
        call    Bcd2Hex
        dec a
        add a,a
        add a,a
        ld  e,a    ;x4

        ld  l,a
        
        add hl,hl
        add hl,hl
        add hl,hl   ;x32
        
        add hl,de   ;x36
        xor a
        call    div16
        ld      d,l
        
        ld      hl,0x1b00
        call    setwrt        
        ld      a,14*8-1
        add     a,d
        push    af
        out (0x98),a
        ld    a,28*8
        nop
        nop
        out (0x98),a
        ld    a,112
        nop
        nop
        out (0x98),a
        nop
        nop
        ld    a,15
        out (0x98),a

        pop     af
        nop
        nop
        out (0x98),a
        ld    a,28*8
        nop
        nop
        out (0x98),a
        ld    a,108
        nop
        nop
        out (0x98),a
        ld    a,1
        nop
        nop
        out (0x98),a
        nop
        nop
        ld    a,0xd0
        out (0x98),a
        ex  af,af
        exx
        
        ret

;-- change colors in the level

new_colors:

        ex  af,af
        exx

        ld  a,(PAGE0+_lastlevel)
        call    Bcd2Hex
        ld  e,a

        ld  a,(PAGE0+LEVEL)
        call    Bcd2Hex        
        dec a
        ld  d,a
        add a,a
        add a,a
        add a,d         ; x5
        
        ld  d,a         ; D = Dividend, E = Divisor, A = 0
        xor a
        call    div8    ;Output: D = Quotient, A = Remainder

        ld      a,d
        add     a,122   ; wall(s) position
        ld      l,a
        ld      h,0
        add     hl,hl
        add     hl,hl
        add     hl,hl   ;x8
        ld      bc,0x2000  ; vram address
        add     hl,bc
        call    setrd
        ld      hl,dummy
        ld      bc,0x0898
        call slowinir

        ld      hl,0x2000+1*8
        call    setwrt
        ld      hl,dummy
        ld      bc,0x0898
        call slowotir
        ld      hl,0x2000+1*8+256*8
        call    setwrt
        ld      hl,dummy
        ld      bc,0x0898
        call slowotir
        ld      hl,0x2000+1*8+256*8*2
        call    setwrt
        ld      hl,dummy
        ld      bc,0x0898
        call slowotir

;;;;;;;;;;;

        ld      a,d
        add     a,a     ;x2
        add     a,6     ; floor position
        ld      l,a
        ld      h,0
        add     hl,hl
        add     hl,hl
        add     hl,hl       ;x8
        ld      bc,0x2000  ; vram address
        add     hl,bc
        call    setrd
        ld      hl,dummy
        ld      bc,0x1098
        call    slowinir

        ld      hl,0x2000+33*8
        call    setwrt
        ld      hl,dummy
        ld      bc,0x0898
        call slowotir
        ld      hl,0x2000+33*8+256*8
        call    setwrt
        ld      hl,dummy
        ld      bc,0x0898
        call slowotir
        ld      hl,0x2000+33*8+256*8*2
        call    setwrt
        ld      hl,dummy
        ld      bc,0x0898
        call slowotir

        ld      hl,0x2000+32*8
        call    setwrt
        ld      hl,dummy+8
        ld      bc,0x0898
        call slowotir
        ld      hl,0x2000+32*8+256*8
        call    setwrt
        ld      hl,dummy+8
        ld      bc,0x0898
        call slowotir
        ld      hl,0x2000+32*8+256*8*2
        call    setwrt
        ld      hl,dummy+8
        ld      bc,0x0898
        call slowotir

        ex  af,af
        exx

        ret        
        
;Input: HL = Dividend, C = Divisor, A = 0
;Output: HL = Quotient, A = Remainder (see note)
div16:
    rept        16
	add	hl,hl		; unroll 16 times
	rla			; ...
	cp	c		; ...
	jr	c,$+4		; ...
	sub	c		; ...
	inc	l		; ...
    endm
    ret

;Input: A = BCD number
;Output: A = binary value
    
Bcd2Hex:
        push    bc
        push    af
        rrca
        rrca
        rrca
        rrca
        and 15

        add a,a 
        ld  c,a
        add a,a
        add a,a
        add a,c     ; x10
        
        ld  c,a
        pop af
        and 15
        add a,c
        pop bc
        ret        
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        endmodule


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; pletter v0.5 msx unpacker

; call unpack with hl pointing to some pletter5 data, and de pointing to the destination.
; changes all registers

    module pletter
  
    MACRO MGBIT
    add a,a
    call z,getbit
    ENDM

    MACRO MGBITEXX
    add a,a
    call z,getbitexx
    ENDM
    
_unpack:
    ld a,(hl)
    inc hl
    exx
    ld de,0
    add a,a
    inc a
    rl e
    add a,a
    rl e
    add a,a
    rl e
    rl e
    ld hl,_modes
    add hl,de
    ld e,(hl)
    db 0xdd,0x6b ; ld ixl,e
    inc hl
    ld e,(hl)
    db 0xdd,0x63 ; ld ixh,e
    ld e,1
    exx
    ld iy,loop
literal:
    ldi
loop:
    MGBIT
    jr nc,literal
    exx
    ld h,d
    ld l,e
getlen:
    MGBITEXX
    jr nc,_lenok
_lus:
    MGBITEXX
    adc hl,hl
    ret c
    MGBITEXX
    jr nc,_lenok
    MGBITEXX
    adc hl,hl
    ret c
    MGBITEXX
    jp c,_lus
_lenok:
    inc hl
    exx
    ld c,(hl)
    inc hl
    ld b,0
    bit 7,c
    jp z,_offsok
    jp (ix)
    
mode7:
    MGBIT
    rl b
mode6:
    MGBIT
    rl b
mode5:
    MGBIT
    rl b
mode4:
    MGBIT
    rl b
mode3:
    MGBIT
    rl b
mode2:
    MGBIT
    rl b
    MGBIT
    jr nc,_offsok
    or a
    inc b
    res 7,c
_offsok:
    inc bc
    push hl
    exx
    push hl
    exx
    ld l,e
    ld h,d
    sbc hl,bc
    pop bc
    ldir
    pop hl
    jp (iy)
    
getbit:
    ld a,(hl)
    inc hl
    rla
    ret
    
getbitexx:
    exx
    ld a,(hl)
    inc hl
    exx
    rla
    ret
    
_modes:
  dw _offsok
  dw mode2
  dw mode3
  dw mode4
  dw mode5
  dw mode6
  dw mode7

    endmodule
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        module MAIN
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; to be called at game start
;

initchest:
         ld   b,(ix+_lastlevel)
         ld   hl,memchst
         ld   a,0xFF
1:       ld   (hl),a
         inc  hl
         djnz 1b        ; all chests in all levels are closed and full

         ld    h,(ix+_lastlevel)
         ld    e,(ix+_chests)
         call  mul8
         add   hl,hl
         ld    bc,hl         ; 2*LASTLEVEL*CHESTS
         ld     hl,locchst


1:       ld     (hl),0
         inc    hl
         dec    bc
         ld     a,b
         or     c
         jr     nz,1b   ; positions of all chests reset to 0
         
         ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; points to the list of chest positions for current LEVEL
; output:
;  hl points to the first chest in locchst

chestlist:
        ld      e,(ix+LEVEL)
        dec     e
        ld      h,(ix+_chests)
        sla     h               ; 2*CHESTS
        call    MAIN.mul8
        ld      de,locchst
        add     hl,de           ; points to the list of chest positions for current LEVEL
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; input
; b = number of chest in the current LEVEL
; de position of the chest to be stored in table locchst
;

storechestinfo:
        push    de
        call    chestlist        ; LEVEL == 1 -> prima riga, LEVEL == 2 -> seconda riga, ect
        ld      e,b
        ld      d,0
        dec     de              ; b=1 prima posizione, b=2 seconda posizione, etc
        add     hl,de
        add     hl,de           ; points to the position of the chest #b
        pop     de
        ld      (hl),de         ; store the chest position
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; no input
; remove opened chests in the current level
;

removeopenchests:

        ld      b,(ix+_chests)
1:
        call    testchst
        jr      nz,chestfull

        call    chestlist        ; LEVEL == 1 -> prima riga, LEVEL == 2 -> seconda riga, ect
        ld      e,b
        ld      d,0
        dec     de              ; b=1 prima posizione, b=2 seconda posizione, etc
        add     hl,de
        add     hl,de           ; points to the position of the chest #b
        
        ld      a,(hl)
        inc     hl
        ld      h,(hl)
        ld      l,a

        ld      (hl),floorchr

chestfull:
        djnz    1b
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; input
; b = number of chest in the current LEVEL
; output
; NZ if the chest is full, Z if the chest has been already opened
; hl points to the byte dedicated to the current level
; a is the masked value

testchst:
         ld     a,0x01          ; genera una maschera di 0 con uno 1 nella posizione data da b
         push   bc

         dec    b
         jr     2f
1:       rlca
2:       djnz   1b            ; b=1 -> a=1, b=2 -> a=2, b=3 -> a=4, b=4 -> a=8, etc

         pop    bc

         ld     e,(ix+LEVEL)
         dec    e
         ld     d,0
         ld     hl,memchst
         add    hl,de         ; LEVEL == 1 prima posizione, LEVEL == 2 seconda posizione,etc
         and    (hl)

         ret        ; return NZ if the chest is full, Z if it is already opened


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; input
;   hl   = X,Y chest position in level LEVEL
; output
;   reset the chest flag in memchst table

openchest:
        call       locate       ; convert x,y to position
        push       de

        call       chestlist    ; LEVEL == 1 -> prima riga, LEVEL == 2 -> seconda riga, ect

        ld         iy,hl
        pop        de
                                ; search for the chest position in the list

        ld         b,(ix+_chests)
1:      ld         hl,(iy+0)
        call       0x20         ; compare HL and DE
        jr         z,found      ; return in B the number of iteration, now if B = CHESTS, the chest is in the first position
        inc        iy
        inc        iy
        djnz       1b
notfound:
        ret

found:  ld          a,(ix+_chests)
        inc         a
        sub         b            ; now, if B = CHESTS => a = 1
        ld          b,a

        call       testchst     ; if the chest is closed, a is the mask             
        cpl                     ; negate the mask
        and        (hl)         
        ld         (hl),a       ; open the current chest
        ret        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; input
;   none
; output
;   a and l
; Bit    	Description
;0        Input joystick pin 1      (up)
;1        Input joystick pin 2      (down)
;2        Input joystick pin 3      (left)
;3        Input joystick pin 4      (right)
;4        Input joystick pin 6      (trigger A)
;5        Input joystick pin 7      (trigger B)

        include "joy.asm"

		; --- INCLUDE new FoV code ---

        include "fastfov.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; slow Vram patch
;
slowotir:
1:      outi
        nop
        jr  nz,1b
        ret
slowinir:
1:      ini
        nop
        jr  nz,1b
        ret

    
  endmodule


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; sprites
;-------------------------------------

titlesprites:
;            include titlespgt.asm
            include newspgt.asm

; in game tileset
ddcolors:
    incbin "tiles\ddcol.bin.miz"
ddpatterns:
    incbin "tiles\ddpat.bin.miz"

; title
ddpat1:
    ; incbin "tiles\ddapat1.bin.miz"
ddpat2:
    ; incbin "tiles\ddapat2.bin.miz"
ddpatl2:
	incbin "tiles\ddapat12.bin.miz"

ddcol1:
    ; incbin "tiles\ddacol1.bin.miz"
ddcol2:
    ; incbin "tiles\ddacol2.bin.miz"
	
ddcol12:
	incbin "tiles\ddacol12.bin.miz"

	; amulet
ddamcol:
    incbin "tiles\ddamcol.bin.miz"
ddampat:
    incbin "tiles\ddampat.bin.miz"

; ending
; endpat1:
;    incbin "tiles\dde1pat.bin.miz"
; endpat2:
;    incbin "tiles\dde2pat.bin.miz"
; endpat3:
;    incbin "tiles\dde3pat.bin.miz"
endpat123:
    incbin "tiles\endpat.pgt.bin.miz"

; endcol1:
;    incbin "tiles\dde1col.bin.miz"
; endcol2:
;    incbin "tiles\dde2col.bin.miz"
; endcol3:
;    incbin "tiles\dde3col.bin.miz"
endcol123:
    incbin "tiles\endcol.ct.bin.miz"


        module miz
; -------------------------------------------------------
; MSX-O-Mizer v1.5f datas depacker    *ROM based version*
; Improved from Metalbrain's z80 version.
; -------------------------------------------------------
; source in hl
; dest in de

; 328 bytes which must be aligned on 8 bits boundary
mom_map_bits_rom    =       0xF100
; 26 bytes located in ram
mom_offset_table    =       0xF100 + 328

_unpack:

mom_depack_rom:     push    de
                    ld      bc, mom_offset_table
                    push    bc
                    ld      de, bc
                    ld      bc, 26
                    ldir
                    push    hl
                    pop     af
                    pop     hl
                    push    af
                    ld      iy, mom_map_bits_rom + 0xf0
                    ld      b, 52
mom_init_bits_rom:  ld      a, iyl
                    and     15
                    jr      nz, mom_node_rom
                    ld      de, 1
mom_node_rom:       rrd
                    ld      (iy), a
                    ld      (iy + 36), e
                    ld      (iy + 72), d
                    inc     iyl
                    inc     a
                    push    hl
                    ld      hl, 0
                    scf
mom_set_bit_rom:    adc     hl, hl
                    dec     a
                    jr      nz, mom_set_bit_rom
                    add     hl, de
                    ex      de, hl
                    pop     hl
                    bit     0, b
                    jr      z, mom_wait_step_rom
                    inc     hl
mom_wait_step_rom:  djnz    mom_init_bits_rom
                    pop     hl
                    ld      a, (hl)
                    inc     hl
                    ld      ixh, a
                    pop     de
mom_lit_copy_rom:   ldi
mom_main_loop_rom:  call    mom_get_bit_rom
                    jr      c, mom_lit_copy_rom
                    ld      c, -17
mom_get_index_rom:  call    mom_get_bit_rom
                    inc     c
                    jr      nc, mom_get_index_rom
                    ld      a, c
                    ret     z
                    push    de
                    call    mom_get_pair_rom
                    push    bc
                    jr      nz, mom_out_range_rom
                    ld      de, 0x0220
                    dec     c
                    jr      z, mom_go_for_it_rom
                    ld      de, 0x0410
                    dec     c
                    jr      z, mom_go_for_it_rom
mom_out_range_rom:  ld      de, 0x0400
mom_go_for_it_rom:  pop     af
                    ex      af, af'
                    call    mom_get_bits_rom
                    add     a, e
                    call    mom_get_pair_rom
                    pop     de
                    push    hl
                    ld      h, d
                    ld      l, e
                    sbc     hl, bc
                    ex      af, af'
                    push    af
                    pop     bc
                    ldir
                    pop     hl
                    jr      mom_main_loop_rom
mom_get_pair_rom:   ld      iyl, a
                    ld      d, (iy)
                    call    mom_get_bits_rom
                    add     (iy + 36)
                    ld      c, a
                    ld      a, b
                    adc     (iy + 72)
                    ld      b, a
                    ret
mom_get_bits_rom:   ld      bc, 0
mom_getting_bits_rom:
                    dec     d
                    ld      a, c
                    ret     m
                    call    mom_get_bit_rom
                    rl      c
                    rl      b
                    jr      mom_getting_bits_rom
mom_get_bit_rom:    ld      a, ixh
                    add     a
                    jr      nz, mom_byte_done_rom
                    ld      a, (hl)
                    inc     hl
                    rla
mom_byte_done_rom:  ld      ixh, a
                    ret
                    
                    endmodule
