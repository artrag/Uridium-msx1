;; -------------------------------------------------------------------
;; Mazegen
;; -------------------------------------------------------------------

;; The maze is hard coded to be 16x16 to make calculations easier
;; and minimize code footprint. 14x14 cells are used for the actual
;; maze and the outer row of cells only serves as the boundary wall

;; Maze data contains a bitmask for each cell in the maze.
;; A zero bit means that there is a wall in that direction:
;;   bit 3: West
;;   bit 2: South
;;   bit 1: East
;;   bit 0: North

dir_N: equ $01
dir_E: equ $02
dir_S: equ $04
dir_W: equ $08

;;--------------------------------------------------------------------
;; mazeCheckWallsIntact
;; 
;; Description:
;;      Checks if a cell has all walls intact
;;
;;      In:  [a ]  - Cell to check
;;      Out: [a  ] - wall bitmap
;;           z flag  set if all walls are intact
;;           c flag  set if cell is border
;;--------------------------------------------------------------------
mazeCheckWallsIntact:
        push    bc
        ld      b,0
        ld      c,a
        ld      hl,mazeData
        add     hl,bc
        pop     bc
        ld      a,(hl)
        cp      $0f
        ret


;;--------------------------------------------------------------------
;; mazeKnockDownWall
;; 
;; Description:
;;      Knocks down a wall
;;
;;      In:  [a ]  - Cell to knock down a wall at
;;           [b ]  - Wall to knock down
;;--------------------------------------------------------------------
mazeKnockDownWall:
        call    mazeCheckWallsIntact
        ld      a,b
        cpl
        and     (hl)
        ld      (hl),a
        ret
   
   
;;--------------------------------------------------------------------
;; mazeFindNeighbour
;; 
;; Description:
;;      Finds a neighbour cell
;;
;;      In:  [a ]  - Cell to find neighbour to
;;           [b ]  - Direction to neighbour
;;      Out: [a ]  - Neighbouring cell
;;           [b ]  - Direction to original cell
;;--------------------------------------------------------------------
mazeFindNeighbour:
        sra     b
        jr      nz,mazeNotNorth
        ;; Neighbour cell is north of current cell, 
        ld      b,4
        sub     16
        ret
mazeNotNorth:
        sra     b
        jr      nz,mazeNotEast
        ;; Neighbour cell is east of current cell, 
        ld      b,8
        inc     a
        ret
mazeNotEast:
        sra     b
        jr      nz,mazeNotSouth
        ;; Neighbour cell is south of current cell, 
        ld      b,1
        add     a,16
        ret
mazeNotSouth:
        ;; Neighbour cell is west of current cell, 
        ld      b,2
        dec     a
        ret


;;--------------------------------------------------------------------
;; mazeGenerate
;; 
;; Description:
;;      Generate a random 14x14 maze with outer walls
;;--------------------------------------------------------------------
mazeGenerate:
        ld      (mazeSP),sp
        
        ld      hl,$d000
        ld      sp,hl
        
        ;; Clear maze
        
        ; Maze is 16x16 cells with pre defined walls so
        ; actual generated part of maze is 14x14 cells.
        
        ld      de,mazeData
        ld      hl,mazeClearData
        ld      bc,256
        ldir
        
        ;; Set up initial state for maze generation
        ld      a,14 * 14 - 1
        ld      (mazeNotVisited),a
        
        call    rand8
        and     $77
        add     $44
        ld      (mazeCurrent),a
    
mazeGenLoop:
        ; find all neighbors of current cell with all walls intact
        
        ld      d,0

        ;; Check west neighbor
        ld      a,(mazeCurrent)
        dec     a
        call    mazeCheckWallsIntact
        jr      nz,mazeWallsNotIntact
        inc     d
mazeWallsNotIntact:
        sla     d
        
        ;; Check south neighbor
        ld      a,(mazeCurrent)
        add     a,16
        call    mazeCheckWallsIntact
        jr      nz,mazeL3
        inc     d
mazeL3:
        sla     d

        ;; Check east neighbor
        ld      a,(mazeCurrent)
        inc     a
        call    mazeCheckWallsIntact
        jr      nz,mazeL2
        inc     d
mazeL2:
        sla     d
        
        ;; Check north neighbor
        ld      a,(mazeCurrent)
        sub     16
        call    mazeCheckWallsIntact
        jr      nz,mazeL1
        inc     d
