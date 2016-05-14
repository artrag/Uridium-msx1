sign:           and a
                ret z
                jp  m,minus
                ld  a,1
                ret
minus:          ld  a,255
                ret                

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; h = dx, l = dy
; iy points to the NPC who casted the bullet

space:         nop
               ld   a,0xc9              ; ret
               ld   (space),a
               
               ld   a,(iy+NPCS_DATA.DX)
               call sign
               ld   h,a
               
               ld   a,(iy+NPCS_DATA.DY)
               call sign
               ld   l,a

               or   h
               ret  z                   ; fire only if moving

               ld   a,11                ; bullet color 
               jp   push_bullet


roomL:         ld   hl,244
               ld   a,(room_num)
               dec  a
               jr   1F

roomR:         ld   hl,4
               ld   a,(room_num)
               inc  a
1:             ld   (MC.X),hl
               jr   2F
               
roomU:         ld   hl,190-11
               ld   a,(room_num)
               sub  MAZEX
               jr   1F

roomD:         ld   hl,0
               ld   a,(room_num)
               add  a,MAZEX
1:             ld   (MC.Y),hl
2:
               ld   (room_num),a
               ld   l,a
               ld   a,(level)
               ld   h,a
               ld   (seed+1),hl
             
               pop af                    ; remove return address
               jp   next_room            ; generate a new room



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mc_update:
                ld    iy,MC
                
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; move MC
                ld   e,(iy+NPCS_DATA.X)
                ld   d,(iy+NPCS_DATA.Y)
                push de
                call test_x
                pop de
                call test_y

test_action:
; action MC

                ld   a,(kbd)     ; fire 1
                bit  0,a
                push af
                call z,space
                pop  af

                jr   z,1f        ; avoids nultiple bullets with the same pressure
                xor   a
                ld   (space),a
1:

; 8 RIGHT DOWN UP LEFT DEL INS HOME SPACE


; stand
                ld   a,(kbd)     ; no action
                and   128+64+32+16
                cp    128+64+32+16
                call z,stand


                call x_y_update

                ld   hl,(iy+NPCS_DATA.X)

                inc  h
                ld   de,4+256
                rst 20h           ; Flag NC if HL>DE, Flag Z if HL=DE, Flag C if HL<DE
                jr   c,roomL

                ld   de,245+256
                rst 20h           ; Flag NC if HL>DE, Flag Z if HL=DE, Flag C if HL<DE
                jr   nc,roomR

                ld   hl,(iy+NPCS_DATA.Y)

                inc h
                ld   de,-4+256
                rst 20h           ; Flag NC if HL>DE, Flag Z if HL=DE, Flag C if HL<DE
                jr   c,roomU

                ld   de,190-10+256
                rst 20h           ; Flag NC if HL>DE, Flag Z if HL=DE, Flag C if HL<DE
                jr   nc,roomD


                include largespot.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
test_x:        
               ld   a,(kbd)
               bit  7,a
               jr z,right

               bit  4,a
               jp z,left

               ld    hl,MC.DX
               jr inertia


test_y:        ld   a,(kbd)
               bit  6,a
               jr z,down

               bit  5,a
               jr z,up

               ld    hl,MC.DY

inertia:       ld    a,(hl)
               and a
               jp  m,1f
               sra a
               ld (hl),a
               ret

1:             neg
               sra a
               neg
               ld (hl),a
               ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

set_animY:     ld   a,(kbd)
               cpl
               and 16+128
               jp nz,3F 
               ld    a,(DIR)
               and   a
               jp    m,1f
               ld    l,anim_right
               jr    2f
1:             ld    l,anim_left
2:             call set_frame
3:             ld hl,MC.DY
               ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

down:          ld   d,16+3
               call test_up_down
               
               push af
               call set_animY
               pop  af
               jp  nz,stop
               jr 1f

right:         ld   e,8+3
               call  test_left_right

               push  af
               ld    a,1
               ld    l,anim_right
               call  set_animX
               pop   af
               jp    nz,stop


1:             ld  a,2
               cp (hl)
               ret m
               inc (hl)
               ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

up:            ld   d,-1-2
               call test_up_down
               
               push af
               call set_animY
               pop  af
               jp  nz,stop
               jr 1f

left:          ld   e,-1-2
               call test_left_right
               
               push af
               ld    a,-1
               ld    l,anim_left
               call  set_animX
               pop   af
               jp    nz,stop

1:             ld  a,-3
               cp (hl)
               ret p
               dec (hl)
               ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stop:          xor a
               ld  (hl),a
               ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

set_animX:     ld    (DIR),a
               call set_frame
               ld   hl,MC.DX
               ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stand:         ld    a,(DIR)
               and   a
               jp    m,1f
               ld    a,anim_stand_r
               jr    2f
1:             ld    a,anim_stand_l
               jr    2f

set_frame:     ld    a,(MC.COUNT)
               inc   a
               ld    (MC.COUNT),a
               and   3
               add   a,l
2:             ld    (MC.FRAME),a
               ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MC animations
; DIRECTIONS


anim_stand_r:  equ 34
anim_stand_l:  equ 42

anim_right:    equ 30                    ;30,31,32,33
anim_left:     equ 38                    ;38,39,40,41

