
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; draw spot light
;
;

               macro add_bc2hl_de
               add hl,bc
               ex  de,hl           ; source temporary in de, destination temporary in hl
               add hl,bc           ; destination one line down
               ex  de,hl           ; destination in de, source in hl
               endm

               ld   e,(iy+NPCS_DATA.X)
               ld   d,(iy+NPCS_DATA.Y)
               call GET_ADDRESS
               push hl
               ld   bc,-3-2*vroomsize+VMPNT +2+vroomsize/2
               add  hl,bc
               ex   de,hl           ; destination in de

               pop  hl
               ld   bc,-3-2*vroomsize+MPNT +2+vroomsize/2
               add  hl,bc          ; source in hl

               ld   bc,4
               ldir                ; 4 columns

               ld  bc,vroomsize-4-1       ; source & destination one line down
               add_bc2hl_de

               ld   bc,6
               ldir                ; 4 columns

               ld  bc,vroomsize-6-1       ; source & destination one line down
               add_bc2hl_de

               ld   a,4            ; lines

1:             ld   bc,8
               ldir                ; 8 columns
               ld  bc,vroomsize-8         ; source & destination one line down
               add_bc2hl_de
               dec a
               jr nz,1B

               inc de
               inc hl
               ld   bc,6
               ldir                ; 6 columns

               ld  bc,vroomsize-6+1         ; source & destination one line down
               add_bc2hl_de

               ld   bc,4
               ldir                ; 4 columns

               ret


