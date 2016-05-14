




; =============================
; NPC 22
; Generic movement NPC 2
; Moving using script. Init is 
; done outside this npc
; =============================

; SCRIPT SYNTAX
;
;
; db	<action code><parameter0>..<parameterx><timer>
;
; action 0: - Fix X, Fix Y		db 0,<dy>,<dx>,<timer>
; 
; action 1: - Var X, Fix Y		db 1,<lookuptable L><lookuptable H>,<dy>,<timer>
; 
; action 2: - Fix X, Var Y		db 2,<dx>,<lookuptable L><lookuptable H>,<timer>
; 
; action 3: - Var X, Var Y		db 3,<lookuptable L><lookuptable H>,<lookuptable L><lookuptable H>,<timer>
; 
; action 4: - Var X2,Fix Y		db 4,<lookuptable L><lookuptable H>,<dy>,<timer>
; 
; action 5: - Fix X, Var Y2		db 5,<dx>,<lookuptable L><lookuptable H>,<timer>
; 
; action 6: - Var X2,Var Y2 		db 6,<lookuptable L><lookuptable H>,<lookuptable L><lookuptable H>,<timer>
;
; action 7: - Special  !! Each specials needs to be followed by a new action (0-7)
;	db	7,0				; cast bullet
;	db	7,1,<pattern1>,<pattern2> 	; change sprite pattern
; 

; expects x pos in a
macro NPC22_X_outside_screen
	;add	a,16
	cp 192-16
	jp nc,freeNPC
endmacro

; expects y pos in a
macro NPC22_Y_outside_screen
	add	a,16
	cp 192+16
	jp nc,freeNPC
endmacro


	;====================
	; Collision
	;====================
_NPC22_collision: 	
	ld	a,(ix+_NPC_subtype)
	and	3
	jp	z,_NPC22_collision_NORMAL	; bullet + subweap
	dec	a
	jp	z,_NPC22_collision_BULLET	; bullets
	;dec	a
	jp	_NPC22_collision_SUBWEAP	; subweap
	
_NPC22_collision_CONTINUE: 		
	jp	_NPC22_collision_MC		; MC collision only
_NPC22_collision_END: 



	;// MOVE 

	ld 	a,	(ix+_NPC_status)
	and	a
	jp	z, npc22_status0		; 0. Static X,Y
	dec	a
	jp	z, npc22_status1		; 1. Static Y, Var X
	dec	a
	jp	z, npc22_status2		; 2. Static x, Var y
	dec	a
	jp	z, npc22_status3		; 3. Var X,Y
	dec	a
	jp	z, npc22_status4		; 4. Static X (*1), Var Y * 2
	dec	a
	jp	z, npc22_status5		; 5. Static Y (*1), var Y * 2
	DEC	a
	jp	z,npc22_status6			; 6. Var X, Y * 2
	JP	npc22_status7			; 7. Fine Static X,Y (for eg homing) 	
	
	;====================
	; state 0
	;====================
npc22_status0:	
	ld	a,(ix+_NPC_y)			; in/decrease y
	add	a,(ix+_NPC_dy)
	ld	(ix+_NPC_y),a
		
	; out of screen?
	NPC22_Y_outside_screen
	
	ld	a,(ix+_NPC_x)			; in/decrease x
	add	a,(ix+_NPC_dx)
	ld	(ix+_NPC_x),a
		
	; out of screen?
	NPC22_X_outside_screen	
	
	; continue with collision detection and SAT placement
	jp	_NPC22_actiontimer
	
	;====================
	; state 1
	;====================
npc22_status1:	
	; static Y
	ld	a,(ix+_NPC_y)
	add	a,(ix+_NPC_dy)
	ld	(ix+_NPC_y),a
		
	; out of screen?
	NPC22_Y_outside_screen
	
	; var X
	ld	l,(ix+_NPC_dx)		; get pointer to lookuptable
	ld	h,high npc_path_data	; data is inside 256byte range
	
	ld	b,(hl)				; movement in b

	; is this the end of the movement data	
	ld	a,128
	cp	b
	jp	nz,1f

		; return to the start of the data
		inc	hl
		ld	b,(hl)
		ld	a,l
		sub	b
		ld	l,a
		; get new path value
		ld	b,(hl)
1:	
	inc	hl
	
	ld	(ix+_NPC_dx),l		; store pointer to lookuptable
	;ld	(ix+_NPC_dy),h	
	
	ld	a,(ix+_NPC_x)
	add	a,b
	ld	(ix+_NPC_x),a	
	
	; out of screen?
	NPC22_X_outside_screen	
	
	; continue with collision detection and SAT placement
	jp	_NPC22_actiontimer

	
	;====================
	; state 2 ; move down
	;====================
npc22_status2:	
	; var Y
	ld	l,(ix+_NPC_dy)		; get pointer to lookuptable
	ld	h,high npc_path_data	; data is inside 256byte range
	
	ld	b,(hl)				; movement in b

	; is this the end of the movement data	
	ld	a,128
	cp	b
	jp	nz,1f

		; return to the start of the data
		inc	hl
		ld	b,(hl)
		ld	a,l
		sub	b
		ld	l,a
		; get new path value
		ld	b,(hl)
1:		
	inc	hl
	
	ld	(ix+_NPC_dy),l		; store pointer to lookuptable
	;ld	(ix+_NPC_dy),h	
	
	ld	a,(ix+_NPC_y)
	add	a,b
	ld	(ix+_NPC_y),a	
			
	; out of screen?
	NPC22_Y_outside_screen	

	; static x
	ld	a,(ix+_NPC_x)
	add	a,(ix+_NPC_dx)
	ld	(ix+_NPC_x),a
	
	; out of screen?
	NPC22_X_outside_screen	
	
	; continue with collision detection and SAT placement
	jp	_NPC22_actiontimer

	;====================
	; state 3 ; move up
	;====================
npc22_status3:	
	; var Y
	ld	l,(ix+_NPC_dy)		; get pointer to lookuptable
	ld	h,high npc_path_data	; data is inside 256byte range
	
	ld	b,(hl)				; movement in b

	; is this the end of the movement data	
	ld	a,128
	cp	b
	jp	nz,1f

		; return to the start of the data
		inc	hl
		ld	b,(hl)
		ld	a,l
		sub	b
		ld	l,a
		; get new path value
		ld	b,(hl)
1:	
	inc	hl
	
	ld	(ix+_NPC_dy),l		; store pointer to lookuptable
	;ld	(ix+_NPC_dy),h	
	
	ld	a,(ix+_NPC_y)
	add	a,b
	ld	(ix+_NPC_y),a	
		
	; out of screen?
	NPC22_Y_outside_screen	
	
	; var X
	ld	l,(ix+_NPC_dx)		; get pointer to lookuptable
	ld	h,high npc_path_data	; data is inside 256byte range
	
	ld	b,(hl)				; movement in b

	; is this the end of the movement data	
	ld	a,128
	cp	b
	jp	nz,1f

		; return to the start of the data
		inc	hl
		ld	b,(hl)
		ld	a,l
		sub	b
		ld	l,a
		; get new path value
		ld	b,(hl)
1:	
	inc	hl
	
	ld	(ix+_NPC_dx),l		; store pointer to lookuptable
	;ld	(ix+_NPC_dy),h	
	
	ld	a,(ix+_NPC_x)
	add	a,b
	ld	(ix+_NPC_x),a	
	
	; out of screen?
	NPC22_X_outside_screen	
	
	; continue with collision detection and SAT placement
	jp	_NPC22_actiontimer

	;====================
	; state 4 ; CC down
	;====================
npc22_status4:	
	; static Y
	ld	a,(ix+_NPC_y)
	add	a,(ix+_NPC_dy)
	ld	(ix+_NPC_y),a
		
	; out of screen?
	NPC22_Y_outside_screen	
	
	; var X
	ld	l,(ix+_NPC_dx)		; get pointer to lookuptable
	ld	h,high npc_path_data	; data is inside 256byte range
	
	ld	b,(hl)				; movement in b

	; is this the end of the movement data	
	ld	a,128
	cp	b
	jp	nz,1f

		; return to the start of the data
		inc	hl
		ld	b,(hl)
		ld	a,l
		sub	b
		ld	l,a
		; get new path value
		ld	b,(hl)
1:	
	inc	hl
	
	ld	(ix+_NPC_dx),l		; store pointer to lookuptable
	;ld	(ix+_NPC_dy),h	
	
	ld	a,(ix+_NPC_x)
	add	a,b
	add	a,b
	ld	(ix+_NPC_x),a	
	
	; out of screen?
	NPC22_X_outside_screen	
	
	; continue with collision detection and SAT placement
	jp	_NPC22_actiontimer

	;====================
	; state 5 ; C top
	;====================
npc22_status5:
	; var Y
	ld	l,(ix+_NPC_dy)		; get pointer to lookuptable
	ld	h,high npc_path_data	; data is inside 256byte range
	
	ld	b,(hl)				; movement in b

	; is this the end of the movement data	
	ld	a,128
	cp	b
	jp	nz,1f

		; return to the start of the data
		inc	hl
		ld	b,(hl)
		ld	a,l
		sub	b
		ld	l,a
		; get new path value
		ld	b,(hl)
1:	
	inc	hl
	
	ld	(ix+_NPC_dy),l		; store pointer to lookuptable
	;ld	(ix+_NPC_dy),h	
	
	ld	a,(ix+_NPC_y)
	add	a,b
	add	a,b
	ld	(ix+_NPC_y),a	
			
	; out of screen?
	NPC22_Y_outside_screen	

	; static x
	ld	a,(ix+_NPC_x)
	add	a,(ix+_NPC_dx)
	ld	(ix+_NPC_x),a
	
	; out of screen?
	NPC22_X_outside_screen
	
	; continue with collision detection and SAT placement
	jp	_NPC22_actiontimer

	;====================
	; state 6 ; C down
	;====================
npc22_status6:	
	; var Y
	ld	l,(ix+_NPC_dy)		; get pointer to lookuptable
	ld	h,high npc_path_data	; data is inside 256byte range
	
	ld	b,(hl)				; movement in b

	; is this the end of the movement data	
	ld	a,128
	cp	b
	jp	nz,1f

		; return to the start of the data
		inc	hl
		ld	b,(hl)
		ld	a,l
		sub	b
		ld	l,a
		; get new path value
		ld	b,(hl)
1:	
	inc	hl
	
	ld	(ix+_NPC_dy),l		; store pointer to lookuptable
	;ld	(ix+_NPC_dy),h	
	
	ld	a,(ix+_NPC_y)
	add	a,b
	add	a,b
	ld	(ix+_NPC_y),a	
		
	; out of screen?
	NPC22_Y_outside_screen
	
	; var X
	ld	l,(ix+_NPC_dx)		; get pointer to lookuptable
	ld	h,high npc_path_data	; data is inside 256byte range
	
	ld	b,(hl)				; movement in b

	; is this the end of the movement data	
	ld	a,128
	cp	b
	jp	nz,1f

		; return to the start of the data
		inc	hl
		ld	b,(hl)
		ld	a,l
		sub	b
		ld	l,a
		; get new path value
		ld	b,(hl)
1:	
	inc	hl
	
	ld	(ix+_NPC_dx),l		; store pointer to lookuptable
	;ld	(ix+_NPC_dy),h	
	
	ld	a,(ix+_NPC_x)
	add	a,b
	add	a,b
	ld	(ix+_NPC_x),a	
	
	; out of screen?
	NPC22_X_outside_screen	
	
	; continue with collision detection and SAT placement
	jp	_NPC22_actiontimer





	;====================
	; state 7 ; fine move
	;====================
npc22_status7:	

	; Y movement

	ld	a,(ix+_NPC_ddy)
	cp	128
	jp	nc,0f
	
	; positive addition
	add a,(ix+_NPC_ly)
	ld (ix+_NPC_ly),a

	ld a,(ix+_NPC_y)
	adc a,(ix+_NPC_dy)
		
	jp	1f
	
