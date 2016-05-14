
NPC_update:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ld   b,(iy+NPCS_DATA.TYPE)
                inc  b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
99:             djnz 99f
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Slow ROBOT
npc_type0:      jp robot_fsm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
99:             djnz 99f
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Slow ROBOT
npc_type1:      jr   npc_type0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
99:             djnz 99f
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Faster Robot
npc_type2:      call npc_type0
                call npc_type0
                jr   npc_type0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; npc BULLET
99:
npc_type3:      ;jr  bullet_fsm                       ; npc_type unknown

                include        bullet_fsm.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ALIEN ROBOT
;

robot_fsm:
                ld   b,(iy+NPCS_DATA.STATUS)
                inc  b

99:             djnz 99f
status0_type0:                                  ; going up
                ld      d,-1
                call    test_up_down
                jp      nz,change_dir

                dec (iy+NPCS_DATA.COUNT)
                jp z,new_status

                ld    b,26
                jp npc_anim

99:             djnz 99f
status1_type0:                                  ; going down
                ld      d,16
                call    test_up_down
                jp      nz,change_dir

                dec (iy+NPCS_DATA.COUNT)
                jp z,new_status

                ld    b,28
                jp npc_anim

99:             djnz 99f
status2_type0:                                  ; going left
                ld      e,-1
                call    test_left_right
                jp      nz,change_dir

                dec (iy+NPCS_DATA.COUNT)
                jp z,new_status

                ld    b,22
                jp npc_anim

99:             djnz 99f
status3_type0:                                  ; going rigth
                ld      e,8
                call    test_left_right
                jp      nz,change_dir

                dec (iy+NPCS_DATA.COUNT)
                jp z,new_status

                ld    b,24
                jp npc_anim

99:             djnz 99f
status4_type0:                                  ; standing
                dec (iy+NPCS_DATA.COUNT)

                call z,new_status
                                                
                ld a,(iy+NPCS_DATA.STATUS)
                cp 4
                jr nz,1f

                ld  a,(iy+NPCS_DATA.COUNT)
                cp  3                           ; do not cast the bullet if the robot is going to move
                jp  m,1f                        ; it helps to avoid that robots walk on their own bullets
       
                call rand4                      ; 1/4 the prob to fire a bullet
                jr nz,1f

                call rand4
                ld  b,a                         ; bullet direction

                call setdxdy                    ; h = dx, l = dy
                                                ; a!=0 <==> bullet request
                ld   a,8                        ; a = bullet color
                call push_bullet


1:              ld  a,(iy+NPCS_DATA.COUNT)
                and   7
                ld b,14
                jp  npc_anim_exit

99:             djnz 99f
status5_type0:                                  ; expolosion
                dec (iy+NPCS_DATA.COUNT)
                jp z,die

                ld    a,(iy+NPCS_DATA.COUNT)
                rra
                and   3
                ld (iy+NPCS_DATA.FRAME),a
                ret

die:
                ld (iy+NPCS_DATA.Y),212         ; disappear
                ld (iy+NPCS_DATA.STATUS),6
99:             ret                             ; any status >=6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

npc_anim:                                       ; 2 frame animations
                ld      a,(iy+NPCS_DATA.COUNT)
                and     1
npc_anim_exit:                                  ; entry for n frame animations
                add     a,b
                ld      (iy+NPCS_DATA.FRAME),a
                ld      a,(iy+NPCS_DATA.TYPE)
                add     a,2
                ld      (iy+NPCS_DATA.CLR),a
                call    x_y_update              ; update position
                ret     c
                ld      a,(iy+NPCS_DATA.STATUS) ; if offscreen revert direction
                xor     1
                jr      set_status

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

change_dir:     call    rand4                   ; avoid standing
                cp      (iy+NPCS_DATA.STATUS)
                jr      z,change_dir            ; avoid old status
                jr      set_status

new_status:     call    rnd_dir                 ; any new status allowed

set_status:     ld   (iy+NPCS_DATA.STATUS),a
                ld   b,a

                call rand
                and  31
                ld   (iy+NPCS_DATA.COUNT),a

set_dir:                                    ; entry for bullets
                call setdxdy

                ld (iy+NPCS_DATA.DX),h      ; stand
                ld (iy+NPCS_DATA.DY),l
                ret

setdxdy:        ld hl,0                         ; h = dx, l = dy
                inc b
99:             djnz 99f
0:              ld l,-1                         ; goto_up
                ret

99:             djnz 99f
1:              ld l,1                          ; goto_down
                ret

99:             djnz 99f
2:              ld h,-1                         ; goto_left
                ret

99:             djnz 99f
3:              ld h,1                          ; goto_right
99:             ret                             ; stand


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rnd_dir:        call  rand4
                jr    nz,1f

                ld  a,4             ; standing has prob 1/4
                ret

1:              jp rand4            ; any other dir has prob 3/4*1/4=3/8




