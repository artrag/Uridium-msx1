;; -------------------------------------------------------------------
;; Maze game
;;
;; The game starts at CC00h, but it will reuse some of that RAM
;; once the code has been used. C000h-CFFFh will be used as
;; temporary RAM for muliple purposes, so once game initialization
;; is done, the first 300h of game data will be reused.
;; -------------------------------------------------------------------

        output "game.bin"

	    org     $cc00

gameSprites:
        db $00,$00,$0c,$1e,$16,$04,$70,$3c,$03,$07,$0e,$0c,$0f,$07,$00,$03
        db $00,$00,$00,$00,$00,$00,$00,$00,$80,$00,$00,$40,$c0,$c0,$e0,$f0
        db $07,$0f,$03,$01,$09,$1b,$0f,$03,$00,$00,$01,$03,$00,$00,$00,$00
        db $00,$80,$c0,$e0,$e0,$e0,$e0,$f0,$78,$fc,$fd,$be,$3c,$30,$00,$00
        db $00,$06,$0f,$0b,$03,$3c,$1c,$07,$0e,$1e,$1c,$18,$c8,$ff,$70,$31
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$e0,$c0,$60,$f0
        db $03,$01,$00,$04,$0c,$03,$03,$00,$01,$01,$03,$07,$07,$00,$00,$00
        db $80,$c0,$e0,$e0,$e0,$e0,$e0,$f0,$f8,$f8,$fc,$fe,$1c,$30,$00,$00
        db $00,$0c,$1e,$16,$06,$78,$38,$06,$0f,$1f,$1f,$1f,$0f,$03,$0f,$1f
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$cc,$6c,$38,$70
        db $07,$03,$01,$09,$19,$07,$07,$01,$10,$20,$60,$e0,$00,$00,$00,$00
        db $80,$c0,$e0,$e0,$e0,$e0,$e0,$f0,$f8,$fc,$fe,$7e,$32,$10,$00,$00

mazeTiles:
        db $00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00
        db $50,$b0,$52,$b0,$e0,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00
        db $50,$b0,$52,$b0,$e0,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$7c,$40,$54,$5c,$7c,$7c,$28,$14
        db $50,$b0,$52,$b0,$e0,$00,$22,$00,$00,$fc,$86,$bd,$9e,$bd,$9e,$00,$00,$00,$22,$00,$00,$00,$22,$00
        db $50,$b0,$52,$b0,$e0,$00,$22,$00,$00,$fc,$86,$bd,$9e,$bd,$9e,$00,$7e,$40,$54,$5e,$7e,$7e,$2a,$14
        db $7f,$40,$55,$5f,$7f,$7f,$2a,$15,$00,$00,$22,$00,$00,$00,$22,$00,$fe,$00,$54,$fe,$fe,$fe,$aa,$54
        db $00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$04,$04,$24,$04,$02,$00,$22,$00
        db $ff,$01,$55,$ff,$ff,$ff,$aa,$55,$00,$00,$22,$00,$00,$00,$22,$00,$04,$04,$24,$04,$02,$00,$22,$00
        db $05,$04,$25,$04,$03,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$50,$b0,$52,$b0,$e0,$00,$22,$00
        db $05,$04,$25,$04,$03,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$50,$b0,$52,$b0,$e0,$00,$22,$00
        db $00,$fc,$86,$bd,$9e,$bd,$9e,$bd,$9e,$bd,$9e,$bd,$9e,$bd,$9e,$00,$00,$00,$22,$00,$00,$00,$22,$00
        db $00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$fc,$84,$bc,$9c,$bc,$9c,$bc
        db $00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$e0,$10,$52,$00,$00,$00,$22,$00,$00,$00,$22,$00
        db $9e,$bd,$9e,$bd,$9e,$bd,$9e,$fd,$00,$00,$22,$00,$e0,$10,$52,$00,$00,$00,$22,$00,$00,$00,$22,$00
        db $00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00
        db $00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$03,$04,$25,$00,$00,$00,$22,$00,$00,$00,$22,$00
        db $00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$03,$04,$25,$00,$9e,$bc,$9e,$bc,$9e,$bc,$9e,$fc
        db $00,$00,$22,$00,$e0,$10,$52,$b0,$50,$b0,$52,$b0,$e0,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00
        db $00,$00,$22,$00,$e0,$10,$52,$b0,$50,$b0,$52,$b0,$e0,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00
        db $00,$00,$22,$00,$00,$00,$22,$00,$7f,$40,$55,$5f,$7f,$7f,$2a,$00,$00,$00,$22,$00,$00,$00,$22,$00
        db $00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$00,$00,$22,$00,$02,$04,$24,$04
        db $00,$00,$22,$00,$00,$00,$22,$00,$ff,$01,$55,$ff,$ff,$ff,$aa,$00,$00,$00,$22,$00,$02,$04,$24,$04
        db $00,$00,$22,$00,$03,$04,$25,$04,$05,$04,$25,$04,$03,$00,$22,$00,$00,$00,$22,$00,$e0,$10,$52,$b0