0:	; negative addition
	neg
	add a,(ix+_NPC_ly)
	ld (ix+_NPC_ly),a
 
	ld a,(ix+_NPC_y)
	sbc	a,0
	add a,(ix+_NPC_dy)
	
1:	
	ld (ix+_NPC_y),a
	
	; out of screen?
	NPC22_Y_outside_screen	


	; x movement

	ld	a,(ix+_NPC_ddx)
	cp	128
	jp	nc,0f
	
	; positive addition
	add a,(ix+_NPC_lx)
	ld (ix+_NPC_lx),a

	ld a,(ix+_NPC_x)
	adc a,(ix+_NPC_dx)
		
	jp	1f
	
0:	; negative addition
	neg
	add a,(ix+_NPC_lx)
	ld (ix+_NPC_lx),a
 
	ld a,(ix+_NPC_x)
	sbc	a,0
	add a,(ix+_NPC_dx)
	
1:	
	ld (ix+_NPC_x),a

	; out of screen?
	NPC22_X_outside_screen

	
	; continue with collision detection and SAT placement
	jp	_NPC22_actiontimer




	;====================
	; Action timer
	;====================
_NPC22_actiontimer: 
	; decrease timer and get next status+action when timer==0
	dec	(ix+_NPC_timer)
	call	z,npc22_getnextmove
_NPC22_actiontimer_END: 

	;====================
	; Lock on for MC missiles
	;====================
_NPC22_locking:
	BIT	7,(ix+_NPC_subtype)		; bit 7; 0= no locking, 1 = locking.
	CALL	nz,locking			; NZ flag = bit is '1'.
	
	;====================
	; Bullet timer
	;====================
_NPC22_bullettimer:
	DEC	(ix+_NPC_counter)
	JP	z,_NPC22_castbullet
	JP	p,_NPC22_bullettimer_END
_NPC22_castbullet_FAIL:	
	INC	(ix+_NPC_counter)
_NPC22_bullettimer_END:



	;====================
	; Animation
	;====================	
_NPC22_animation:
	; check if we need to animate
	BIT	4,(ix+_NPC_subtype)		; bit 4; 0= no animation, 1 = animation.
	JP	z,_NPC22_animation_END		; bit is '0' do not animate.	
	
	; decrease the timer.
	DEC	(ix+_NPC_animationtimer)	
	JP	NZ,_NPC22_animation_END
	
	; timer reached zero.
	LD	l,(ix+_NPC_animationdata)
	LD	h,(ix+_NPC_animationdata+1)
	
	LD	d,ixh
	LD	e,ixl
	LD	a,_NPC_pattern
	ADD	a,e
	LD	e,a
	JP	nc,1f
	INC	d
1:
	; copy data into the pattern/color data
	ld	bc,4
	ldir
	
	ld	a,(hl)
	ld	(ix+_NPC_animationtimer),a

	; end of animation?
	inc	l
	ld	a,(hl)
	cp 	255
	jp	nz,2f				; next value is not 255 (loop)
	inc	l
	ld	l,(hl)				; set lowbyte to loop position

2:
	; store the new pointer for next animation step
	ld	(ix+_NPC_animationdata),l
	
	
_NPC22_animation_END:
	;====================
	; Copy to sat
	;====================
_NPC22_copy_to_sat:	
	BIT	6,(ix+_NPC_subtype)		; 1 = double/ 0 = single layer?
	JP	nz,npc_to_sat2
	JP	npc_to_sat


;///////////// END OF PROCESSING ///////////////





	;====================
	; Normal Collision
	;====================
_NPC22_collision_NORMAL:
	call 	normal_collision			; check bullets and subweapons for collision
	jp	nc,_NPC22_collision_MC			; no collision
	jp	_NPC22_collision_FOUND
	
	;====================
	; Bullet only Collision
	;====================
_NPC22_collision_BULLET:
	call 	bulletonly_collision			; check bullets and subweapons for collision
	jp	nc,_NPC22_collision_MC			; no collision
	jp	_NPC22_collision_FOUND
		
	;====================
	; Subweap only Collision
	;====================
