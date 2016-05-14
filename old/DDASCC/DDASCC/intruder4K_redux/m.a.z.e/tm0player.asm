;                      ---------
;                     TM0 Tracker
;                      ---------
;
;               (c) 2008 dvik & joyrex
;
; TM0 is a very basic PSG replayer that only requires 118 bytes
; of RAM/ROM for the code and 15 bytes RAM. It is a 3 track
; pattern player where the patterns have variable length.
; This means that the track can switch patterns independently
; of each other.
;
; A track is basically a list of patterns. The last pattern
; in a track is a special pattern that contains a pointer to
; the beginning of the track. This is to avoid keeping counters
; or other end tags, all to reduce code usage.
;
; A pattern contain a list of 16 bit command/value pairs
; The following commands are available: 
;
; hhaaaaaa aaaaaaaa - Switches track to the one located at
;                     the 16 bit address. hh is the high
;                     two bits in the address and shall be > 0.
;                     Used mainly for looping the track.
; 001xxxxx xxxxxxxx - End of pattern. Switches to next pattern  
;                     in current track.
; 0001xxxx dddddddd - Sets delay (in frames) until next command 
;                     will be executed.
; 0000rrrr vvvvvvvv - Programs PSG register R with value V
;
;
; channel_data structure:
;   0x00 -  ch1 delay until next write
;   0x01 -  ch1 pattern location
;   0x03 -  ch1 track location
;   0x05 -  ch2 delay until next write
;   0x06 -  ch2 pattern location
;   0x08 -  ch2 track location
;   0x09 -  ch1 delay until next write
;   0x0a -  ch1 pattern location
;   0x0c -  ch1 track location
;
;
    
    
;;--------------------------------------------------------------------
;; tm0_interrupt
;; 
;; Description:
;;      Plays 1/50th of a song. The method shall be called once
;;      every frame.
;;--------------------------------------------------------------------
tm0_interrupt:
        ld      ix,channel_data
        call    _tm0_play_one
        inc     ix
        inc     ix
        inc     ix
        inc     ix
        inc     ix
        call    _tm0_play_one
        inc     ix
        inc     ix
        inc     ix
        inc     ix
        inc     ix
    
_tm0_play_one:
        dec     (ix+0)  ; Delay counter
        ret     nz
    
_tm0_loop:
        ld      l,(ix+1)  ; Pattern location
        ld      h,(ix+2)
        ld      e,(hl)
        inc     hl
        ld      a,(hl)
        inc     hl
        ld      (ix+1),l
        ld      (ix+2),h
        
        cp      $40
        jr      nc,_tm0_settrack
        
        cp      $20
        jr      nc,_tm0_nexttrack

        cp      $10
        jr      nc,_tm0_delay
        
        out     ($a0),a
        ld      a,e
        out     ($a1),a
        
        jp      _tm0_loop


;;--------------------------------------------------------------------
;; tm0_setsong,  tm0_mute
;; 
;; In:  [hl]  - Pointer to song data
;;
;; Description:
;;      Initializes the song and mutes the PSG
;;--------------------------------------------------------------------
tm0_setsong:
        ld      de,channel_data
        ld      bc,15
        ldir
tm0_mute:
        jp      $90
    
    
;;--------------------------------------------------------------------
;; _tm0_nexttrack
;; 
;; Description:
;;      Moves track pointer to beginning of next rack for current
;;      channel.
;;--------------------------------------------------------------------
_tm0_nexttrack:
        ld      l,(ix+3)
        ld      h,(ix+4)
        ld      e,(hl)
        inc     hl
        ld      a,(hl)
        inc     hl
        ld      (ix+3),l
        ld      (ix+4),h
        ld      (ix+1),e
        ld      (ix+2),a

        jp      _tm0_loop


;;--------------------------------------------------------------------
;; _tm0_delay
;; 
;; Description:
;;      Saves the delay count for current channel.
;;--------------------------------------------------------------------
_tm0_delay:
        ld      (ix+0),e
        ret


;;--------------------------------------------------------------------
;; _tm0_settrack
;; 
;; Description:
;;      Switches track for current channel
;;--------------------------------------------------------------------
_tm0_settrack:
        ld      (ix+3),e
        ld      (ix+4),a
        jr      _tm0_nexttrack
