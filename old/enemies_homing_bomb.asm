; =============================
; NPC 7
; Homing missile
; Moving to MC
; =============================


	ld 		a,	(ix+_NPC_status)
	and		a
	jp		nz, 0f
	;;;;;;;;;;;;;;;;;;;;;;;
	; state 0
	;;;;;;;;;;;;;;;;;;;;;;;
	
	; call 	RandPosition				; it has to be the position of the cannon
	; ld 		(ix+_NPC_x),	a			; CHANGE HERE TO ADD TESTING OF SOME SORT OF BULLET RESERVATION 
	; ld 		(ix+_NPC_y),	0
	
	; x,fx, y,fy         missile position
	; ddx,dx, ddy,dy     missile speed
	; +/-1, +/-1 		 missile acceleration 
	
	; initial speed
	
	; dx
	ld a,(myX)
	sub a,(ix+_NPC_x)
	ld (ix+_NPC_dx),a
	sbc	a,a
	ld	(ix+_NPC_ddx),a		;DDX = HI byte, DX = LO byte

	; dy
	ld a,(myY)
	sub a,(ix+_NPC_y)
	ld (ix+_NPC_dy),a
	sbc	a,a
	ld	(ix+_NPC_ddy),a		;DDY = HI byte, DY = LO byte

	bit	7,(ix+_NPC_ddx)
	ld	a,(ix+_NPC_dx)
	jr	z,1f
	neg
1:	ld	b,a

	bit	7,(ix+_NPC_ddy)
	ld	a,(ix+_NPC_dy)
	jr	z,1f
	neg
1:	or	b

	jp z,mchit			;if (|DX| or |DY|)==0 bullet hits MC

333:
	rlca							; test bit 7 of (|DX| or |DY|)
	jr	c,1f
	sla	(ix+_NPC_dx)
	sla	(ix+_NPC_dy)
	jr	333b
1:



	repeat 2						; CHANGE HERE FOR TUNING BULLET SPEED
	sla (ix+_NPC_dy)
	rl  (ix+_NPC_ddy)

	sla (ix+_NPC_dx)
	rl  (ix+_NPC_ddx)
	endrepeat						; now we have max (|dx|,|dy|)<4



	ld 		(ix+_NPC_pattern),	40
	ld 		(ix+_NPC_color),	7
	; ld		(ix+_NPC_pattern2),	0x84
	; ld		(ix+_NPC_color2),	1
	ld 		(ix+_NPC_status),1
	ld	(ix+_NPC_hp),4	
	ld 		(ix+_NPC_xoffset),6		
	ld 		(ix+_NPC_yoffset),5
	ld 		(ix+_NPC_xsize),4
	ld 		(ix+_NPC_ysize),4

	jp		npc_to_sat

	;;;;;;;;;;;;;;;;;;;;;;;
	; state !=0
	;;;;;;;;;;;;;;;;;;;;;;;
0:
	; y movement
	ld a,(ix+_NPC_y)
	add a,32
	cp 192+32 		; out of screen?
	jp nc,freeNPC
	cp 32
	jp c,freeNPC


	ld a,(myY)
	cp (ix+_NPC_y)
	sbc	a,a
	ld      h,a
	or	1             ; if  myY>=_NPC_y  HL=1
	ld      l,a           ; if  myY<_NPC_y   HL=-1

	repeat 6
	add    hl,hl
        endrepeat

	ld      e,(ix+_NPC_dy)  ; low byte
	ld      d,(ix+_NPC_ddy) ; hi byte
	add     hl,de

	jp	m,ynegative
ypositive:
	push    hl
	ld      bc,4*256
	and     a
	sbc     hl,bc
	pop     hl
	jp	p,333f		; if HL>=4 exit
	ld	(ix+_NPC_dy),l	; increase/decrease speed
	ld	(ix+_NPC_ddy),h	; increase/decrease speed
	jp 333f
ynegative:
	push    hl
	ld      bc,-4*256
	and     a
	sbc     hl,bc
	pop     hl
	jp	m,333f		; if HL<-4 exit
	ld	(ix+_NPC_dy),l	; increase/decrease speed
	ld	(ix+_NPC_ddy),h	; increase/decrease speed
