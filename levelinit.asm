
; ------------------------------------------------
; expand level in A
;
levelinit:
	ld	(cur_level),a
	
	ld	hl,level_buffer
	ld	de,level_buffer+1
	xor a
	ld	(hl),a
	ld	bc,LvlWidth*16-1+32
	ldir
	
	ld	hl,0
	ld	(xmap),hl
	ld	bc,xship_rel
	add hl,bc
	ld	(xship),hl
	; ld	a,64+64-8
	; ld	(yship),a


	ld	a,(cur_level)
	ld	l,a
	ld	h,0
	add hl,hl
	ld	bc,meta_levels
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	de,level_buffer
	jp	mom_depack_rom



	
meta_levels:
	dw meta_pnt0, meta_pnt1, meta_pnt2, meta_pnt3
	dw meta_pnt4, meta_pnt5, meta_pnt6, meta_pnt7
	dw meta_pnt8, meta_pnt9, meta_pntA, meta_pntB
	dw meta_pntC, meta_pntD, meta_pntE, meta_pntF

	
; *** Level data in rom ***

	;
meta_pnt0:	incbin lev_ms.miz
	;
meta_pnt1:	incbin lev_1.miz
	;
meta_pnt2:	incbin lev_2.miz
	;
meta_pnt3:	incbin lev_3.miz
	;
meta_pnt4:	incbin lev_4.miz
	;
meta_pnt5:	incbin lev_5.miz
	;
meta_pnt6:	incbin lev_6.miz
	;
meta_pnt7:	incbin lev_7.miz
	;
meta_pnt8:	incbin lev_8.miz
	;
meta_pnt9:	incbin lev_9.miz
	;
meta_pntA:	incbin lev_A.miz
	;
meta_pntB:	incbin lev_B.miz
	;
meta_pntC:	incbin lev_C.miz
	;
meta_pntD:	incbin lev_D.miz
	;
meta_pntE:	incbin lev_E.miz
	;
meta_pntF:	incbin lev_F.miz
