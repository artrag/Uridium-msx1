
; VDP ports
;
vdpport0    equ 098h        ; VRAM read/write
vdpport1    equ 099h        ; VDP registers read/write


PNT   equ    1800h ; Pattern Name Table
PGT   equ    0000h ; Pattern Generator Table
PCT   equ    2000h ; Pattern Color Table
SAT   equ    1b00h ; Sprite Attribute Table
SPT   equ    3800h ; Sprite Pattern Table



;Ln B_7 B_6 B_5 B_4 B_3 B_2 B_1 B_0
; 0 "7" "6" "5" "4" "3" "2" "1" "0"
; 1 ";" "]" "[" "\" "=" "-" "9" "8"
; 2 "B" "A" ??? "/" "." "," "'" "`"
; 3 "J" "I" "H" "G" "F" "E" "D" "C"
; 4 "R" "Q" "P" "O" "N" "M" "L" "K"
; 5 "Z" "Y" "X" "W" "V" "U" "T" "S"
; 6 F3 F2  F1 CODE CAP GRAPH CTR SHIFT
; 7 RET SEL BS STOP TAB ESC F5  F4
; 8 RIGHT DOWN UP LEFT DEL INS HOME SPACE


;; MSX bios calls

wrtvdp: equ $0047
rdvrm:  equ $004a
wrtvrm: equ $004d
setwrt: equ $0053
filvrm: equ $0056
ldirmv: equ $0059
ldirvm: equ $005c
chgmod: equ $005F
clrspr: equ $0069
initxt: equ $006c
init32: equ $006f

GICINI: equ $0090

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

WRTPSG    equ     00093h
RDPSG     equ     00096h

JIFFY     equ     0FC9Eh

RG0SAV:   equ     0F3DFH
RG1SAV    equ     0F3E0H
RG8SAV:   equ     0F3E7H        ; VDP Register 8 Save copy.


  STRUCT NPCS_DATA
X              ds 2
Y              ds 2
Xsize          ds 1 ; Xsize
Ysize          ds 1 ; Ysize

DX             ds 1
DY             ds 1

FRAME          ds 1
CLR            ds 1

STATUS         ds 1
TYPE           ds 1
COUNT          ds 1
;FLAG           ds 1         ;   b7,b6,b5,b4,b3,b2,b1,b0    
;                            ;   b0 up
;                            ;   b1 down
;                            ;   b2 right
;                            ;   b3 left
  ENDS

SWITCH:        equ 239
DIGITS:        equ 240
NNPCS:         equ 31
NRBTS:         equ 2
NBLLTS:        equ NNPCS-NRBTS

cell_len_X:    equ 10
cell_len_Y:    equ 8

vroomsize      equ 64

MPNT:          equ 0C800h
VMPNT:         equ MPNT+vroomsize*32

nodeA_coord:   equ 1*cell_len_X+1*cell_len_Y*vroomsize+MPNT + vroomsize/2
nodeB_coord:   equ 2*cell_len_X+1*cell_len_Y*vroomsize+MPNT + vroomsize/2 + 1
nodeC_coord:   equ 2*cell_len_X+2*cell_len_Y*vroomsize+MPNT + vroomsize/2 + 1
nodeD_coord:   equ 1*cell_len_X+2*cell_len_Y*vroomsize+MPNT + vroomsize/2


MAZEX:   equ 4
MAZEY:   equ 4