333:

	ld a,(ix+_NPC_fy)
	add a,(ix+_NPC_dy)
	ld (ix+_NPC_fy),a

	ld a,(ix+_NPC_y)
	adc a,(ix+_NPC_ddy)
	ld (ix+_NPC_y),a
	

	; x movement	
	ld a,(ix+_NPC_x)
	add a,32
	cp 8*24-16+32 		; out of screen?
	jp nc,freeNPC
	cp 32
	jp c,freeNPC

; 	ld a,(myX)
; 	cp (ix+_NPC_x)
; 	sbc	a,a				; if  myX<_NPC_x   A=-1
; 	or	1				; if  myX>=_NPC_x  A=1
; 	add	a,(ix+_NPC_ddx)
; 	jp	m,xnegative
; xpositive:
; 	cp	4
; 	jr	nc,333f			; if A>=4 exit
; 	ld	(ix+_NPC_ddx),a	; increase/decrease speed
; 	jp 333f
; xnegative:	
; 	cp	-4
; 	jr	c,333f			; if A<-4 exit
; 	ld	(ix+_NPC_ddx),a	; increase/decrease speed
; 333:


	ld a,(myX)
	cp (ix+_NPC_x)
	sbc	a,a
	ld      h,a
	or	1             ; if  myX>=_NPC_x  HL=1
	ld      l,a           ; if  myX<_NPC_x   HL=-1

	repeat 6
	add    hl,hl
        endrepeat

	ld      e,(ix+_NPC_dx)  ; low byte
	ld      d,(ix+_NPC_ddx) ; hi byte
	add     hl,de

	jp	m,xnegative
xpositive:
	push    hl
	ld      bc,4*256
	and     a
	sbc     hl,bc
	pop     hl
	jp	p,333f		; if HL>=4 exit
	ld	(ix+_NPC_dx),l	; increase/decrease speed
	ld	(ix+_NPC_ddx),h	; increase/decrease speed
	jp 333f
xnegative:
	push    hl
	ld      bc,-4*256
	and     a
	sbc     hl,bc
	pop     hl
	jp	m,333f		; if HL<-4 exit
	ld	(ix+_NPC_dx),l	; increase/decrease speed
	ld	(ix+_NPC_ddx),h	; increase/decrease speed
333:

	
	ld a,(ix+_NPC_fx)
	add a,(ix+_NPC_dx)
	ld (ix+_NPC_fx),a
	
	ld a,(ix+_NPC_x)
	adc a,(ix+_NPC_ddx)
	ld (ix+_NPC_x),a

	;;;;;;;;;;;;;;;;;;;;;;;
	;  
	;  NPC animation
	;;;;;;;;;;;;;;;;;;;;;;;
	
	ld	a,(game_tic)
	and   2
	jr	nz,4444f
	inc	(ix+_NPC_counter)
	ld	a,(ix+_NPC_counter)
	and	1
	add	a,a
	add	a,a
	add	a,40
	ld 	(ix+_NPC_pattern),a
4444:
	;;;;;;;;;;;;;;;;;;;;;;;
	;  collision test
	;;;;;;;;;;;;;;;;;;;;;;;
	call	locking				; test if the NPC can be locked by a homing missle
		

	call normal_collision			; check bullets and subweapons for collision
	
	jp	c,4f					; no collision



	
	;;;;;;;;;;;;;;;;;;;;;;;
	;  collision test
	;  NPC agains MC
	;;;;;;;;;;;;;;;;;;;;;;;
	
	ld iy,myState
	call collision					; check for collision
	jp nc, npc_to_sat				; no collision.... continue
	
									; mc hit
	ld a,1
	ld (myState),a
	jp freeNPC

4:			; bullet hit
	ld (ix+_NPC_type),1
	ld (ix+_NPC_status),0			; turn NPC into an explosion
	
	ld (iy+_MC_status),0						; turn off bullet
	
	ld bc,0x05
	call addScore
	
	
	jp next_npc	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
casthomingbullet:
	ld	b,7				; NPC type for bullet
	call    init_npc		; y pos and the x pos in the next byte (inc hl)
	ret	z				; no spare room 
	inc	hl
	ld	a,(ix+_NPC_y)
	ld	(hl),a
	inc	hl
	ld	a,(ix+_NPC_x)
	ld	(hl),a
	
	ret	