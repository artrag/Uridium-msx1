        output "maze.rom"

	    org     $4000

	    db  "A","B"
	    dw  init,0,0,0,0,0,0
    	
init:
        ld      hl,game+7
        ld      de,$c000
        ld      bc,gamesize-7
        ldir
        jp      $c000
    
game:
        incbin "maze.bin"
gamesize: equ $ - game

        ds  $6000-$
    