_NPC22_collision_SUBWEAP:
	; not implemented yet
	HALT
	JP	_NPC22_collision_BULLET


_NPC22_collision_FOUND:
	;collision found
	ld	b,a					; set damage done in b
	ld	a,(ix+_NPC_hp)			
	sub	b					; subtract damge from hp
	jp	c,_NPC22_destroyed			; hp == -1 -> explosion!
	ld	(ix+_NPC_hp),a
	
	ld	a,b					; make the enemy flash.
	ld	(hitflash),a
	
	
	; =============
	; CHECK FOR ACTION ON HIT
	; =============
	ld	a,(ix+_NPC_hitjump)
	and 	a
	jp	z,_NPC22_collision_MC
	ld	(ix+_NPC_fx),a					; store low byte address
	
	ld	(ix+_NPC_hitjump),0
	
	call	npc22_getnextmove
	
	
	;jp 	_NPC22_collision_MC			; not killed.... continue


	;====================
	; MC Collision
	;====================	
_NPC22_collision_MC:
	CALL	mc_collision
	jp	nc,_NPC22_collision_END			; no collision
	
	; collision
	ld	a,(ix+_NPC_explosiontype)
	ld 	(ix+_NPC_type),a
	ld 	(ix+_NPC_status),0			; turn NPC into another npc (explosion?)
	
	BIT	5,(ix+_NPC_subtype)			; Hit the MC??
	JP 	z,_NPC22_collision_END			; bit 5 -> 0 do not hit	
		
	ld 	a,1					; set MC in hit state
	ld 	(myState),a	
	jp 	next_npc	


	;====================
	; NPC destroyed
	;====================	
_NPC22_destroyed:	
	ld	a,(ix+_NPC_explosiontype)
	ld 	(ix+_NPC_type),a
	ld 	(ix+_NPC_status),0			; turn NPC into another npc (explosion?)
	
	; add score.
	ld	c,(ix+_NPC_score)
	ld	b,(ix+_NPC_score+1)
	CALL	addScore
	
	jp 	next_npc				; process next npc
	; continue npc loop


	;====================
	; Cast Bullet
	;====================	
_NPC22_castbullet:		
	ld	b,(ix+_NPC_bullettype)
	call	init_npc
	jp	z,_NPC22_castbullet_FAIL	; this will increment the timer to triger next time

	; set position
	inc	hl
	ld	a,(ix+_NPC_y)
	ld	(hl),a
	inc	hl
	ld	a,(ix+_NPC_x)
	ld	(hl),a
	
	;reset bullet timer
	LD	a,(ix+_NPC_bulletretrigger)
	LD	(ix+_NPC_counter),a

	JP	_NPC22_bullettimer_END


	;====================
	; Get next move.
	;====================	
npc22_getnextmove:
	; get movement script pointer
	ld	l,(ix+_NPC_fx)
	ld	h,(ix+_NPC_fy)
npc22_getnextmove_again:	
	; get new action code
	ld	a,(hl)		; get action code
	inc	hl

	and	a
	jp	z,npc22_action0
	dec	a
	jp	z,npc22_action1
	dec	a
	jp	z,npc22_action2
	dec	a
	jp	z,npc22_action3
	dec	a
	jp	z,npc22_action4
	dec	a
	jp	z,npc22_action5
	dec	a
	jp	z,npc22_action6
	dec	a
	jp	z,npc22_action7
	dec	a
	jp	z,npc22_action8	
	dec	a
	jp	z,npc22_action9	
	dec	a
	jp	z,npc22_action10
	dec	a
	jp	z,npc22_action11
	dec	a
	jp	z,npc22_action12	
	jp	npc22_action13	

npc22_action0:
	; Static x,y
	ld	(IX+_NPC_status),0
	
	; get x movement

	ld	a,(hl)
	ld	(ix+_NPC_dx),a
	
	; get y movement
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_dy),a
	
	; get timer
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_timer),a

	inc	hl
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h
	
	ret
	
