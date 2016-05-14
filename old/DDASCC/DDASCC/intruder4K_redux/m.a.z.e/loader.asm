        output "maze.bin"

	db      $fe
	dw      init
	dw      end
	dw      init

	org     $c000

packmode:	equ 0

game_start: equ $cc00
game_main:  equ game_start + $31b


init:
        ld   a,128
        ld   de,1
        exx
        ld   hl,data
        ld   de,game_start
_ll_looplit:
        ldi
_ll_loop:
        add  a,a
        jr   nz,_ll_hup
        ld   a,(hl)
        inc  hl
        rla
_ll_hup:
        jr   nc,_ll_looplit

        exx
        ld   l,e
        ld   h,d
_ll_getlen:
        add  a,a
        call z,_getbyteexx
        jr   nc,_ll_lenok
        add  a,a
        call z,_getbyteexx
        adc  hl,hl
        jr   nc,_ll_getlen
	     jp game_main
_ll_lenok:
        inc  hl
        exx

	ld   c,(hl)
	inc  hl
	ld   b,0
 if packmode !=8
	bit  7,c
	jr   z,_offsok
	add  a,a
	call z,_getbyte
 if packmode !=9
	rl   b
	add  a,a
	call z,_getbyte
 if packmode !=0
	rl   b
	add  a,a
	call z,_getbyte
 if packmode !=1
	rl   b
	add  a,a
	call z,_getbyte
 if packmode !=2
	rl   b
	add  a,a
	call z,_getbyte
 if packmode !=3
	rl   b
	add  a,a
	call z,_getbyte
 endif
 endif
 endif
 endif
 endif
	rl   b
	add  a,a
	call z,_getbyte
	jr   nc,_offsok
	or   a
	inc  b
	res  7,c
_offsok:
 endif
	inc  bc

        push hl
        exx
        push hl
        exx
        ld   l,e
        ld   h,d
        sbc  hl,bc
        pop  bc
        ldir
        pop  hl
        jr   _ll_loop

_getbyte
	ld   a,(hl)
	inc  hl
	rla
	ret

_getbyteexx:
        exx
        ld   a,(hl)
        inc  hl
        exx
        rla
        ret

data:
        incbin "game.bin.plet0"
end:
