;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Initialization
;

music_init:      

	    ;;-------------------------------
	    ;; Initialize game song
	    ;;-------------------------------

        ld      hl,game_song
	    call    tm0_setsong
        ret                     ;       silence

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        include "m.a.z.e.\tm0player.asm"
        include "m.a.z.e.\gamesong.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; EXPLOSION
;
;rem SOUND 1,7
; SOUND 7,&b010110110
;
; N = 15
; V = 60
;
; FOR F = 0 TO 255 STEP 8
;rem  SOUND 0,F
;     SOUND 6,N
;     SOUND 8,V/4
;     N = N + 6
;     V = V - 1
; NEXT F
;
; SOUND 8,0

       		; --- SFX  ---

explode:
               ld       a,15
               ld       (_n+1),a
               
               ld       a,63
               ld       (_v+1),a        ; V = 60

               ld       hl,explode_loop
               ld       (sfx+1),hl


explode_loop:
               ld       a,7
               call     RDPSG
               and      10110111b
               ld	    e,a
               ld       a,7
               call	WRTPSG     ;       SOUND 7,&b010110111

               ld       a,6
_n:            ld       e,0
               call	WRTPSG     ;       SOUND 6,N
               add      a,e
               ld       (_n+1),a

               ld       a,8
_v:            ld       e,0
               ld       b,e
               srl      e
               srl      e               
               call	WRTPSG     ;       SOUND 8,V/4
               ld       a,b
               dec      a
               ld       (_v+1),a
               ret      nz

               ld       hl,no_sfx
               ld       (sfx+1),hl
               ret              

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; LASER
;
;10 SOUND1,0
;20 SOUND6,128
;30 SOUND7,&b10110110
;40 SOUND8,15

;80 FORK=0TO255STEP32
;90 SOUND0,K
;100 FORI=0TO1:NEXT
;110 NEXTK

;140 SOUND8,0


laser:

               xor      a
               ld       (_k+1),a

               ld       hl,laser_loop
               ld       (sfx+1),hl

laser_loop:
               ld       a,6
               ld       e,128
               call	WRTPSG     ;       SOUND 6,128

               inc      a
               call     RDPSG
               and      010110110b
               ld	    e,a
               ld       a,7
               call	WRTPSG     ;       SOUND 7,&b010110110

               inc      a
               ld       e,15
               call	WRTPSG     ;       SOUND 8,15
               
               ld       a,1
               ld       e,0
               call	WRTPSG     ;       SOUND 1,0

               xor      a
_k:            ld       e,0
               call	WRTPSG     ;       SOUND 0,k
               ld       a,32
               add      a,e
               ld       (_k+1),a

               ret      nz

               ld       e,a
               ld       a,8
               call	WRTPSG     ;       SOUND 8,0

               ld       hl,no_sfx
               ld       (sfx+1),hl
               ret              

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Final switch
;


shutdown:
               ld       hl,0x0FFF
               ld       (vl),hl
               ld       hl,0x230
               ld       (fq),hl

               ld       hl,shutdown_loop
               ld       (sfx+1),hl

shutdown_loop:
               ld       a,7
               call     RDPSG
               and      010111110b
               ld	    e,a
               ld       a,7
               call	WRTPSG     ;       SOUND 7,&b010111110

               ld       hl,(fq)
               ld       e,l
               xor      a
               call	WRTPSG     ;       SOUND 0,low fq

               ld       e,h
               inc      a
               call	WRTPSG     ;       SOUND 1,hi fq
               
               ld       bc,32
               add      hl,bc
               ld       (fq),hl

               ld       hl,(vl)
               ld       e,h
               ld       a,8               
               call	WRTPSG     ;       SOUND 8,vl/256

               ld       bc,-32
               add      hl,bc
               ld       (vl),hl
               
               ld       a,h
               or       a
               ret      p

               ld       hl,no_sfx
               ld       (sfx+1),hl
               ret              

fq:            ds   2
vl:            ds   2
