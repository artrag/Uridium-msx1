;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; pop_bullet
; get a bullet request from  the stack
;
; output
; a=color;
; h = dx, l = dy
; ix points to the NPC who casted the bullet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


pop_bullet:
n_req:    ld    a,0
          or    a
          ret   z
          push  af
          xor   a
          ld    (n_req+1),a
bull_dir: ld hl,0
pc_cast:  ld ix,0
          pop   af       ; make sure we have NZ
          ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; push_bullet
; put a bullet request on the stack
;
; input
; a=color;
; h = dx, l = dy
; iy points to the NPC who casted the bullet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


push_bullet:
          ld  (n_req+1),a
          ld  (bull_dir+1),hl
          ld  (pc_cast+2),iy
          call  laser       ; SFX for bullet
          ret


