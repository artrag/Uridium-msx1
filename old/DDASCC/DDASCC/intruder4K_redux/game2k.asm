
                org $9000

                include "definitions.asm"

startProgram:
                ld    hl,0
                ld    (hiscore),hl
              
startProgram2:  
                ld    hl,0
                ld    (score),hl                
                ld    (seed+1),hl
                ld    a,l
                ld    (level),a
                di
                ld    a,0xc9
                ld    (0xfd9f),a
                call    0x90
                ei
                
restart:
                call  INIT               ;initialize screen,sprites and sound
             
                ld    a,(level)
                add   a,NRBTS
                ld    (nrbts),a       ; this will allow variable number of robots
                ld    b,a
                ld    a,NNPCS
                sub   a,b
                ld    (nbllts),a

                ld    ix,MC
                ld    (ix+NPCS_DATA.CLR),15
                ld    (ix+NPCS_DATA.X),24h
                ld    (ix+NPCS_DATA.Y),9ch
                ld    (ix+NPCS_DATA.Xsize),8
                ld    (ix+NPCS_DATA.Ysize),16

                di
                ld    a,(0xfd9f)
                cp    0xc3
                jr    z,1f                ; do not restart the music if it is running
                ld    hl,tm0_interrupt
                ld    (0xfd9f+1),hl
                ld    a,0xc3
                ld    (0xfd9f),a
                call  music_init                
1:              ei


next_room:
                call  gen_maze
                call  npc_init

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Avoid random collision when staring the level 
;

                ld      b,NNPCS+1

                ld      ix,MC
                ld      iy,NPCs

1:              exx

                call    check_collision
                jp      c,next_room

                ld      de,NPCS_DATA
                add     iy,de
                exx
                djnz    1b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                xor a
                ld    (n_req+1),a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; read keys
;
main:
                ld        a,8
                call      0141h
                ld        (kbd),a


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MC update
;
                ld        hl,0
                ld        (cur_tile0),hl

                call      mc_update
                
                
                call      update_statbar
                

                ld        a,(timer)
                and       a
                jp        nz,1f

                ld        hl,(cur_tile0)
                ld        a,h
                cp        SWITCH
                call      z,YouWon                ; hit GOAL

                ld        a,l
                cp        SWITCH
                call      z,YouWon                ; hit GOAL
1:
                ld        a,(timer)
                and       a
                jp        z,1f
                dec       a
                jp        z,restart
                ld       (timer),a

                ld      a,(switch_anim)
                cp      4
                jr      z,1f            ; already animated
                ld      hl,switchoff
                and     3
                add     a,a
                add     a,a
                add     a,a
                ld      c,a
                ld      b,0
                add     hl,bc
                ld      de,0x0000+SWITCH*8
                ld      bc,0x08
                call    ldirvm
                ld  a,(switch_anim)
                inc a
                ld  (switch_anim),a                
                
                
1:                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NPC update
;

                ld        b,NNPCS
                ld        iy,NPCs

1:              push      bc
                call      NPC_update

                ld        de,NPCS_DATA
                add       iy,de
                pop       bc
                djnz      1b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MSAT update

                ld        hl,MSAT
                ld        iy,MC

                ld        b,NNPCS+1

1:              call      update_MSAT

                ld        de,NPCS_DATA
                add       iy,de
                djnz      1b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SAT update

                ld      b,3
1:              push    bc
sfx:            call    no_sfx
                halt
                call    update_SAT
                pop     bc
                djnz    1b
                call    update_PNT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; collision test

; MC collision
                ld      b,NNPCS+1

                ld      ix,MC
                ld      iy,NPCs

1:              exx
                ld      a,(iy+NPCS_DATA.STATUS)      ; do not test against explosions
                cp      5
                jr      z,2f

                ld      a,(iy+NPCS_DATA.CLR)         ; do not test against your own bullets
                cp      11
                jr      z,2f

                call    check_collision
                jp      c,mc_dies

2:
                ld      de,NPCS_DATA
                add     iy,de
                exx
                djnz    1b

; NPC collision

                ld      ix,NPCs                      ; point to bullets
                ld      bc,(nbllts-1)                

