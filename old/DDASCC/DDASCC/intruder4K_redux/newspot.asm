               macro copy_line cols,offset
               ld    bc,cols
               ld    a,offset
               call  copy_one_line
               endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; draw spot light
;
;


               ld   e,(iy+NPCS_DATA.X)
               ld   d,(iy+NPCS_DATA.Y)
               call GET_ADDRESS

               push hl
               ld   bc,-3-7*vroomsize+VMPNT +vroomsize/2
               add  hl,bc
               ex   de,hl           ; destination in de

               pop  hl
               ld   bc,-3-7*vroomsize+MPNT +vroomsize/2
               add  hl,bc          ; source in hl

               copy_line 6,8-(8-6)/2
               copy_line 8,12-(12-8)/2
               copy_line 12,12-0
               copy_line 12,14-(14-12)/2
               copy_line 14,16-(16-14)/2
               rept  5
               copy_line 16,16-0
               endm
               copy_line 16,14-(14-16)/2
               copy_line 14,12-(12-14)/2
               copy_line 12,12-0
               copy_line 12,8-(8-12)/2
               copy_line 8,6-(6-8)/2
               copy_line 6,0

               ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;         Copy one line
;in: hl source
;    de destination
;    bc #columns
;    a offset
;
;out: next hl and de
;
copy_one_line:

               ldir                ;  columns
               ld  bc,vroomsize    ; source & destination one line down
               add a,c
               ld  c,a
               jr  nc,1f
               inc b
1:                                 ;       add bc to hl
                                   ;       add bc to de
               add hl,bc
               ex  de,hl           ; source temporary in de, destination temporary in hl
               add hl,bc           ; destination one line down
               ex  de,hl           ; destination in de, source in hl
               ret
