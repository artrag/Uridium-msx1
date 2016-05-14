	align 0x100
sprite_collision_windows:
	ds	3*4				; first 3 frames are missing
	include sprite_collision_window.asm

;	in: 
;		IX-> current sprite
;		(ix+enemy_data.frame) = frame in the SPT
;	out;
;		IX -> xoff,yoff,xsize,ysize are set
	
set_size:
 	ex	af,af'
	ld	a,(ix+enemy_data.frame)
	exx
	and	%11111100
	ld	l,a
	ld	h,high sprite_collision_windows		
	ld	a,(hl)
	ld	(ix+enemy_data.xoff),a
	inc	hl
	ld	a,(hl)
	ld	(ix+enemy_data.yoff),a
	inc	hl
	ld	a,(hl)
	ld	(ix+enemy_data.xsize),a
	inc	hl
	ld	a,(hl)
	ld	(ix+enemy_data.ysize),a
	exx
	ex		af,af'
	ret

;	in: 
;		IY-> current sprite
;		(iY+enemy_data.frame) = frame in the SPT
;	out;
;		IY -> xoff,yoff,xsize,ysize are set
	
set_size2:
 	ex	af,af'
	ld	a,(iy+enemy_data.frame)
	exx
	and	%11111100
	ld	l,a
	ld	h,high sprite_collision_windows		
	ld	a,(hl)
	ld	(iy+enemy_data.xoff),a
	inc	hl
	ld	a,(hl)
	ld	(iy+enemy_data.yoff),a
	inc	hl
	ld	a,(hl)
	ld	(iy+enemy_data.xsize),a
	inc	hl
	ld	a,(hl)
	ld	(iy+enemy_data.ysize),a
	exx
	ex		af,af'
	ret
	

;	in: 
;		IX-> current bullet
;		(iY+enemy_data.frame) = frame in the SPT
;		xship,yship,ms_ysize,ms_xoff ecc ecc
;	out:
;		Carry set = MS is hit
;
test_collision_enemy_bullets:
	
	ld  a,(ix+enemy_data.y)
	add a,(ix+enemy_data.yoff)
	ld  b,a
	ld  c,(ix+enemy_data.ysize)
	
	;[minx(h) maxx(h) miny(h) maxy(h)]
	
	ld  a,(yship)
	add	a,(iy+2)
	ld  d,a
	
	ld	a,(iy+3)
	sub	a,(iy+2)
	inc	a
	ld  e,a 		; 	ms_ysize
	
	call	CollisionCheck_8b
	ret nc
	
	;[minx(h) maxx(h) miny(h) maxy(h)]
	
	ld l,(ix+enemy_data.x)
	ld h,(ix+enemy_data.x+1)
	ld d,0
	ld e,(ix+enemy_data.xoff)
	add hl,de
	ex de,hl
	
	ld b,h
	ld hl,(xship)
	ld c,(iy+0) ;	ms_xoff
	add hl,bc

	ld c,(ix+enemy_data.xsize)
	
	ld	a,(iy+1)
	sub	a,(iy+0)
	inc	a
	ld  b,a 		; ms_xsize

	jp CalcCollision
	; call CalcCollision
	; ret 
	
;	in: 
;		ix -> current enemy
;	out;
; 		Carry set = collision
	
test_collision_msbullets:

    ld  iy,ms_bullets
	ld  de,enemy_data
    ld  b,max_bullets
    and	a
	
1:	exx
    
	bit 0,(iy+enemy_data.status)
	call	nz,test_collision
	ret	c
	
	exx
    add iy,de
    djnz   1b
	ret
	

; struct enemy_data
; y               db  0
; x               dw  0
; xoff			db	0
; yoff			db	0
; xsize			db	0
; ysize			db	0
; status          db  0
; cntr            db  0
; kind            db  0
; frame			db	0
; color			db	0
; speed           dw  0
; ends


; IN: 
; 	ix -> object 1
; 	iy -> object 2
;
; OUT: 
; Carry set = collision

test_collision:
	ld  a,(ix+enemy_data.y)
	add a,(ix+enemy_data.yoff)
	ld  b,a
	ld  c,(ix+enemy_data.ysize)
	
	ld  a,(iy+enemy_data.y)
	add	a,(iy+enemy_data.yoff)
	ld  d,a
	ld  e,(iy+enemy_data.ysize)
	
	call	CollisionCheck_8b
	ret nc
	
	ld l,(ix+enemy_data.x)
	ld h,(ix+enemy_data.x+1)
	ld d,0
	ld b,d
	ld e,(ix+enemy_data.xoff)
	add hl,de
	ex de,hl
	
	ld l,(iy+enemy_data.x)
	ld h,(iy+enemy_data.x+1)
	ld c,(iy+enemy_data.xoff)
	add hl,bc

	ld c,(ix+enemy_data.xsize)
	ld b,(iy+enemy_data.xsize)

	; call CalcCollision
	; ret 

