;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BULLETS

bullet_fsm:
                ld   b,(iy+NPCS_DATA.STATUS)
                inc  b

99:             djnz 99f
status0_type3:                                  ; silent and waiting  status
                call  pop_bullet
                ret z                           ; ix points to coordinates
                                                ; h = dx, l = dy, a=color,
                ld   (iy+NPCS_DATA.DX),h
                ld   (iy+NPCS_DATA.DY),l

                ld  (iy+NPCS_DATA.CLR),a       ; bullet color

                ld   de,(ix+NPCS_DATA.X)
                ld   a,h
                rlca
                ld   hl,-3
                jr   c,1f

                ld   a,(ix+NPCS_DATA.STATUS)    ; able to detect the MC direction: only MC can have negative status ;-)
                rlca
                jr   c,1f

                ld   hl,9

1:              add  hl,de
                ld  (iy+NPCS_DATA.X),hl

                ld   de,(ix+NPCS_DATA.Y)
                ld   hl,4
                add  hl,de
                ld  (iy+NPCS_DATA.Y),hl

                ld  (iy+NPCS_DATA.FRAME),4     ; bullet shape
                ld  (iy+NPCS_DATA.STATUS),1    ; moving status

                ret

99:             ;djnz 99f
status1_type3:                                  ; moving status

                ld b,6                          ; bullet speed
1:              push bc
                call move_bullet
                pop  bc
                djnz 1B

99:             ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

move_bullet:
                call x_y_update
                jr   NC,1f                      ; bullet offscreen ?

                ld   e,(iy+NPCS_DATA.X)
                ld   d,(iy+NPCS_DATA.Y)
                ld   bc,0
                call get_2tiles
                ret  z                            ; hit a wall

1:              ld   (iy+NPCS_DATA.Y),212         ; disappear
                ld   (iy+NPCS_DATA.STATUS),0      ; go silent and wait
                ret

