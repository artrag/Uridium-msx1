;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; activate ms bullets
;
max_bullet_rate equ 5

ms_shoot:
	ld	a,(bullet_rate)
	and a
	jp	z,.book_bullet
	dec a
	ld	(bullet_rate),a
	ret
.book_bullet:
	ld	a,max_bullet_rate
	ld	(bullet_rate),a

	ld	ix,ms_bullets
	ld	b,max_bullets
	ld	de,enemy_data
1:	bit	0,(ix+enemy_data.status)
	jr	z,.activate_this
	add ix,de
	djnz   1b
	ret

.activate_this:
	xor	a				; ms bullet
	call AFXPLAY

	ld	a,(ms_state)	; in states 0-3 ms faces right
	and 0x04
	jr	nz,.shootsx
.shootdx
	ld	(ix+enemy_data.status),1
	ld	hl,8
	jp	1f

.shootsx
	ld	(ix+enemy_data.status),1 + 64
	ld	hl,-8
1:
	ld	a,(aniframe)
	and 7
	add a,8
	add a,a
	add a,a
	ld	(ix+enemy_data.frame),a

	call	set_size	; set  xoff,yoff,xsize,ysize for sprite collision

	ld	a,(dxmap)
[2] sra a
	ld	e,a
	rla
	sbc a,a
	ld	d,a

	add hl,de
	ld	(ix+enemy_data.speed),l
	ld	(ix+enemy_data.speed+1),h

	ld	hl,(xship)
	ld	(ix+enemy_data.x),l
	ld	(ix+enemy_data.x+1),h

	ld	a,(yship)
	ld	(ix+enemy_data.y),a
	ld	(ix+enemy_data.cntr),17
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; manage active ms bullets
;

bullet_loop:
	ld	ix,ms_bullets
	
	repeat	max_bullets
	bit	 0,(ix+enemy_data.status)
	jr	z,1f

	; move right or	 left

	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld	e,(ix+enemy_data.speed)
	ld	d,(ix+enemy_data.speed+1)
	add hl,de
	ld	(ix+enemy_data.x),l
	ld	(ix+enemy_data.x+1),h

	call	.test_obstacles

	dec	(ix+enemy_data.cntr)
	jr	nz,1f
	res 0,(ix+enemy_data.status)
1:
	ld	de,enemy_data
	add ix,de
	endrepeat
	ret


.test_obstacles:
	ld	e,(ix+enemy_data.frame)
	ld	d,0
	ld	iy,ms_bllts_col_win-32
	add	iy,de			; here iy points to the collision window of the current frame of the bullet

	bit	7,(ix+enemy_data.speed+1)
	jr	z,2f			;.x_positive

	ld	e,(iy+0)		;.x_negative:
	jp	3f

2:	ld	e,(iy+1)		;.x_positive:
	
3:
	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	add hl,de
	ld	a,(ix+enemy_data.y)
	add	a,(iy+2)
	push	hl
	push	af
	call	.tst_block
	pop		de
	pop		hl
	ret	z				; skip the rest if already hit
	ld	a,d
	and	0xF8
	ld	d,a
	ld	a,(ix+enemy_data.y)
	add	a,(iy+3)
	and	0xF8
	cp	d
	ret	z				; avoid testing twice the same tile
	jp	.tst_block


.tst_block:
	call test_obstacles.meta_tile_peek
	ld	e,a
	dec	a					; deal with space apart
	cp	nblock-1
	
	jp	nc,.no_blocking		; a>22
	
.blocking:	
	res 0,(ix+enemy_data.status)
	ld	a,10			; hit solid wall
	call AFXPLAY
	xor	a
	ret					; obstacle found - return Z
	
.no_blocking:
	cp	nblock+n_d2x1-1
	jp	nc,.no_2x1		; a>26
	
	cp	nblock+1
	jr	c,.left2x1		; two 2x1 items
	
.right2x1:
	ld	a,(hl)
	add	a,n_d2x1
	ld	(hl),a
	dec	hl
	jr	1f
	
.left2x1:
	ld	a,(hl)
	add	a,n_d2x1
	ld	(hl),a
	inc	hl
1:	ld	a,(hl)
	add	a,n_d2x1
	ld	(hl),a

	res 0,(ix+enemy_data.status)
	ld	a,11			; destroy small ground item
	call AFXPLAY
	ld	bc,5			; score for destruction of a small ground item
	call	add_bc_score_bin
	
	call	land_now_test	; make LAND NOW arrive sooner
	ret
	
.no_2x1:
	
	cp	nblock+n_d2x1*2-1
	jr	z,.left_up3x2
	cp	nblock+n_d2x1*2+0
	jr	z,.left_dw3x2
	cp	nblock+n_d2x1*2+1
	jr	z,.left_up3x2
	cp	nblock+n_d2x1*2+2
	jr	z,.left_dw3x2

	cp	nblock+n_d2x1*2+7
	jr	z,.right_up3x2
	cp	nblock+n_d2x1*2+8
	jr	z,.right_dw3x2
	cp	nblock+n_d2x1*2+9
	jr	z,.right_up3x2
	cp	nblock+n_d2x1*2+10
	jr	z,.right_dw3x2
	
	ret				; obstacle not found - return NZ
	
.left_dw3x2:
	ld	bc,-LvlWidth
	add hl,bc
	jr	.left_up3x2

.right_up3x2:
[2]	dec hl
	jr	.left_up3x2

.right_dw3x2:
	ld	bc,-LvlWidth-2
	add hl,bc

.left_up3x2:
	repeat 3
	ld	a,(hl)
	add	a,n_d3x2
	ld	(hl),a
	inc	hl
	endrepeat
	ld	bc,LvlWidth-3
	add hl,bc
	repeat 3
	ld	a,(hl)
	add	a,n_d3x2
	ld	(hl),a
	inc	hl
	endrepeat
	
	res 0,(ix+enemy_data.status)
	ld	a,12				; destroy large ground item
	call AFXPLAY
	ld	bc,50				; score for destruction of a large ground item
	call	add_bc_score_bin
	
	call	land_now_test	; make LAND NOW arrive sooner
	ret
	

	