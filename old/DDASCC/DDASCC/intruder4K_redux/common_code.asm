;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test screen boundaries
;


x_y_update:

set_x:

; set X
               ld   hl,(iy+NPCS_DATA.X)
               ld   a,(iy+NPCS_DATA.DX)
               call add_hl_a
               ld   (iy+NPCS_DATA.X),hl

               inc  h
               ld   de,-7+256
               rst 20h           ; Flag NC if HL>DE, Flag Z if HL=DE, Flag C if HL<DE
               jr   c,boundx_left

               ld   de,255+256
               rst 20h           ; Flag NC if HL>DE, Flag Z if HL=DE, Flag C if HL<DE
               jr   nc,boundx_right
set_y:

; set Y
               ld   hl,(iy+NPCS_DATA.Y)
               ld   a,(iy+NPCS_DATA.DY)
               call add_hl_a
               ld   (iy+NPCS_DATA.Y),hl

               inc h
               ld   de,-7+256
               rst 20h           ; Flag NC if HL>DE, Flag Z if HL=DE, Flag C if HL<DE
               jr   c,boundy_up

               ld   de,191+256
               rst 20h           ; Flag NC if HL>DE, Flag Z if HL=DE, Flag C if HL<DE

               ret  c            ; NPC not offscreen => we have C

boundx_right:
boundx_left:

boundy_down:
boundy_up:

               xor   a           ; NPC offscreen => we have NC
               ret



;------------------------------------------------------
; Description: Finds the address in PNT of a SC2 pair of coordinates.
; It really works with any buffer with a width of 64 bytes... :)
; Input: D = coord. Y (0-191), E = coord. X (0-255)
; Output: HL = address in buffer
; Modifies: AF,HL
;------------------------------------------------------

GET_ADDRESS:
                ld a,d
                and $F8
                ld h,0
                ld l,a
                add hl,hl
                add hl,hl
                add hl,hl ; (Y/8)*vroomsize (i.e 64)
                ld a,e
                and $F8
                rrca
                rrca
                rrca ; X/8
            
                ld  e,a
                ld  d,0
                add hl,de
                ret

get_3tiles:     ld   bc,vroomsize
                call get_2tiles                
                ret nz
                jr  1f

get_2tiles:     call GET_ADDRESS
                
                ld de,VMPNT+vroomsize/2         ; top left edge of the room
                add hl,de
                ld  a,(hl)                      ; top left edge of the MC
                and a
                ld  (cur_tile0),a
                ret nz

1:              add hl,bc
                ld  a,(hl)                      ; mid left tile of the MC
                and a
                ld  (cur_tile1),a                                
                ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; hl += (signed) a

add_hl_a:
                ld   e,a
                ld   d,0
                and  a
                jp   p,1f
                dec d
1:              add  hl,de
                ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    accepts d as Y offset
;    test the char in direction of DY
;
;
test_up_down:
                ld  a,d
                add a,(iy+NPCS_DATA.Y)
                ld  d,a

                ld  e,(iy+NPCS_DATA.X)
                ld  a,7
                and e

                ld  bc,1
                jr  nz,get_2tiles
                dec bc
                jr  get_2tiles

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    accepts e as X offset
;    test the char in direction of DX
;
;
test_left_right:

                ld  a,e
                add  a,(iy+NPCS_DATA.X)
                ld  e,a

                ld  d,(iy+NPCS_DATA.Y)
                ld  a,7
                and d

                jr  nz,get_3tiles
                ld  bc,vroomsize
                jr  get_2tiles

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;    generate in A a random number from a 16 bit seed
;

rand:
seed:           ld de,0; Seed is usually 0
                ld a,d
                ld h,e
                ld l,253
                or a
                sbc hl,de
                sbc a,0
                sbc hl,de
                ld d,0
                sbc a,d
                ld e,a
                sbc hl,de
                jr nc,1F
                inc hl
1:              ld (seed+1),hl
                ld a,h
                ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; return 0 or 1 or 2 at random

rand3:        call  rand4
              cp  3
              jr  z,rand3
              ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; return 0 or 1 or 2 or 3 at random

rand4:        call  rand
              and 3
              ret