mazeL1:

        ; check if intact cells are found d == 0
        ld      a,d
        and     a
        jr      nz,mazeL5
        
        ; none found, pop the most recent cell entry off the cell stack 
        pop     af
        ld      (mazeCurrent),a
        jr      mazeGenLoop

mazeL5:
        ; choose one found neigbour at random
        call    rand8
        and     3
        ld      b,1
        jr      z,mazeL6b
mazeL6a:
        sla     b
        dec     a
        jr      nz,mazeL6a
mazeL6b:
        ld      a,d
        and     b
        jr      z,mazeL5
        
        ; Neigbour found, knock down walls between current and neigbour
        ld      a,(mazeCurrent)
        ; push current cell location on the stack 
        push    af
        call    mazeKnockDownWall
        
        ; Find neighbour
        ld      a,(mazeCurrent)
        call    mazeFindNeighbour
        
        ; Set the neighbour as the current cell
        ld      (mazeCurrent),a
        call    mazeKnockDownWall
        
        ; Decrease number of not visited cells
        ld      a,(mazeNotVisited)
        dec     a
        ld      (mazeNotVisited),a
        
        jr      nz,mazeGenLoop
        
mazeL9:
        ; Create opening in the outer maze wall
        call    rand8
        ld      c,a
        add     $11
        ld      b,a
        and     $e0
        jr      z,potentialExit
        ld      a,b
        and     $0e
        jr      nz,mazeL9
potentialExit:
        ld      a,c
        call    mazeCheckWallsIntact
        and     $0f
        jr      z,mazeL9
        ld      b,a
        ld      a,c
        call    mazeKnockDownWall
        ld      a,c
        call    mazeFindNeighbour
        call    mazeKnockDownWall

        ; Restore stack pointer
        ld      sp,(mazeSP)
        
        ret
        

;;--------------------------------------------------------------------
;; mazeDraw
;; 
;; Description:
;;      Draws the maze at location (e,d)
;;
;;      In: [d ] y coordinate, valid range 0 - 255
;;          [ e] x coordinate, valid range 0 - 255
;;--------------------------------------------------------------------
mazeDraw:
        ld      a,(gamePosX)
        ld      e,a
        ld      a,(gamePosY)
        ld      d,a

        ; Set horizontal / vertical scroll
        ld      b,0
        and     3
        jr      z,mazeL31
        inc     b
mazeL31:

        ; Save scroll offset
        ld      a,e
        or      d
        and     3
        rrca
        rrca
        rrca
        or      $80
        ld      (mazeScroll),a
        
        ; Calculate top left corner of display
        ld      a,d
        rrca
        rrca
        and     $3f
        sub     9
        ld      d,a
        
        ld      a,e
        rrca
        rrca
        and     $3f
        sub     14
        ld      e,a
        
        ; Select tile bank in vram (b = page to set)
        ld      c,4
        call    wrtvdp
        
        ; Setup vram write pointer
        ld      hl,0x1800
        call    setwrt
        
        ; Calculate maze Map pointer to tile that will be 
        ; displayed in the top left corner of the display
        ld      h,0
        ld      l,d
        bit     7,d
        jr      z,noNegD
        dec     h
noNegD:
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        ld      b,0
        ld      c,e
        bit     7,e
        jr      z,noNegE
        dec     b
noNegE:
        add     hl,bc
        ld      bc,mazeMap
        add     hl,bc

        ; Blit the display
        ld      b,22
mazeRowLoop:
        push    bc
        push    de
        
        ld      a,d
        and     $c0
        ld      b,32
        ld      a,(mazeScroll)
        jr      z,mazeRowOnMap
mazeColLoop1:
        out     ($98),a
        inc     hl
        inc     e
        djnz    mazeColLoop1
        jr      mazeRowDone

mazeRowOnMap:
        ld      d,a
mazeColLoop2:
        ld      a,d
        bit     6,e
        jr      nz,mazeColDone
        or      (hl)
mazeColDone:
        out     ($98),a
        inc     hl
        inc     e
        djnz    mazeColLoop2
    
mazeRowDone:
        ld      bc,32
        add     hl,bc
        
        pop     de
        inc     d
        
        pop     bc
        djnz    mazeRowLoop    
        ret
        

