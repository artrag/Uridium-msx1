

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	plot enemies and bullets if visible
;
plot_enemy:

	ld	iy,ram_sat+4*3
	ld	ix,enemies
	ld	b,max_enem + max_bullets + max_enem_bullets
	ld	c,3				; main ship and its shadow

npc_loop1:
	ld	a,(ix+enemy_data.status)
	and 1
	jr	z,.next

	ld	l,(ix+enemy_data.x+0)
	ld	h,(ix+enemy_data.x+1)
	ld	de,32
	add hl,de
	ld	de,(xmap)
	and a
	sbc hl,de		; dx = enemy.x + 32 - xmap
	jp	c,.next		; dx <-32
	ld	de,32
	sbc hl,de
	jp c,.ecset		; -32<dx<0

	ld	a,h
	and a
	jp	nz,.next	; dx >255

	res 7,(iy+3)

.cont:
	ld	a,(ix+enemy_data.frame)
	cp	16*4					; hard coded in the SPT
	jp	nc,.two_layers

.one_layer:
	ld	(iy+2),a				; write shape
	ld	(iy+1),l				; write X
	ld	a,(ix+enemy_data.y)		; write Y
	ld	(iy+0),a
	ld	a,(iy+3)
	and 0xF0
	or	(ix+enemy_data.color)
	ld	(iy+3),a				; write colour
	inc c
	ld	de,4
	add iy,de

.next:
	ld	de,enemy_data
	add ix,de
	djnz	npc_loop1

	ld	a,c
	add a,a				; x4 -> sat data
	add a,a
	ld	(visible_sprts),a
	ret

.two_layers:
	ld	(iy+2),a				; write shape
	add	a,8
	ld	(iy+2+4),a				; second layer shape
	ld	(iy+1),l				; write X
	ld	(iy+1+4),l	
	ld	a,(ix+enemy_data.y)		; write Y
	ld	(iy+0),a
	ld	(iy+0+4),a
	ld	a,(iy+3)
	and 0xF0
	or	(ix+enemy_data.color)
	ld	(iy+3),a				; write colour
	and	0xF0
	or	1						; second layer colour
	ld	(iy+3+4),a	
	inc c
	inc c
	ld	de,8
	add iy,de
	jp	 .next
	
.ecset:
	add hl,de
	set 7,(iy+3)
	jp	.cont
