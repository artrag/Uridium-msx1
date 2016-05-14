

loopframe:
           push   hl
           push   bc
           push   de

          ld     hl,(curframe)
          ld      bc,0x0098

          xor a
          out     (0X99),a
          ld      a,0x18 + 64
          out     (0X99),a

          otir                       ; plot 768 bytes
          otir
          otir
          ld  (curframe),hl

          ld  a,(numframe)
          dec a
          ld  (numframe),a

          jr  nz,intend

          ld  hl,SAMPLE_START
          ld  (curframe),hl

          ld  a,nf
          ld  (numframe),a
intend:
           pop   de
           pop   bc
           pop   hl

           ret