textColors:
        db  $e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0
   

;;--------------------------------------------------------------------
;; gameTilesCopyOne
;; 
;; Description:
;;      Render one game tile and copies it to VRAM
;;
;;      In: [hl] Tile data
;;          [a ] Right rotation
;;--------------------------------------------------------------------
gameTilesCopyOne:
        push    bc
        push    de
        ld      b,8
        push    hl
        pop     ix
    
mazeCpLoop:
        ld      d,(ix+0)
        ld      e,(ix+16)
        
        push    af
    
mazeShiftLoop:  
        and     a
        jr      z,mazeShiftDone
        sla     e
        rl      d
        dec     a
        jr      mazeShiftLoop
        
mazeShiftDone:
        ld      a,d
        out     ($98),a
        
        pop     af
        inc     ix
        djnz    mazeCpLoop
        pop     de
        pop     bc
        ret

;--------------------------------------------
;; main
;; 
;; Description:
;;      Main game routine
;--------------------------------------------
main:
	    ; Set screen 1
	    xor     a
	    ld      (bakclr+1),a
	    call    erafnk
        call    init32
    	
	    ; Set big sprites
	    ld      bc,$e201
	    call    wrtvdp

	    ;; ----------------------------
	    ;; Create bold font
	    ;; ----------------------------
	    ld      bc,$0400
	    ld      de,mazeMap
	    ld      hl,$0000
	    call    ldirmv

	    ld      hl,mazeMap
	    ld      b,$0
_blod_font_loop:

	    ld      a,(hl)
	    rrca
	    or      (hl)
	    ld      (hl),a
        inc     hl
	    ld      c,a
    	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    or      c
	    ld      (hl),a
	    inc     hl
    	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    ld      (hl),a
	    inc     hl
    	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    ld      (hl),a
	    inc     hl
    	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    ld      (hl),a
	    inc     hl

	    inc     hl
    	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    ld      (hl),a
	    dec     hl
        ld      c,a
    	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    or      c
	    ld      (hl),a
	    inc     hl
    	
	    inc     hl
    	
	    xor     a
	    ld      (hl),a	
	    inc     hl
    	
        djnz    _blod_font_loop
        
	    ld      de,$0001
	    ld      hl,mazeMap
	    ld      bc,$0800
	    call    ldirvm
        
	    ld      de,$0801
	    ld      hl,mazeMap
	    ld      bc,$0800
	    call    ldirvm
    	
	    ;; ----------------------------
        ;; Unpack and load game tiles into VRAM
        ;; ----------------------------
        ld      de,$0400
        ld      hl,mazeTiles
        ld      b,4
        xor     a

mazeTilesL1:
        ex      de,hl
        push    af
        call    setwrt
        pop     af
        ex      de,hl
        
        push    bc
        push    hl
        ld      b,23
mazeTilesL2:
        push    bc
        call    gameTilesCopyOne      
        ld      bc,24
        add     hl,bc
        pop     bc
        djnz    mazeTilesL2
        pop     hl
        inc     a
        inc     a
        ex      de,hl
        ld      bc,32*8
        add     hl,bc
        ex      de,hl
        pop     bc
        djnz    mazeTilesL1
        
        ld      de,$0c00
        ld      hl,mazeTiles
        ld      b,4
        xor     a

mazeTilesL3:
        ex      de,hl
        push    af
        call    setwrt
        pop     af
        ex      de,hl
        
        push    bc
        push    hl
        ld      b,23
mazeTilesL4:
        push    bc
        call    gameTilesCopyOne      
        ld      bc,24
        add     hl,bc
        pop     bc
        djnz    mazeTilesL4
        pop     hl
        inc     hl
        inc     hl
        ex      de,hl
        ld      bc,32*8
        add     hl,bc
        ex      de,hl
        pop     bc
        djnz    mazeTilesL3


        ;--------------------------
        ; Load game sprites
        ;--------------------------
	    ; Mirror sprites
	    ld      hl,gameSprites
	    ld      de,gameSprites - $100
	    ld      b,0
spriteLoop:
        ld      a,l
        xor     $10
        ld      l,a
        
        rrc     (hl)
        rl      a
        rrc     (hl)
        rl      a
        rrc     (hl)
        rl      a
        rrc     (hl)
        rl      a
        rrc     (hl)
        rl      a
        rrc     (hl)
        rl      a
        rrc     (hl)
        rl      a
        rrc     (hl)
        rl      a
        
        ld      (de),a
        
        ld      a,l
        xor     $10
        ld      l,a
        
        inc     de
        inc     hl
        djnz    spriteLoop
        
        ; Upload sprites to VRAM
        ld      hl,gameSprites - $100
	    ld      de,$3800
	    ld      bc,$800
	    call    ldirvm
    	
        ;--------------------------
        ; Load text colors
        ;--------------------------
	    ld      hl,textColors
	    ld      de,$2000
	    ld      bc,$800
	    call    ldirvm
        
        ; Initialize game variables
        ld      hl,0
        ld      (gameHighscore),hl
    
titleScreen:
        call    showTitle

        ; Exit game and set secreen 0 if exit was selected
        ld      a,(gameMenu)
        and     $1f
        jp      z,initxt
        
        ; Initialize game variables
        ld      hl,0
        ld      (gameScore),hl
        ld      (gameLevel),hl
        
        ld      a,4
        ld      (gameLives),a
        
gamePlay:
	    xor     a
        call    cls

	    ld      de,mazeLevel
	    ld      hl,$1800+32*11+11
	    call    prstr
	    inc     hl
	    call    levelDrawLevel
    	
	    call    delay
    	
	    call    levelPlay
	    jr      c,gameTimeUp

	    call    tm0_mute

        ; Add bonus for time not spent
gameAddTimeLoop:
        ld      a,8
        call    drawStatbar
        jr      nc,gameAddTimeLoop

        ; Clear screen and hide sprites
	    xor     a
	    call    cls
	    ld      a,208
	    ld      hl,$1b00
	    call    wrtvrm

        ; Display Level completed
	    ld      de,gameCompleted
	    ld      hl,$1800+32*11+6
	    call    prstr
	    ld      hl,$1800+32*11+12
	    call    levelDrawLevel
	    call    delay

        ; Move to next level
        ld      a,(gameLevel)
        inc     a
        ld      (gameLevel),a

        jr      gamePlay
        
	    ; If times up, reduce number of lives and
	    ; quit game if no more lives
gameTimeUp:
	    call    tm0_mute

        ; Clear screen and hide sprites
	    xor     a
	    call    cls
	    ld      a,208
	    ld      hl,$1b00
	    call    wrtvrm

        ; Display times up
	    ld      de,gameTimesUp
	    ld      hl,$1800+32*11+11
	    call    prstr
	    call    delay
    	
	    ; Reduce number of lives
        ld      a,(gameLives)
        dec     a
        ld      (gameLives),a
        
        ; If still lives left, continue play
        jp      nz,gamePlay
        
        ; If no lives left, show game over
	    ld      de,gameOver
	    ld      hl,$1800+32*11+11
	    call    prstr
	    call    delay

        ; Check if new hig score
        ld      hl,(gameHighscore)
        ld      de,(gameScore)
        sbc     hl,de
        jr      nc,NoHighscore
        ld      (gameHighscore),de
NoHighscore:

        ; Return to title screen
        jp      titleScreen

    
;;--------------------------------------------------------------------
;; showTitle
;; 
;; Description:
;;      Shows the tile menu
;;--------------------------------------------------------------------
showTitle:
        xor     a
        call    cls
    	
        ld      a,$3e
        ld      (gameMenu),a
	
showTitleLoop:
	    ld      de,titleTextDJ
	    ld      hl,$1800+32*23+5
	    call    prstr
	
        ld      hl,$1800+32*5+5
        call    prstr
    
	    ld      a,(gameMenu)
	    ld      hl,$1800+32*13+11
	    call    wrtvrm
	    inc     hl
	    inc     hl
	    call    prstr
    
	    ld      a,(gameMenu)
	    xor     $1e
	    ld      hl,$1800+32*15+11
	    call    wrtvrm
	    inc     hl
	    inc     hl
	    call    prstr
    	
	    xor     a
	    call    gttrig
	    and     a
	    ret     nz
    	
	    inc     a
	    call    gttrig
	    and     a
	    ret     nz

        xor     a
	    call    gtstck
	    ld      c,a
	    ld      a,1
	    call    gtstck
	    or      c
	    jr      z,showTitleLoop
    	
	    and     4
	    ld      a,$3e
	    jr      z,menuDown
	    xor     $1e
menuDown:
        ld      (gameMenu),a
    	
	    jr      showTitleLoop
    	    

;;--------------------------------------------------------------------
;; Includes
;;--------------------------------------------------------------------
	    include "level.asm"
	    include "mazegen.asm"
	    include "crumbs.asm"
XXXX1:
	    include "tm0player.asm"
XXXX2:
	    include "gamesong.asm"


;;--------------------------------------------------------------------
;; Data
;;--------------------------------------------------------------------
gameTimesUp:
        db "TIME'S UP!",0

gameOver:
        db "GAME OVER!",0
        
mazeLevel:
        db "LEVEL",0
        
gameCompleted:
        db "LEVEL     COMPLETED!",0

gameStatbar:
        db  "SCORE  HIGH   LEVEL  LIVES  TIME",0
        
titleTextDJ:
        db "(c) 2008 DVIK&JOYREX",0

titleTextMaze:
        db "-: M.A.Z.E  2KBOS :-",0
        
menuTextPlay:
        db "PLAY",0
        
menuTextExit:
        db "EXIT",0

    
mazeClearData:
        db $00,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$00
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $12,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$18
        db $00,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$00

stickDirectionTable:
        db $00,$01,$03,$02,$06,$04,$0c,$08,$09

mazeColors:
        db  $9b,$74,$2c,$ed,$12,$6a,$16,$69
    
spriteTable:
        db  81,122,0,15,81,122,0,1,208

;;--------------------------------------------------------------------
;; Ram variables
;;--------------------------------------------------------------------
mazeRamBase:    equ $
	
mazeSP:         equ mazeRamBase + 0
mazeNotVisited: equ mazeRamBase + 2
mazeCurrent:    equ mazeRamBase + 3

gamePosX:       equ mazeRamBase + 5
gamePosY:       equ mazeRamBase + 6
mazeScroll:     equ mazeRamBase + 7
gameDirMask:    equ mazeRamBase + 8
gameDirPerfer:  equ mazeRamBase + 9
gameCharacter:  equ mazeRamBase + 10
gameLevel:      equ mazeRamBase + 12
gameLives:      equ mazeRamBase + 13
gameScore:      equ mazeRamBase + 14
gameHighscore:  equ mazeRamBase + 16
gameCharDir:    equ mazeRamBase + 18
gameTime:       equ mazeRamBase + 19
gameMenu:       equ mazeRamBase + 21
randSeed        equ mazeRamBase + 23
channel_data:   equ mazeRamBase + 25

mazeData:       equ mazeRamBase + 40

mazeMap:        equ $c000
