;;--------------------------------------------------------------------
;; levelPlay
;; 
;; Description:
;;      Play one level
;;--------------------------------------------------------------------
levelPlay:
	    ;;-------------------------------
	    ;; Initialize maze
	    ;;-------------------------------
	    ld      a,(gameLevel)
        call    mazeSetup
        
	    ;;-------------------------------
	    ;; Initialize game song
	    ;;-------------------------------
        ld      hl,game_song
	    call    tm0_setsong
    	
	    ;;-------------------------------
	    ;; Initialize variables
	    ;;-------------------------------
	    ; Calculate time to complete current level
	    ld      a,(gameLevel)
        ld      hl,$2500
        inc     a
        ld      b,a
gameTimeLoop1:
        ld      c,40
        call    bcdSub16
        djnz    gameTimeLoop1
        ld      (gameTime),hl
        
        ; Initialize other variables
        ld      a,7*16
        ld      (gamePosX),a
        ld      (gamePosY),a
        
        xor     a
        ld      (gameDirMask),a
        ld      (gameCharDir),a
        ld      (gameCharacter),a
        
        ; Jump into game loop (skip input first time)
        jp      gameCanMoveAnyDir
        
gameLoop:    
        ; Get user direction (check stick 0 and 1)
        xor     a
	    call    gtstck
        ld      c,a
        ld      a,1
        call    gtstck
        or      c
        ld      b,0
        ld      c,a
        ld      hl,stickDirectionTable
        add     hl,bc
        ld      a,(hl)
        ld      b,a
        and     0x0a
        jr      z,gameNoTurn
        
        ; Calculate whether character points east or west
        and     0x08
        rlca
        rlca
        ld      (gameCharDir),a
gameNoTurn:
    
        ; Check if character is allowed to move in desired direction
        ld      a,(gameDirMask)
        and     b
	    jr      z,gameNoMove
    	
        ; Move character (Move in one direction only, prioritizing
        ; the direction that character didn't move to last time
        ld      b,a
        ld      a,(gameDirPerfer)
        and     1
        jr      z,gamePreferX
        
        call    userMoveX
gamePreferX:
        call    z,userMoveY
        call    z,userMoveX

        ; Update move mask and preferred direction
        ld      a,(gamePosX)
        and     $0f
        jr      z,gameCanMoveHoriz
        ld      a,$0a
        ld      (gameDirMask),a
        ld      (gameDirPerfer),a
        jr      gameMoveUpdateDone
        
gameCanMoveHoriz:
        ld      a,(gamePosY)
        and     $0f
        jr      z,gameCanMoveAnyDir
        ld      a,$05
        ld      (gameDirMask),a
        ld      (gameDirPerfer),a
        jr      gameMoveUpdateDone

gameCanMoveAnyDir:
        ; Increase score
        ld      hl,(gameScore)
        call    bcdInc16
        ld      (gameScore),hl

        ; Get wall info from current cell
        ld      a,(gamePosY)
        and     $f0
        ld      c,a
        ld      a,(gamePosX)
        and     $f0
        rlca
        rlca
        rlca
        rlca
        or      c
        call    mazeCheckWallsIntact
        
        ; Return if we reached outer row of the maze
        ret     nc
        
        ; Save direction mask
        xor     $0f
        ld      (gameDirMask),a

gameMoveUpdateDone:
        ; Update character animaton
        ld      a,(gameCharacter)
        sub     6
        and     $0f
        add     8
        jr      gameDirectionDone
        
gameNoMove:
        ; Reset character animation
        xor     a

gameDirectionDone:
        ld      (gameCharacter),a
        and     0xf8

        ; Draw sprites
        ld      l,a
        ld      a,(gameCharDir)
        add     l
        
        ld      hl,spriteTable+2
        ld      (hl),a
        add     4
        ld      hl,spriteTable+6
        ld      (hl),a
        ld      hl,spriteTable
            
	    ld      bc,$0010
	    ld      de,$1b00
	    call    ldirvm
    	
        ld      a,1
        call    drawStatbar
        ret     c
        
	    ; Play sound
	    call    tm0_interrupt
    	 
        ; Wait for vblank
        di
VblankWaitLoop:
        in      a,($99)
        rlca
        jr      nc,VblankWaitLoop
        call    mazeDraw
        
	    ; Play sound
	    call    tm0_interrupt
        
        ; Wait for vblank
        halt
        
        jp      gameLoop

drawStatbar:
        ld      c,a
        ; Update score. Increase score by one if c is > 1 (time bonus)
        ld      hl,(gameScore)
        cp      1
        jr      z,drawStatbarNoInc
        call    bcdInc16
drawStatbarNoInc:
        ld      (gameScore),hl
	    ld      de,$1800+32*23+0
        call    prnum
        
        ; Update game time    
        ld      hl,(gameTime)
        call    bcdSub16
        ret     c
        ld      (gameTime),hl
	    ld      de,$1800+32*23+28
        call    prnum
        
        ; Update highscore
        ld      hl,(gameHighscore)
	    ld      de,$1800+32*23+7
        call    prnum
        
        ; Update lives
        ld      a,(gameLives)
        add     47
	    ld      de,$1800+32*23+21
	    ex      de,hl
	    call    wrtvrm

        ; Update statbar text
	    ld      de,gameStatbar
	    ld      hl,$1800+32*22+0
	    call    prstr

        ; Update level
	    ld      hl,$1800+32*23+14

        ; Fallthrough


;;--------------------------------------------------------------------
;; levelDrawLevel
;; 
;; Description:
;;      Print level at current location
;;
;;      In:  [a ] - Level to print
;;--------------------------------------------------------------------
levelDrawLevel:
	    ld      a,(gameLevel)
        sra     a
	    sra     a
	    add     49
	    call    wrtvrm
	    inc     hl	
	    ld      a,45
	    call    wrtvrm
	    inc     hl
	    ld      a,(gameLevel)
	    and     3
	    add     49
	    call    wrtvrm
	    inc     hl
        ret

        
;;--------------------------------------------------------------------
;; userMoveX
;; 
;; Description:
;;      Moves gharacter horizontally
;;--------------------------------------------------------------------
userMoveX:
        ld      a,b
        and     $0a
        ret     z
        and     $02
        sub     1
        ld      c,a
        ld      a,(gamePosX)
        add     c
        ld      (gamePosX),a
        ret
    

;;--------------------------------------------------------------------
;; userMoveY
;; 
;; Description:
;;      Moves gharacter vertically
;;--------------------------------------------------------------------
userMoveY:
        ld      a,b
        and     $05
        ret     z
        rlca
        and     $02
        sub     1
        ld      c,a
        ld      a,(gamePosY)
        sub     c
        ld      (gamePosY),a
        ret
    	
