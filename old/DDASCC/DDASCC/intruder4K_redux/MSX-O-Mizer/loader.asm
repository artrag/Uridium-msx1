                db $fe
                dw  startFile,endFile-1,startProgram

                org 0C000h
startFile:
                include datas_depacker.asm
startProgram:
                ld  hl,data
                ld  de, 09000h
                call mom_depack
                jp 09000h


data:
                incbin game2k.bin.miz

endFile:

