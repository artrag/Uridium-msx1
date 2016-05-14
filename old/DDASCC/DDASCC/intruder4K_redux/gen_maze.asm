;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gen_maze:
;
; clear rooms
;
        xor  a
        ld   hl,MPNT-vroomsize
        ld   bc,vroomsize*65
        call FILLRAM
        ld   a,01Ch     ; FOG TILE
        ld   hl,VMPNT
        ld   bc,24*vroomsize
        call FILLRAM

; set goal
        ld   a,(room_num)
endroom:
        cp   0
        jr  nz,nogoalhere

        ld  a,SWITCH    ; Goal tile
        ld  (MPNT+12*vroomsize+48),a

nogoalhere:

        call    buildall
                
        ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rnd3B:  call rand3      ; in {up,right,down}
        jr  backB

rnd3C:  call rand3      ; in {right,down,left}
        inc  a
        jr  backC

rnd3D:  call rand3      ; in {down,left,up}
1:      add  a,2
        jr  backD

rnd3D2: call rand3      ; in {left,up,right}
        inc a
        jr  1b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
buildall:

; DIRECTIONS
;
; 0 wall up
; 1 wall right
; 2 wall down
; 3 wall left
; other: no wall

; process node A

process_nodeA:

        call    rand4       ; nodeA in {up,down,left,right}

        ld  (nodeA+1),a
        ld  hl,nodeA_coord
        call  build_node

process_nodeB:

nodeA:  ld    a,0           ; data stored in the code
        dec   a
        jp    z,rnd3B       ; if (nodeA == right) then nodeB in {up,right,down}
        call  rand4         ; else
                            ; nodeB in {up,down,left,right}

backB:  ld  (nodeB+1),a
        ld  hl,nodeB_coord
        call  build_node

process_nodeC:

nodeB:  ld    a,0
        cp 2
        jp    z,rnd3C       ; if (nodeB == down) then nodeC in {right,down,left}
        call  rand4         ; else
                            ; nodeC in {up,down,left,right}

backC:  ld  (nodeC+1),a
        ld  hl,nodeC_coord
        call  build_node

process_nodeD:

nodeC:  ld    a,0
        cp 3
        jp    z,rnd3D       ; if (nodeC == left) then nodeD in {down,left,up}
        ld    a,(nodeA+1)
        cp 2
        jp    z,rnd3D2      ; if (nodeA == down) then nodeD in {left,up,right}
        call  rand4         ; else
                            ; nodeD in {up,down,left,right}

backD:
        ld  hl,nodeD_coord
        call  build_node

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;     Plot borders
;

        ld    hl,MPNT+vroomsize/2
        ld    de,1
        ld    b,31
        call  wall_loop
        ld    de,vroomsize
        ld    b,23
        call  wall_loop
        ld    de,-1
        ld    b,31
        call  wall_loop
        ld    de,-vroomsize
        ld    b,23
        call  wall_loop

        ld   a,(room_num)
        cp  MAZEX
        jr  c,1F
        
        xor   a
        ld    hl,MPNT+cell_len_X+1+vroomsize/2
        ld    de,1
        ld    b,cell_len_X
        call  2F
1:
        ld   a,(room_num)
        rra
        rra
        inc a
        and (MAZEY-1)
        jr  z,1F

        xor   a
        ld    hl,MPNT+cell_len_X+23*vroomsize+1 +vroomsize/2
        ld    de,1
        ld    b,cell_len_X
        call  2F
1:
        ld   a,(room_num)
        and MAZEX-1
        jr  z,1F

        xor   a
        ld    hl,MPNT+(cell_len_Y+1)*vroomsize+vroomsize/2
        ld    de,vroomsize
        ld    b,cell_len_Y-1
        call  2F

1:
        ld   a,(room_num)
        inc a
        and MAZEX-1
        ret  z

        xor   a
        ld    hl,MPNT+(cell_len_Y+1)*vroomsize+31+vroomsize/2
        ld    de,vroomsize
        ld    b,cell_len_Y-1
        jr  2F

build_node:

        inc a
        ld  b,a
        djnz   1F

        ; 0 wall up
        ld       de,-vroomsize
        jr       5F

1:      djnz   1F

        ; 1 wall right
        ld       de,1
        jr       6F

1:      djnz   1F

        ; 2 wall down
        ld       de,vroomsize
5:      ld       b,cell_len_Y
        jr       wall_loop

1:
        ; 3 wall left

        ld       de,-1
6:      ld       b,cell_len_X+1

wall_loop:
        ld  a,08h; wall tile
2:      ld  (hl),a
        add      hl,de
        djnz     2B
        ret
