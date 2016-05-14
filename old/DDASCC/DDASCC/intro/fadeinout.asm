datatab    equ 0xc100

fadein:

        exx
        ld      hl,colorfadingin-1
        jr      1f

fadeout:
        exx
        ld      hl,colorfadingout-1
1:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ld      d,0
        ld      e,b
        add     hl,de
        ld      a,(hl)
        ex      af,af
        exx
1:        
        halt                  ; avoid conflicts with interrupt
        ld      a,(delframe)
        cp      animdealay
        jr      nz,1b


        ld      hl,datatab
        ld      e,0
outer:  ld      d,0

inner:  ld      b,d
        ld      a,15
        cp      d
        jr      nz,1f
        ex      af,af
        ld      b,a
        ex      af,af
1:      

        ld      c,e
        ld      a,15
        cp      e
        jr      nz,1f
        ex      af,af
        ld      c,a
        ex      af,af
1:      
        ld      a,c
        add     a,a
        add     a,a
        add     a,a
        add     a,a
        or      b
        
        ld      (hl),a
        inc     hl
        
        inc     d
        ld      a,d
        cp      16
        jr      nz,inner

        inc     e
        ld      a,e
        cp      16
        jr      nz,outer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        xor     a
        out     (0x99),a
        ld      a,0x2000/256 + 0x40 ; PCT
        out     (0x99),a


        ld      hl,0xc000+3*256*8
        ld      de,datatab
        ld      bc,256*8*2

1:
        
        ld      e,(hl)
        ld      a,(de)
        out     (0x98),a

        inc     hl

        dec     bc
        ld      a,b
        or      c
        jp      nz,1b
        ret