npc22_action1:	
	; Var x, Static y
	ld	(IX+_NPC_status),1
	
	; get x movement pointer

	ld	a,(hl)
	ld	(ix+_NPC_dx),a
	;inc	hl
	;ld	a,(hl)
	;ld	(ix+_NPC_dy),a		
	
	; get y movement
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_dy),a
	
	; get timer
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_timer),a

	inc	hl
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h
	
	ret	
	
npc22_action2:	
	; Static x, Var y
	ld	(IX+_NPC_status),2
	
	; get x movement

	ld	a,(hl)
	ld	(ix+_NPC_dx),a
	
	; get y movement pointer
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_dy),a
	;inc	hl
	;ld	a,(hl)
	;ld	(ix+_NPC_dy),a	
	
	; get timer
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_timer),a

	inc	hl
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h
	
	ret	

npc22_action3:
	; Var x, Var y
	ld	(IX+_NPC_status),3
	
	; get x movement pointer

	ld	a,(hl)
	ld	(ix+_NPC_dx),a
	inc	hl
	;ld	a,(hl)
	;ld	(ix+_NPC_dy),a	
	;inc	hl

	; get y movement pointer

	ld	a,(hl)
	ld	(ix+_NPC_dy),a
	;inc	hl
	;ld	a,(hl)
	;ld	(ix+_NPC_dy),a	
	
	
	; get timer
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_timer),a

	inc	hl
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h
	
	ret	
	
npc22_action4:
	; Var x (*2) , Static y (*1)
	ld	(IX+_NPC_status),4
	
	; get x movement pointer

	ld	a,(hl)
	ld	(ix+_NPC_dx),a
	;inc	hl
	;ld	a,(hl)
	;ld	(ix+_NPC_dy),a		
	
	; get y movement
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_dy),a
	
	; get timer
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_timer),a

	inc	hl
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h
	
	ret		

npc22_action5:
	; Static x, Var y (*2)
	ld	(IX+_NPC_status),5
	
	; get x movement
	ld	a,(hl)
	ld	(ix+_NPC_dx),a
	
	; get y movement pointer
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_dy),a
	;inc	hl
	;ld	a,(hl)
	;ld	(ix+_NPC_dy),a	
	
	; get timer
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_timer),a

	inc	hl
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h
	
	ret	

npc22_action6:
	; Var x, Var y
	ld	(IX+_NPC_status),6
	
	; get x movement pointer
	ld	a,(hl)
	ld	(ix+_NPC_dx),a
	inc	hl
	;ld	a,(hl)
	;ld	(ix+_NPC_dy),a
	;inc	hl	
	; get y movement pointer
	ld	a,(hl)
	ld	(ix+_NPC_dy),a
	;inc	hl
	;ld	a,(hl)
	;ld	(ix+_NPC_dy),a	
	
	; get timer
	inc	hl
	ld	a,(hl)
	ld	(ix+_NPC_timer),a

	inc	hl
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h
	
	ret	
npc22_action7:
	; set move fine static x,y	
	LD	(IX+_NPC_status),7
	
	LD	a,(hl)
	LD	(ix+_NPC_dx),a
	
	INC	hl
	LD	a,(hl)
	LD	(ix+_NPC_ddx),a	
	
;	LD	(ix+_NPC_lx),0
	
	INC	hl
	LD	a,(hl)
	LD	(ix+_NPC_dy),a
	
	INC	hl
	LD	a,(hl)
	LD	(ix+_NPC_ddy),a	
	
;	LD	(ix+_NPC_ly),0	
		
	INC	hl
	LD	a,(hl)
	LD	(ix+_NPC_timer),a		
	
	inc	hl
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h
	
	ret
npc22_action8:
	; set timer (no state update)
	ld	a,(hl)
	ld	(ix+_NPC_timer),a
	
	inc	hl
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h	
	
	ret
	
npc22_action9:
	; jump to a location (no status update)
	ld	a,(hl)
	ld	l,a
	ld	(ix+_NPC_fx),a

	jp	npc22_getnextmove_again
	
