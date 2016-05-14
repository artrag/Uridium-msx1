	
ms_fly__right				equ	0
ms_spin_face_right			equ	1
ms_side_dwn_face_right		equ	2
ms_side_up__face_right		equ	3

ms_fly__left				equ	4
ms_spin_face_left			equ	5
ms_side_dwn_face_left		equ	6
ms_side_up__face_left		equ	7

ms_loop_right2left			equ	8
ms_loop_left2right			equ	9

ms_explode					equ	10
ms_landing					equ	11
ms_reset					equ	12

;%%%%%%%%%%%%%%%%%%%%%%
ms_ctrl:
	ld	a,(ms_state)
	cp	ms_explode-1		; ms cannot move while exploding landing or at level reset
	call	c,.ms_directions

.intro:
	ld	a,(ms_state)
	cp	ms_fly__right
	jp	z,.ms_fly__right
	
	cp	ms_loop_right2left
	jp	z,.ms_loop_right2left
	
	cp	ms_spin_face_left
	jp	z,.ms_spin_face_left
	
	cp	ms_fly__left
	jp	z,.ms_fly__left
	
	cp	ms_loop_left2right
	jp	z,.ms_loop_left2right

	cp	ms_spin_face_right
	jp	z,.ms_spin_face_right
	
	cp	ms_side_dwn_face_right
	jp	z,.ms_side_dwn_face_right

	cp	ms_side_up__face_right
	jp	z,.ms_side_up__face_right
	
	cp	ms_side_dwn_face_left
	jp	z,.ms_side_dwn_face_left

	cp	ms_side_up__face_left
	jp	z,.ms_side_up__face_left

	cp	ms_explode
	jp	z,.ms_explode
	
	cp	ms_landing
	jp	z,.ms_landing

	cp	ms_reset
	jp	z,.ms_reset
	
;	abnormal end
	ld	a,ms_fly__right
	ld	(ms_state),a
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	FAKE FOR TEST
.ms_landing	
.ms_reset 
	ret
	
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;	control X and Y 

.ms_directions:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; read joystick and keyboard
	call	.rd_joy
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; x speed control of the screen and of the main ship
    call    .right
    jr  nz,1f
    ld  a,(dxmap)
    cp  maxspeed        ; MAX SPEED
    jr  z,1f
    inc a
    ld  (dxmap),a
1:
    call    .left
    jr  nz,1f
    ld  a,(dxmap)
    cp  -maxspeed       ; MAX SPEED
    jr  z,1f
    dec a
    ld  (dxmap),a
1:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; y control of the main ship

    call    .up
    jr  nz,1f
    ld  a,(yship)
	add	a,-4
    cp  48+16
    jr  c,1f
    ld  (yship),a
1:
    call    .dwn
    jr  nz,1f
    ld  a,(yship)
	add	a,4
    cp  192-16+1
    jr  nc,1f
    ld  (yship),a
1:
	ret

	
