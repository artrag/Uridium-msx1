
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	manage SAT entries of the main ship
;

put_ms_sprt:
	ld	a,(ms_state)
	cp	ms_explode
	jr	z,.expl
						; manage SAT entries of the main ship
	ld	hl,ram_sat
	ld	a,(yship)
	dec	a
	ld	(hl),a
	inc hl
	ld	(hl),xship_rel
	inc hl
	ld	(hl),0		; shape 0 hard wired
	inc hl
	ld	(hl),15
	inc hl

	ld	a,(yship)
	dec	a
	ld	(hl),a
	inc hl
	ld	(hl),xship_rel
	inc hl
	ld	(hl),4		; shape 4 hard wired
	ld	c,a
	inc hl
	ld	(hl),7
	inc hl

	ld	a,(yship)
	add a,16-1
	ld	(hl),a
	inc hl
	ld	(hl),xship_rel+16
	inc hl
	ld	(hl),8		; shape 8 hard wired
	inc hl
	ld	(hl),1
	ret
.expl:
						; manage SAT entries of the main ship
	ld	hl,ram_sat
	ld	a,(yship)
	ld	(hl),a
	inc hl
	ld	(hl),xship_rel
	inc hl
	ld	(hl),0		; shape 0 hard wired
	inc hl
	ld	(hl),10
	inc hl

	ld	a,(yship)
	ld	(hl),a
	inc hl
	ld	(hl),xship_rel
	inc hl
	ld	(hl),4		; shape 4 hard wired
	ld	c,a
	inc hl
	ld	(hl),11
	inc hl

	ld	a,(yship)
	ld	(hl),a
	inc hl
	ld	(hl),xship_rel
	inc hl
	ld	(hl),8		; shape 8 hard wired
	inc hl
	ld	(hl),6
	ret
	
.landing:
	ld	hl,ram_sat+4*2
	ld	a,(yship)
	dec	a
	ld	(hl),a
	inc hl
	ld	a,(xmap)
	ld  d,a
	ld	a,(xship)
	sub	a,d
	ld	(hl),a	; xship_rel
	inc hl
	ld	(hl),0		; shape 0 hard wired
	inc hl
	ld	(hl),15
	
	ld  de,-7
	add hl,de
	
	ld	a,(yship)
	dec	a
	ld	(hl),a
	inc hl
	ld	a,(xmap)
	ld  d,a
	ld	a,(xship)
	sub	a,d
	ld	(hl),a	; xship_rel
	inc hl
	ld	(hl),4		; shape 4 hard wired
	ld	c,a
	inc hl
	ld	(hl),7

	ld  de,-7
	add hl,de

	ld	a,(yship)
	add a,b 
	ld	(hl),a
	inc hl

	ld	a,(xmap)
	ld  d,a
	ld	a,(xship)
	sub	a,d
	add	a,b
	ld	(hl),a
	inc hl
	ld	(hl),8		; shape 8 hard wired
	inc hl
	ld	(hl),1
	ret