1:              push    bc                           ; For   i=NBULLTS:-1:1
                
                ld      bc,(nbllts-1)                
                ld      de,NPCS_DATA
                ld      iy,NPCs
mul:            add     iy,de
                djnz mul                            ;  ld  iy,NPCs+NBLLTS*NPCS_DATA     ; iy point to robots

                ld      bc,(nrbts-1)

2:              push    bc                           ; For   j=NROBOTS:-1:1

                ld      a,(ix+NPCS_DATA.STATUS)      ; do not test inactive bullets
                and     a
                jr      z,next

                ld      a,(iy+NPCS_DATA.STATUS)      ; do not test exploding robots
                cp      5
                jr      z,next

                call    check_collision
                jp      nc,next

                ld      hl,(score)
                ld      de,65
                add     hl,de
                ld     (score),hl
                
                ld      (iy+NPCS_DATA.COUNT),8
                ld      (iy+NPCS_DATA.STATUS),5      ; robot explodes
                ld      (iy+NPCS_DATA.CLR),8         ; color of the explosion
                ld      a,(iy+NPCS_DATA.X)
                sub     4
                ld      (iy+NPCS_DATA.X),a

                ld      (ix+NPCS_DATA.Y),212
                ld      (ix+NPCS_DATA.STATUS),0      ; bullet disappears
                call    explode                      ; SFX

next:
                ld      de,NPCS_DATA
                add     iy,de
                pop     bc
                djnz    2b                           ; Next  j

                add     ix,de
                pop     bc
                djnz    1b                           ; Next  i

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; repeat the main loop
;
                jp      main
                



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; update MSAT
;


update_MSAT:
                ld   a,(iy+NPCS_DATA.Y)
                dec  a
                ld   (hl),a    ; Y
                inc  hl

                ld   c,0
                ld   a,(iy+NPCS_DATA.X)
                bit  7,(iy+NPCS_DATA.X+1)
                jr   z,1f
                add  a,32
                ld   c,128     ; EC bit
1:              ld   (hl),a    ; X
                inc   hl

                ld    a,(iy+NPCS_DATA.FRAME)
                add   a,a
                add   a,a
                ld    (hl),a    ; shape
                inc   hl

                ld   a,(iy+NPCS_DATA.CLR)
                or   c
                ld   (hl),a    ; color
                inc  hl

no_sfx:         ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; update SAT
;

                include satupd.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; update PNT
;
update_PNT:
                ld    hl,PNT
                call  setwrt
                ld    hl,VMPNT+vroomsize/2
                ld    de,vroomsize-32
                ld    a,24
1:              ld    bc,32*256+98h
                otir
                add   hl,de
                dec   a
                jr nz,1B
                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NPC update
;

                include "npc_update.asm"

                include "stack.asm"
                include "npc_init.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;

                include "collision.asm"
                include "common_code.asm"

                include "music.asm"
                include "gen_maze.asm"
                include "init.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MC update
;
                include "mc_update.asm"

mc_dies:
                ld     b,50
                call    explode                      ; SFX
1:              push   bc

                call   rand
                ld     b,a
                ld     c,7
                call   wrtvdp                        ; cycle colors
                halt
                call   explode_loop
                pop    bc
                djnz   1b
                jp      startProgram2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

YouWon:
                ld      hl,(score)
                ld      bc,895
                add     hl,bc
                ld      (score),hl
                
                call    shutdown                     ; SFX
                
; Disable all bullets

                ld      iy,NPCs                      ; point to bullets
                ld      bc,(nbllts-1)
1:
                ld      (iy+NPCS_DATA.Y),212
                ld      (iy+NPCS_DATA.STATUS),0      ; bullet disappears
                ld      de,NPCS_DATA
                add     iy,de
                djnz    1b                           


; Kill all robots 

                                                    ; iy points already to robots by previous loop
                ld      bc,(nrbts-1)
2:                                                    ; For   j=NROBOTS:-1:1
                ld      (iy+NPCS_DATA.COUNT),8
                ld      (iy+NPCS_DATA.STATUS),5      ; robot explodes
                ld      (iy+NPCS_DATA.CLR),8         ; color of the explosion
                ld      a,(iy+NPCS_DATA.X)
                sub     4
                ld      (iy+NPCS_DATA.X),a

                ld      de,NPCS_DATA
                add     iy,de
                djnz    2b                           ; Next  j

                
; Activate timer to end level
                
                ld  a,30
                ld  (timer),a

                ld    a,(level)
                or    a
                jr    nz,3f
                inc   a
3:
                inc    a
                ld    (level),a
                ld    (seed+1),a
                ld    (seed+2),a
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print the Level complete message
;
                ld    de,VMPNT+7*vroomsize+48-8
                ld    hl,message
                ld    c,15                              ; b is already 0 by previous loops
                ldir
                ld    de,MPNT+7*vroomsize+48-8
                ld    hl,message
                ld    c,15
                ldir

                xor a
                ld  hl,VMPNT+6*vroomsize+48-8
                ld  c,15-1                
                call FILLRAM
                ld  hl,MPNT+6*vroomsize+48-8
                ld  c,15-1
                call FILLRAM

                ld  hl,VMPNT+8*vroomsize+48-8
                ld  c,15-1
                call FILLRAM
                ld  hl,MPNT+8*vroomsize+48-8
                ld  c,15-1
                call FILLRAM

                ret
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Print the Level complete message
;
update_statbar:
        ld      a,(room_num)
        ld      l,a
        ld      de,MPNT+64*23+32
        call    Num2asc

        ld      a,(room_num)
        ld      l,a
        ld      de,VMPNT+64*23+32
        call    Num2asc

        ld      a,(endroom+1)
        ld      l,a
        ld      de,MPNT+64*23+59
        call    Num2asc

        ld      a,(endroom+1)
        ld      l,a
        ld      de,VMPNT+64*23+59
        call    Num2asc
        
        ld      hl,(score)
        ex      de,hl
        ld      hl,(hiscore)
        sbc     hl,de
        jr      nc,nohi
        ex      de,hl
        ld      (hiscore),hl
nohi:        
        
        ld      de,MPNT+32
        ld      hl,(score)
        call    xNum2ascPts
        ld      de,VMPNT+32
        ld      hl,(score)
        call    xNum2ascPts
        
        ld      de,MPNT+54
        ld      hl,(hiscore)
        call    xNum2ascHi
        ld      de,VMPNT+54
        ld      hl,(hiscore)
        call    xNum2ascHi
        
        ret

xNum2ascPts:
            ld  a,8
            ld  (de),a
            inc de
            ld  a,$fd
            ld  (de),a
            inc de
            ld  a,$ff
            ld  (de),a
            inc de
            ld  a,$fe
            ld  (de),a
            inc de
            jr  xNum2asc

xNum2ascHi:
            ld  a,8
            ld  (de),a
            inc de
            ld  a,$fa
            ld  (de),a
            inc de
            ld  a,$fb
            ld  (de),a
            inc de
xNum2asc:
            ld  a,8
            ld  (de),a
            inc de
            ld  bc,-10000
            call    xNum1
            ld  bc,-1000
            call    xNum1
            ld  bc,-100
            call    xNum1
            ld  bc,-10
            call    xNum1
            ld  c,-1
            call    xNum1
            ld  a,8
            ld  (de),a
            ret

xNum1:       
            ld  a,$f0-1  ; '0' in the tileset

xNum2:      
            inc a
            add hl,bc
            jr  c,xNum2
            sbc hl,bc
        
            ld  (de),a
            inc de
            ret


	
                
message:                
                dm " LEVEL CLEARED "                

hiscore:        ds    2
score:          ds    2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; data to not reset at each level change
;
level:          ds    1
channel_data:   ds    15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

endProgram:             ; data to be reset at each play

kbd:            ds    1
room_num:       ds    1
cur_tile0:      ds    1
cur_tile1:      ds    1
timer:          ds    1  
switch_anim:    ds    1 

nrbts:          ds    1
nbllts:         ds    1

MSAT:           ds    128

MC:             NPCS_DATA
NPCs:           ds 31*NPCS_DATA

DIR             equ MC.STATUS


endData:



    END