; CalcCollision
;
; 1D collision check
;
; IN: 
; 	DE = Location object 1
; 	C = Size object 1
; 	HL = Location object 2
; 	B = Size object 2
; OUT: 
; Carry set = collision
;
CalcCollision:
	xor a
	sbc hl,de		; x2-x1
	ld  d,a
	jr  c,.switch 	; jump if x2<x1
	
					; x2>=x1
	ld  e,c
	sbc hl,de		; C == x2-x1<dx1	
	ret


.switch:			; x2-x1<0
	ld	d,a
	ld	e,b
	xor	a
	sbc hl,de		; x2-x1 - dx2
	ret				; C == x1-x2<dx2

;
; CollisionCheck
;
;   Calculates whether a collision occurs between two objects
;   of a certain size
;
; IN: b = coordinate of object 1
;     c = size of object 1
;     d = coordinate of object 2
;     e = size of object 2
; OUT: Carry set if collision
; CHANGES: AF
;
CollisionCheck_8b:
        ld      a,d             ; get x2                       [5]
        sub     b               ; calculate x2-x1              [5]
        jr      c,.other        ; jump if x2<x1                [13/8]
        sub     c               ; compare with size 1          [5]
        ret                     ; return result                [11]
.other:
        neg                     ; use negative value           [10]
        sub     e               ; compare with size 1          [5]
        ret                     ; return result                [11]


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; check_obj_collision
; (obj *obj1,                          DE
;  obj *obj2);                         BC
;
; obj->
;    dw x,y
;    db dx,dy
;
; if collision 
;	return HL = -1 
; else 
;	return HL = 0

	struct obj_data
y               db  0
x               dw  0
xoff			db	0
yoff			db	0
xsize			db	0
ysize			db	0
    ends


_check_obj_collision:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	push de
	pop ix		; ix   -> obj_data1
	push bc
	pop iy		; iy   -> obj_data1

check_obj_collision_8_16:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ld  a,(ix+obj_data.y)        ; TEST Y
	add	a,(ix+obj_data.yoff)
	ld	l,a				; HL=vertical pos. object 1 + 256 (i.e. Y1+256)
	ld	h,1
	
	
	ld  a,(iy+obj_data.y)
	add	a,(iy+obj_data.yoff)
	ld	e,a		    	; DE=vertical pos. object 2 + 256 (i.e. Y2+256)
	ld	d,h               

	ld      b,(iy+obj_data.ysize)    ; B=number of pixels, object 2 (i.e. Ysize2)

	xor      a
	sbc     hl,de
	jr      nc,1f       ; if HL<DE swap objects

swap_objects_y:

	ld      b,(ix+obj_data.ysize)    ; B=number of pixels, object 1 (i.e. Ysize1)

	ex      de,hl
	ld      h,a			; NB: A is 0
	ld      l,a
	sbc     hl,de       ; HL = - HL

1:	or      h			; NB: A was 0
	jr      nz,9f       ; Delta Y>256 == test failed (NB: CF = 0)

	ld      a,l         ; A = abs(Y2+256-(Y1+256)); B = (Y2>Y1) ? Ysize1 : Ysize2;
	cp      b
	jr      nc,9f       ; delta Y> B == test failed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld	b,1

	ld  l,(ix+obj_data.x)        ; TEST X
	ld  h,(ix+obj_data.x+1)
	ld	c,(ix+obj_data.xoff)
	add	hl,bc		    ; HL=x pos. object 1 + 256 (i.e. X1+256)

	ld  e,(iy+obj_data.x)
	ld  d,(iy+obj_data.x+1)
	ld	c,(iy+obj_data.xoff)
	add	hl,bc		    ; DE=x pos. object 2 + 256 (i.e. X2+256)
	ex	de,hl               

	ld      b,(iy+obj_data.xsize)    ; Xsize2 in b

	xor      a
	sbc     hl,de       ; x1-x2
	jr      nc,1f       ; if (x1-x2>=0) swap objects (NB CF=0)

swap_objects_x:

	ld      b,(ix+obj_data.xsize)    ; Xsize1 in b

	ex      de,hl
	ld      h,a			; NB: A is 0
	ld      l,a
	sbc     hl,de       ; hl=x1-x2

1:	or      h
	jr      nz,9f       ; if delta X>256 the test on X failed (NB CF=0)

	ld      a,l
	cp      b           ; CF holds the test result on X

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

9:              
	sbc     hl,hl       ; return hl = -1 if obj1 and obj2 collide

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
	
	