; PSG I/O port A (r#14) – read-only
; Bit	Description	Comment
; 0	Input joystick pin 1	(up)
; 1	Input joystick pin 2	(down)
; 2	Input joystick pin 3	(left)
; 3	Input joystick pin 4	(right)
; 4	Input joystick pin 6	(trigger A)
; 5	Input joystick pin 7	(trigger B)
; 6	Japanese keyboard layout bit	(1=JIS, 0=ANSI)
; 7	Cassette input signal	

.rd_joy:
	ld	a,#0f
	out	(#a0),a
	ld	a,0x8F
	out	(#a1),a		; select port A
	ld	a,#0e
	out	(#a0),a
	in	a,(#a2)
.rd_key:	
	ld	ix,joystick
	ld	(ix),a
	
	ld  e,8
    call    checkkbd
	bit	0,a				; space
	jr	nz,1f
	res	4,(ix)			; (trigger A)
1:
	bit	7,a				; RIGHT
	jr	nz,1f
	res	3,(ix)			; (right joy)
1:
	bit	6,a				; DOWN
	jr	nz,1f
	res	1,(ix)			; (down joy)
1:
	bit	5,a				; UP
	jr	nz,1f
	res	0,(ix)			; (up joy)
1:
	bit	4,a				; LEFT
	jr	nz,1f
	res	2,(ix)			; (left joy)
1:
	ld  e,5
    call    checkkbd
	bit	5,a				; X
	jr	nz,1f
	res	5,(ix)			; (trigger B)
1:
	bit	7,a				; Z
	jr	nz,1f
	res	4,(ix)			; (trigger A)
1:
	ret

	
	
;    5   |    Z     Y     X     W     V     U     T     S
;    6   |   F3    F2    F1   CODE   CAP  GRAPH CTRL  SHIFT
;    7   |   RET   SEL   BS   STOP   TAB   ESC   F5    F4
;    8   |  RIGHT DOWN   UP   LEFT   DEL   INS  HOME  SPACE
.z_or_space:
	; ld  e,5
    ; call    checkkbd
	; and	128
	; ret	z
	; ld  e,8
    ; call    checkkbd
	; and	1		; z || SPACE
	ld	a,(joystick)
	and	16
	ret
.x_and_up:
	; ld  e,5
    ; call    checkkbd
	; and	32
	ld	a,(joystick)
	and	32
	ret	nz
.up:
	; ld  e,8
    ; call    checkkbd
	; and	32		; X & UP
	ld	a,(joystick)
	and	1
	ret
.x_and_dwn:
	; ld  e,5
    ; call    checkkbd
	; and	32
	ld	a,(joystick)
	and	32
	ret	nz
.dwn:
	; ld  e,8
    ; call    checkkbd
	; and	64		; X & DWN
	ld	a,(joystick)
	and	2
	ret
.left:
	; ld  e,8
    ; call    checkkbd
	; and	16
	ld	a,(joystick)
	and	4
	ret
.right:
	; ld  e,8
    ; call    checkkbd
	; and	128
	ld	a,(joystick)
	and	8
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ms_fly__right:		
	ld  a,(dxmap)
	bit	7,a
	jr z,1f
	
	xor	a
	ld  (aniframe),a
	ld	a,ms_loop_right2left
	ld	(ms_state),a
	ret
1:
	ld	a,32
	ld  (aniframe),a
	call	.x_and_up
	jp	nz,1f
	ld	a,32
	ld  (aniframe),a
	ld	a,ms_side_up__face_right
	ld	(ms_state),a
	ret
1:	call	.x_and_dwn
	jp	nz,1f
	ld	a,40
	ld  (aniframe),a
	ld	a,ms_side_dwn_face_right
	ld	(ms_state),a
	ret
1:	call	.left
	jp	nz,1f
	xor	a
	ld  (aniframe),a
	ld	a,ms_loop_right2left
	ld	(ms_state),a
	ret
1:	call	.z_or_space
	jp		z,ms_shoot
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ms_loop_right2left:
	ld	a,(aniframe)
	inc	a
	ld	(aniframe),a
	cp	4
	jp	z,1f
	cp	8
	ret	nz
	ld	a,ms_spin_face_left
	ld	(ms_state),a
	ret
1:	xor	a
    ld  (dxmap),a
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ms_spin_face_left:
	call	.z_or_space
	call	z,ms_shoot
	ld	a,(aniframe)
	inc	a
	ld	(aniframe),a
	cp	16
	ret	nz
	ld	a,ms_fly__left
	ld	(ms_state),a
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ms_fly__left:
	ld  a,(dxmap)
	dec	a
	bit	7,a
	jr nz,1f
	
	ld	a,16
	ld  (aniframe),a
	ld	a,ms_loop_left2right
	ld	(ms_state),a
	ret	
1:
	ld	a,48
	ld  (aniframe),a
	call	.x_and_up
	jp	nz,1f
	ld	a,48
	ld  (aniframe),a
	ld	a,ms_side_up__face_left
	ld	(ms_state),a
	ret
1:	call	.x_and_dwn
	jp	nz,1f
	ld	a,56
	ld  (aniframe),a
	ld	a,ms_side_dwn_face_left
	ld	(ms_state),a
	ret
1:	call	.right
	jp	nz,1f
	ld	a,16
	ld  (aniframe),a
	ld	a,ms_loop_left2right
	ld	(ms_state),a
	ret
1:	call	.z_or_space
	jp		z,ms_shoot
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ms_loop_left2right:
	ld	a,(aniframe)
	inc	a
	ld	(aniframe),a
	cp	20
	jp	z,1f
	cp	24
	ret	nz
	ld	a,ms_spin_face_right
	ld	(ms_state),a
	ret
1:	xor	a
    ld  (dxmap),a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ms_spin_face_right:
	call	.z_or_space
	call	z,ms_shoot
	ld	a,(aniframe)
	inc	a
	ld	(aniframe),a
	cp	32
	ret	nz
	ld	a,ms_fly__right
	ld	(ms_state),a
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ms_side_dwn_face_right:
	call	.z_or_space
	call	z,ms_shoot
	ld	a,(aniframe)
	cp	44
	jp	z,1f

	inc	a
	ld	(aniframe),a
	cp	47
	ret	nz
	ld	a,32
	ld	(aniframe),a
	ld	a,ms_fly__right
	ld	(ms_state),a
	ret
1:	ld  a,(dxmap)
	bit	7,a
	jr nz,1f
	call	.x_and_up
	jp		z,1f
	call	.left
	ret	nz
1:	ld	a,45
	ld	(aniframe),a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ms_side_up__face_right	
	call	.z_or_space
	call	z,ms_shoot
	ld	a,(aniframe)
	cp	36
	jp	z,1f

	inc	a
	ld	(aniframe),a
	cp	40
	ret	nz
	ld	a,32
	ld	(aniframe),a
	ld	a,ms_fly__right
	ld	(ms_state),a
	ret
1:	ld  a,(dxmap)
	bit	7,a
	jr nz,1f
	call	.x_and_dwn
	jp		z,1f
	call	.left
	ret	nz
1:	ld	a,37
	ld	(aniframe),a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ms_side_dwn_face_left	
	call	.z_or_space
	call	z,ms_shoot
	ld	a,(aniframe)
	cp	60
	jp	z,1f

	inc	a
	ld	(aniframe),a
	cp	63
	ret	nz
	ld	a,48
	ld	(aniframe),a
	ld	a,ms_fly__left
	ld	(ms_state),a
	ret
1:	ld  a,(dxmap)
	dec	a
	bit	7,a
	jr z,1f
	call	.x_and_up
	jp		z,1f
	call	.right
	ret	nz
1:	ld	a,61
	ld	(aniframe),a
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ms_side_up__face_left	
	call	.z_or_space
	call	z,ms_shoot
	ld	a,(aniframe)
	cp	52
	jp	z,1f

	inc	a
	ld	(aniframe),a
	cp	56
	ret	nz
	ld	a,48
	ld	(aniframe),a
	ld	a,ms_fly__left
	ld	(ms_state),a
	ret
1:	ld  a,(dxmap)
	dec	a
	bit	7,a
	jr z,1f
	call	.x_and_dwn
	jp		z,1f
	call	.right
	ret	nz
1:	ld	a,53
	ld	(aniframe),a
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.ms_explode:
	ld	a,(anispeed)
	inc	a
	and	3
	ld	(anispeed),a
	ret nz
	ld	a,(aniframe)
	inc	a
	ld	(aniframe),a
	cp	80
	ret	nz
	xor	a
	ld	(yship),a
	call	put_ms_sprt.expl
	ld	a,ms_reset
	ld	(ms_state),a
	
	ld	c,1						; show lives on screen 
	call	sub_c_lives_bin
	
	ld	a,-1
	ld	(already_dead),a	; reset at level start, set after you die

	ld	a,(lives_bin)
	and	a
	ret	nz
		
	call	PT3_MUTE
	ld	a,19			; game over
	call AFXPLAY
	
	ld	hl,GameOver
	ld	de,0x1C00+8*3*32
	call	print_strf
	ld	b,0
1:	halt	
	djnz	1b

	; you've lost 
	pop af
	jp	title_screen

	

