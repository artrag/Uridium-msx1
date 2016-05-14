;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	manage MS collisions with background
;
	
;include	blocktiles.asm

test_obstacles:
	ld	hl,ms_ani
	ld	a,(aniframe)
	ld	c,a
	ld	b,0
	add	hl,bc
	ld	a,(hl)
	add	a,a
	add	a,a
	ld	ix,ms_col_win
	ld	c,a
	ld	b,0
	add	ix,bc

	ld	h,0
	ld	l,(ix+0)
	ld	de,(xship)
	add hl,de
	ld	a,(yship)
	add	a,(ix+2)
	call	.tst

	ld	h,0
	ld	l,(ix+1)
	ld	de,(xship)
	add hl,de
	ld	a,(yship)
	add	a,(ix+2)
	call	.tst

	ld	h,0
	ld	l,(ix+0)
	ld	de,(xship)
	add hl,de
	ld	a,(yship)
	add	a,(ix+3)
	call	.tst

	ld	h,0
	ld	l,(ix+1)
	ld	de,(xship)
	add hl,de
	ld	a,(yship)
	add	a,(ix+3)
	call	.tst

	ret


.tst:
	call .meta_tile_peek
	dec	a
	cp	nblock-1
	ret	nc		; a>22

.found:
	ld	a,(ms_state)
	cp	ms_explode
	ret	z
	ld	a,ms_explode
	ld	(ms_state),a
	ld	a,64
	ld	(aniframe),a
	xor	a
	ld	(dxmap),a

	ld	a,9			; ms explosion
	call AFXPLAY

	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	peek a meta-tile
; in	a:	y (screen coordinate)
;		hl: x (level coordinate)
; out	a: meta tile at x,y
;		hl: pointer in level_buffer to meta tile
	
.meta_tile_peek:
	sub 64				; move y to level coordinate
	and 0xF8
	rrca
	rrca

	srl h
	rr	l
	srl h
	rr	l
	srl h
	rr	l
	ex	de,hl

	ld	h,high _tst_table
	ld	l,a

	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a

	add	hl,de
	ld	a,(hl)
	ret

	ALIGN 0x0100
_tst_table:
	repeat 16
	dw	level_buffer + (@# * LvlWidth)
	endrepeat
	

