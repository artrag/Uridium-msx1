
.one_layer:
	ld	(iy+1),l				; write X

	ld	a,(ix+enemy_data.y)		; write Y
	ld	(iy+0),a

	ld	a,(ix+enemy_data.frame)
	ld	(iy+2),a				; write shape

	ld	a,(iy+3)
	and 0xF0
	or	(ix+enemy_data.color)
	ld	(iy+3),a				; write colour

	inc c

	ld	de,4
	add iy,de
	jp	 .next

two_layers:
	ld	(iy+1),l				; write X
	ld	(iy+1+4),a	

	ld	a,(ix+enemy_data.y)		; write Y
	ld	(iy+0),a
	ld	(iy+0+4),a

	ld	a,(ix+enemy_data.frame)
	ld	(iy+2),a				; write shape
	add	a,8
	ld	(iy+2+4),a	; second layer shape

	ld	a,(iy+3)
	and 0xF0
	or	(ix+enemy_data.color)
	ld	(iy+3),a				; write colour
	and	0xF0
	or	1			; second layer colour
	ld	(iy+3+4),a	

	inc c
	inc c

	ld	de,8
	add iy,de
	jp	 .next
