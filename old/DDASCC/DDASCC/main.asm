		; --- December, 2008 by ARTRAG                      ---

                output "deepdung.rom"
        org 0000h
                        
        include intro\introplayer.asm

		ds	$4000 - $        
        org 4000h
		; --- ROM HEADER ---
                dw  0x4241,INIT,0,0,0,0,0,0   ; Rom starts in INIT label

        include SETPAGES48K.ASM

		INCLUDE "sccdetect\SCCaudio.asm"
		INCLUDE "sccdetect\SCCWAVES.ASM"
		INCLUDE "sccdetect\SCCDETEC.ASM"		
INIT:	

        ld a,15
        ld (forclr),a
        ld hl,0101h	 ; COLOR ,1,1
        ld (bakclr),hl

        xor a
        ld (0F3DBh),a ; key clik off
        ld (0F3DEh),a ; KEY OFF

        call test_easteregg

        ld a,2
        call 05Fh       ; screen 2
        call disscr
        di					        ; Disable interrupts
        
        call SETPAGES48K
        call intro_START
        call RESTOREBIOS

        ld a,2
        call 05Fh       ; screen 2
        call enascr

        ld      a,-3
        ld      (_psg_vol_fix),a
		
		call 	SCCINIT
		call 	_SCC_PSG_Volume_balance
        
        call    CheckIf60Hz
        dec a
        ld (vsf),a                ; 0=>60Hz, !0=>50Hz

        ld      hl,cnt
        ld      (hl),1               ; reset the tic counter

        ld      hl,INTERRUPT
        ld      (0xFD9F+1),hl
        ld      a,0xC3
        ld      (0xFD9F),a          ; install INTERRUPT

        call    ayFX_SETUP

        xor a
        ld     [PT3_SETUP],a       ; LOOP the song

        call    PT3_MUTE
        
		
        ld	hl,MUSIC6			; hl <- initial address of module 
        call	PT3_INIT			; Inits PT3 player

        ei					       ; Enable interrupts
        halt

        jp      startAdr

easteregg:
            incbin   intruder4K_redux\loader.bin,7
;;;;;;;;;;;;;;;;;;;;;;;;;
; test for easter eggs
;
test_easteregg:
        ld      e,7
        call    checkkbd
        cp      255-4           ; key ESC
        ret     nz

        ld      hl,easteregg
        ld      de,0xc000
        ld      bc,test_easteregg-easteregg+1
        ldir
        jp      0xc0A1




        include "setdiff.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
seq:
        ld  hl,(PT3_CrPsPtr)
        ld  de,(PT3_MODADDR)
        and a
        sbc hl,de
        ld  de,101+100
        and a
        sbc hl,de
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INTERRUPT:

          ld      a,(vsf)
          and     a
          jp      nz,PAL               ; if PAL call at any interrupt

NTSC:
          ld      hl,cnt               ; if NTSC call 5 times out of 6
          dec     (hl)
          jp      nz,PAL               ; skip one tic out of 6 when at 60hz

          ld      (hl),6               ; reset the tic counter
          ret                          ; interrupt exit

PAL:                             ; execute the PSG and ayFX core


        ; --- Place this instruction on interrupt or after HALT instruction to synchronize music ---
        call	PT3_ROUT			; Write values on PSG registers
    call    probewavechanges
    call    SCCROUT

	call Audio_Internal_code
		
	    ; --- To speed up VDP writes you can place this instruction after all of them, but before next INT ---
        ;call	PT3_PLAY			; Calculates PSG values for next frame

		
		; --- You can place here your favourite FX system and write the values to AYREGS label ---
        ;call	ayFX_FRAME			; Calculates PSG values for next frame

		; --- so on next frame the FX will be played automatically when calling PT3_ROUT       ---

        ret


;;;;;;;;;;;;;;;;;;;;;
;; Keyboard testing
;; ayFX
;
;        ld	a,(ayFX_PRIORITY)
;        cp      255
;        ret     nz              ; play only if no sfx is active
;
;; // 0 "7" "6" "5" "4" "3" "2" "1" "0"
;
;        ld      e,0
;        call    checkkbd
;
;        ld      b,8
;        ld      c,a
;1:
;        ld      a,b
;        dec     a
;        ld      l,a
;
;        ld      a,c
;        add     a,a
;        ld      c,a
;
;        push    bc
;        ld      a,l
;        ld      c,0            ;   Priority
;
;        call    nc,ayFX_INIT
;        pop     bc
;        djnz    1B
;        ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; returns 1 in a and clears z flag if vdp is 60Hz
;;
CheckIf60Hz:
        in      a,(0x99)
        nop
        nop
        nop
vdpSync:
         in      a,(0x99)
         and     0x80
         jr      z,vdpSync
    
         ld      hl,0x900
vdpLoop:
         dec     hl
         ld      a,h
         or      l
         jr      nz,vdpLoop
    
         in      a,(0x99)
         rlca
         and     1
         ret

;-------------------------------------
; checkkbd: ckeck keyboard line
; syntax:checkkbd <keyboar line #>
; in:  e
; out: l
;-------------------------------------

i8255portb  equ 0a9h        ; keyboard column input
i8255portc  equ 0aah        ; leds, motor, cassette, kbd line

checkkbd:
        in  a,(i8255portc)
        and 011110000B          ; upper 4 bits contain info to preserve
        or  e
        out (i8255portc),a
        in  a,(i8255portb)
        ld  l,a
        ret


		; --- INCLUDE ACTUAL GAME code ---

        INCLUDE	"WHACK_Z80.ASM"


		; --- INCLUDE PT3-ROM.ASM in ROM code ---

REPLAYER:	INCLUDE	"audio\PT3-ROM.ASM"

		; --- INCLUDE MUSIC in ROM code (don't forget to strip first 100 bytes of PT3 module ---


MUSIC0:		db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
			INCLUDE	"audio\music0.asm"
MUSIC1:		db 0x03,0x0B,0x0B,0x03,0x03,0x03,0,0x03,0x01,0x01,0x03,0,0,0,0,0
			INCLUDE	"audio\music3.asm"
MUSIC2:		db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
			INCLUDE	"audio\music2.asm"
MUSIC3:		db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
			INCLUDE	"audio\music1.asm"
MUSIC4:		db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
			INCLUDE	"audio\music4.asm"
MUSIC5:		db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
			INCLUDE	"audio\music5.asm"
MUSIC6:		db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
			INCLUDE	"audio\music6.asm"

;-------------------------------------
;
;      AYFX replayer
;
;-------------------------------------
;
; --- INCLUDE ayFX-ROM.ASM

        INCLUDE "audio\ayFX-ROM.ASM"
		
; --- INCLUDE ayFX - data

ayFX_STREAMS:
        dw sfx0,  sfx1, sfx2, sfx3, sfx4, sfx5, sfx6, sfx7,sfx8,sfx9,sfx10

sfx0:   incbin   "audio\afx\04_chest.afx"
sfx1:   incbin   "audio\afx\05_coin.afx"
sfx2:   incbin   "audio\afx\01_stairdwn.afx"
sfx3:   incbin   "audio\afx\02_stairup.afx"
sfx4:   incbin   "audio\afx\03_opendoor.afx"
sfx5:   incbin   "audio\afx\06_powerup.afx"
sfx6:   incbin   "audio\afx\07_potionsm.afx"
sfx7:   incbin   "audio\afx\08_potionbg.afx"
sfx8:   incbin   "audio\afx\09_enehit_1.afx"
sfx9:   incbin   "audio\afx\10_enehit_2.afx"
sfx10:  incbin   "audio\afx\11_plyr_hit.afx"
;-------------------------------------
; intro data
;-------------------------------------

firecol:
            ;incbin intro\tiles.col.bin.miz

        
;-------------------------------------
; Padding, align rom image to a power of two.
;-------------------------------------

		ds	$C000 - $

MAXLASTLEVEL = 40
MAXCHESTS    = 5

		; --- RAM SECTION ---
        MAP 0xc000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nround      FIELD 3
PAGE0       FIELD 256        ; emulate 6502 page 0
buffer      FIELD  2048         ; buffer for unpack
hidden      FIELD 1024       ; hidden level (emulate VIC color ram)
visible     FIELD 1024       ; visible area (emulate VIC color ram)

dummy       FIELD 100
MUSICBUFF   FIELD 4096

storedseed  FIELD 1

levels      FIELD 256        ; dungeon level pseudo-random seeds

seeds       FIELD MAXLASTLEVEL              ; store the seed for each level
memchst     FIELD MAXLASTLEVEL              ; store the chest status in each floor of the dungeon
locchst     FIELD 2*MAXLASTLEVEL*MAXCHESTS  ; store the chest position in each floor of the dungeon


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

vsf         FIELD 1          ; 0 if 50Hz, !0 if 60Hz
cnt         FIELD 1          ; couter to compensate NTSC machines

	; --- INCLUDE PT3-RAM.ASM in RAM section (no code output, but label definitions) ---

        INCLUDE	"audio\PT3-RAM.ASM"
        INCLUDE "audio\ayFX-RAM.ASM"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper variables from PT3 mobule
;

; pt3 samples previously detected (times 2)

OSmplA          FIELD 1
OSmplB          FIELD 1
OSmplC          FIELD 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

wchA    FIELD 1                  ; wave on channel A
wchB    FIELD 1                  ; wave on channel B
wchC    FIELD 1                  ; wave on channel C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_waves	FIELD	15


; ==========
;    Data
; ==========

SLOT            FIELD     1
PAGE1RAM        FIELD     1
RAMSLOT         FIELD     1

SCC             FIELD     1
SUB             FIELD     1

AYREGS_CPY:     FIELD  13


VolBalance:     FIELD 2
    ;dw VT_
; =================
;    Program end
; =================


        ENDMAP


