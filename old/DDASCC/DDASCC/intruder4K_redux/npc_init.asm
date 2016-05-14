
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

npc_init:

                ld   ix,NPCs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ld   bc,(nbllts-1)
                inc  b
                jr   3f

1:              ld   (ix+NPCS_DATA.TYPE),3
                ld   (ix+NPCS_DATA.FRAME),63
                ld   (ix+NPCS_DATA.Xsize),2
                ld   (ix+NPCS_DATA.Ysize),2
                ld   (ix+NPCS_DATA.Y),212
                
                ld   de,NPCS_DATA
                add  ix,de

3:              djnz 1b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                ld   bc,(nrbts-1)
                inc  b
                jr   3f

1:
2:              call  rand
                cp  192-16-48
                jr  nc,2b

                add a,24

                ld    (ix+NPCS_DATA.Y),a
                ld    (ix+NPCS_DATA.Y+1),0

2:              call  rand
                cp  255-8-32
                jr  nc,2b

                add a,16

                ld    (ix+NPCS_DATA.X),a
                ld    (ix+NPCS_DATA.X+1),0

                ld   (ix+NPCS_DATA.Xsize),8
                ld   (ix+NPCS_DATA.Ysize),16

                ld    (ix+NPCS_DATA.COUNT),1
                ld    (ix+NPCS_DATA.STATUS),1
                ld    (ix+NPCS_DATA.FRAME),63

                call  rand3                     ; is a rand value in 0,1,2
                ld    (ix+NPCS_DATA.TYPE),a

                ld   de,NPCS_DATA
                add  ix,de

3:              djnz 1b
                ret
