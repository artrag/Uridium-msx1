;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ; check_collision 
                ; (byte *obj1,                          ix
                ;  byte *obj2);                         iy
                ; obj-> 
                ;    dw x,y
                ;    db dx,dy
                ;
                
check_collision:
                                        ; ix+0   -> x1 
                                        ; ix+2   -> y1
                                        ; ix+4   -> Xsize1
                                        ; ix+5   -> Ysize1
                
                                        ; iy+0   -> x2
                                        ; iy+2   -> y2
                                        ; iy+4   -> Xsize2
                                        ; iy+5   -> Ysize2
                ; TEST Y

                ld      de,(ix+2)       
                inc     d               ; DE=vertical pos. object 1 + 256 (i.e. Y1+256)

                ld      hl,(iy+2)
                inc     h               ; HL=vertical pos. object 2 + 256 (i.e. Y2+256)

                ld      b,(iy+5)        ; B=number of pixels, object 2 (i.e. Ysize2)

                ex      de,hl           ; swap DE and HL
                or      a
                sbc     hl,de
                jr      nc,1f           ; if HL<DE swap objects

                ld      b,(ix+5)        ; B=number of pixels, object 1 (i.e. Ysize1)

                add     hl,de
                ex      de,hl
                or      a
                sbc     hl,de

1:              ld      a,l             ; A = abs(Y2+256-(Y1+256)); B = (Y2+256>Y1+256) ? Ysize1 : Ysize2;
                cp      b
                jr      nc,9f           ; the test in Y failed

                ; TEST X

                ld      de,(ix+0)       ; x1 in de
                ld      hl,(iy+0)       ; x2 in hl
                
                ld      b,(iy+4)        ; Xsize2 in b

                ex      de,hl           ; x2 in de, x1 in hl
                or      a
                sbc     hl,de           ; x1-x2
                jr      nc,1f           ; if (x1-x2>=0) swap objects

                ld      b,(ix+4)        ; Xsize1 in b
                add     hl,de
                ex      de,hl           ; x1 in hl, x2 in de
                or      a
                sbc     hl,de           ; hl=x1-x2


1:              ld      a,h
                or      a
                jr      nz,9f

                ld      a,l
                cp      b


9:                                      ; return C if obj1 and obj2 collide

                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

