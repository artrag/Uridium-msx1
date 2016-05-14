
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Input :
; DE = pointer in hidden to (x-coordinate,y-coordinate)

;- draw one line-of-sight

_drawline:
        
1:      ex      de,hl   
        add     hl,bc
        ld      a,(hl)
        ex      de,hl
        
        ld      hl,-hidden+visible
        add     hl,de
        ld      (hl),a
                 
        cp      wallchr                     ; view blocking characters
        ret     z
        cp      doorchr        
        ret     z
        jp      1b        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Input:
; None
;Output:
; compute the FoV visible area

fastmanview:

        call    locateman        
        ld      (buffer),de
        push    hl,de,bc
        call    viewsegments
        pop     hl,de,bc
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Input:
; buffer points to the buffer of the FoV
;Output:
; compute the FoV in 8 octants (split in 4 quadrants)

viewsegments:

        ld      bc,-MAPW+1      ; segment 1
        ld      de,(buffer)
        call    segxloopinc
        
        ld      de,(buffer)
        call    segyloopdec

        ld      bc,MAPW+1       ; segment 2
        ld      de,(buffer)
        call    segxloopinc
        
        ld      de,(buffer)
        call    segyloopinc
        
        ld      bc,MAPW-1       ; segment 3
        ld      de,(buffer)
        call    segxloopdec
        
        ld      de,(buffer)
        call    segyloopinc

        ld      bc,-MAPW-1      ; segment 4
        ld      de,(buffer)
        call    segxloopdec
        
        ld      de,(buffer)
        jp      segyloopdec
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
segxloopinc:
1:
        ld      a,(de)
        ld      hl,-hidden+visible
        add     hl,de
        ld      (hl),a
        
        cp      wallchr                     ; view blocking characters
        ret     z
        cp      doorchr        
        ret     z

        push    de
        call    _drawline
        pop     de

        inc     de
        jp     1b
        
segxloopdec:
1:
        ld      a,(de)
        ld      hl,-hidden+visible
        add     hl,de
        ld      (hl),a
        
        cp      wallchr                     ; view blocking characters
        ret     z
        cp      doorchr        
        ret     z

        push    de
        call    _drawline
        pop     de

        dec     de
        jp     1b

segyloopinc:
1:
        ld      hl,MAPW
        add     hl,de
        ld      a,(hl)
        ex      de,hl
        
        ld      hl,-hidden+visible
        add     hl,de
        ld      (hl),a

        cp      wallchr                     ; view blocking characters
        ret     z
        cp      doorchr        
        ret     z

        push    de
        call    _drawline
        pop     de
        jp     1b

segyloopdec:
1:
        ld      hl,-MAPW
        add     hl,de
        ld      a,(hl)
        ex      de,hl
        
        ld      hl,-hidden+visible
        add     hl,de
        ld      (hl),a

        cp      wallchr                     ; view blocking characters
        ret     z
        cp      doorchr        
        ret     z

        push    de
        call    _drawline
        pop     de
        jp     1b