;;--------------------------------------------------------------------
;; blitTile
;; 
;; Description:
;;      Blits one tile/character of a maze cell.
;;
;;      In:  [b ]  - mask to check
;;           [d ]  - value if not bit set
;;           [ e]  - value if bit set
;;           [hl]  - Pointer to bgmap where to blit to
;;--------------------------------------------------------------------
blitTile:
        ld      c,a
        and     b
        jr      z,blitOther
        ld      d,e
blitOther:
        ld      (hl),d
        inc     hl
        ld      a,c
        ret

    
;;--------------------------------------------------------------------
;; blitCell
;; 
;; Description:
;;      Blits one maze cell onto the bgamp (4x4 characters)
;;
;;      In:  [a ]  - Cell to blit
;;           [hl]  - Pointer to bgmap where to blit to
;;--------------------------------------------------------------------
blitCell:
        push    bc
        push    de
        
        ; First row
        bit     3,a
        jr      nz,topLeftWest
        ld      de,$0102
        ld      b,dir_N
        call    blitTile
        jr      topLeftDone
topLeftWest:
        ld      de,$0304
        ld      b,dir_N
        call    blitTile
topLeftDone:

        ld      de,$0005
        ld      b,dir_N
        call    blitTile
        
        ld      de,$0607
        ld      b,dir_N
        call    blitTile
        
        ld      de,$0809
        ld      b,dir_E
        call    blitTile

        ld      de,64-4
        add     hl,de
        
        ; Second row
        ld      de,$000a
        ld      b,dir_W
        call    blitTile
        
        ld      de,$0000
        ld      b,0
        call    blitTile
        
        ld      de,$0000
        ld      b,0
        call    blitTile
        
        ld      de,$000b
        ld      b,dir_E
        call    blitTile

        ld      de,64-4
        add     hl,de

        ; Third row
        ld      de,$0c0d
        ld      b,dir_W
        call    blitTile
        
        ld      de,$0000
        ld      b,0
        call    blitTile
        
        ld      de,$0e00
        ld      b,0
        call    blitTile
        
        ld      de,$0f10
        ld      b,dir_E
        call    blitTile

        ld      de,64-4
        add     hl,de

        ; Fourth row
        ld      de,$1112
        ld      b,dir_S
        call    blitTile
        
        ld      de,$0013
        ld      b,dir_S
        call    blitTile
        
        ld      de,$1415
        ld      b,dir_S
        call    blitTile
        
        ld      de,$1600
        ld      b,0
        call    blitTile

        ld      de,64-4-(256-4)
        add     hl,de
        
        pop     de
        pop     bc
        
        ret
        
    
;;--------------------------------------------------------------------
;; mazeSetup
;; 
;; Description:
;;      Initializes the maze
;;
;;      In: [a ] game level
;;--------------------------------------------------------------------
mazeSetup:   
        ld      b,0 
        ld      c,a
        
        add     $81
        ld      (randSeed),a
        ld      (randSeed+1),a
        
        sra     c
        sra     c
        ld      hl,mazeColors
        add     hl,bc
        ld      a,(hl)
        ld      hl,$2010
   	    ld      bc,$0010
   	    call    filvrm
       	
        call    mazeGenerate
        ; Fallthrough


;;--------------------------------------------------------------------
;; mazeCreateBgmap
;; 
;; Description:
;;      Creates the maze bitmap
;;--------------------------------------------------------------------
mazeCreateBgmap:
        ld      de,mazeData
        ld      hl,mazeMap
      
        ld      b,16
mazeCreateY:
        push    bc
        ld      b,16
mazeCreateX:
        ld      a,(de)
        inc     de
        call    blitCell
        djnz    mazeCreateX
        
        ld      bc,64*3
        add     hl,bc
        
        pop     bc
        djnz    mazeCreateY
        
        ; Clear edges of map
        ld      hl,mazeMap
        ld      de,mazeMap+62*64
        ld      a,$80
        ld      b,a
mazeL20:
        ld      (hl),a
        ldi
        djnz    mazeL20

        ld      hl,mazeMap
        ld      de,62
        ld      b,64
mazeL21:
        ld      (hl),a
        add     hl,de
        ld      (hl),a
        inc     hl
        ld      (hl),a
        inc     hl
        djnz    mazeL21
        ret