npc22_action10:
	; move x pos towards MC
	ld	a,(myX)
	and	0xFE
	ld	b,a
	
	ld	a,(ix+_NPC_x)
	
	cp	b
	
	ld	a,(ix+_NPC_dx)	; get dx before changing it . Flags are preserved
	jp	z,0f		; MC pos = NPC pos
	jp	nc,1f
	
	;move right
	CP	2
	JP	z,npc22_getnextmove_again
	
	INC	a
	LD	(ix+_NPC_dx),a	
	JP	npc22_getnextmove_again	
	;move left
1:	
	CP	-2
	JP	z,npc22_getnextmove_again
	
	DEC	a
	LD	(ix+_NPC_dx),a	
	JP	npc22_getnextmove_again	
	
0:
	LD	(ix+_NPC_dx),0
	
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h	
	
	
	JP	npc22_getnextmove_again	

npc22_action11:
	; aim NPC at MC

	ld	a,(hl)
	ld	(ix+_NPC_timer),a
	
	inc	hl
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h	
	
	
	; ddx,dx, ddy,dy     missile speed
	; +/-1, +/-1 		 missile acceleration 
	
	; initial speed
	ld a,(myX)
	sub a,(ix+_NPC_x)
	ld (ix+_NPC_ddx),a
	sbc	a,a
	ld	(ix+_NPC_dx),a		;DDX = HI byte, DX = LO byte

	; dy
	ld a,(myY)
	sub a,(ix+_NPC_y)
	ld (ix+_NPC_ddy),a
	sbc	a,a
	ld	(ix+_NPC_dy),a		;DDY = HI byte, DY = LO byte

	bit	7,(ix+_NPC_dx)
	ld	a,(ix+_NPC_ddx)
	jp	z,1f
	neg
1:	ld	b,a

	bit	7,(ix+_NPC_dy)
	ld	a,(ix+_NPC_ddy)
	jp	z,1f
	neg
1:	or	b

	RET	z					; MC is hit

333:
	rlca							; test bit 7 of (|DX| or |DY|)
	jp	c,1f
	sla	(ix+_NPC_ddx)
	sla	(ix+_NPC_ddy)
	jp	333b
1:


	repeat 3						; CHANGE HERE FOR TUNING BULLET SPEED
	sla (ix+_NPC_ddy)
	rl  (ix+_NPC_dy)

	sla (ix+_NPC_ddx)
	rl  (ix+_NPC_dx)
	endrepeat						; now we have max (|dx|,|dy|)<4


	LD	(ix+_NPC_status),7
	RET

npc22_action12:
	; move random x,y direction increment (max -2,2)
	ld	a,(hl)
	ld	(ix+_NPC_timer),a
	
	inc	hl
	ld	(ix+_NPC_fx),l
	ld	(ix+_NPC_fy),h	

	ld	(ix+_NPC_status),0
	; x movmement
	ld	a,r;(Seed)
	ld	b,a				; store Seed
	and	1
	jp	z,1f	; increase
	;decrease
		ld	a,(ix+_NPC_dx)
		cp	-2
		jp	z,3f			; nothing to do for x
		dec	a
		ld	(ix+_NPC_dx),a
		jp	3f
1:		
	;increase
		ld	a,(ix+_NPC_dx)
		cp	2
		jp	z,3f			; nothing to do for x
		inc	a
		ld	(ix+_NPC_dx),a
		;jp	3f	

3: ; y movement
	ld	a,b				; store Seed
	and	2
	jp	z,1f	; increase
	;decrease
		ld	a,(ix+_NPC_dy)
		cp	-2
		jp	z,3f			; nothing to do for x
		dec	a
		ld	(ix+_NPC_dy),a
		jp	3f
1:		
	;increase
		ld	a,(ix+_NPC_dy)
		cp	2
		jp	z,3f			; nothing to do for x
		inc	a
		ld	(ix+_NPC_dy),a
		;jp	3f	

3:
	ret

npc22_action13:
	; End the NPC
	ld	(ix+_NPC_type),0
	
	ret
