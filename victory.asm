
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; typewriter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
greetings:
	db	"CONGRATULATIONS PILOT!!",13
	db	"You saved our solar system",13
	db	"from the Dreadnoughts menace",13
	db	"for now at least...",13
greetings1:
	db	"They will return.",13
	db	"But for that time",13
	db	"you will need an MSX2",13
	db	"to defeat them.",13
greetings2:
	db	   "a last note...",13
	db	"Now you can select God mode.",13
	db	"Next time, try to boot",13
	db	"while ESC is pressed...",13
	
_cls:
	_setvdpwvram 0x1A00
	xor	a
	ld	b,a
111:	
	out	(0x98),a
	nop
	djnz 111b
	ret

victory_text2:
	ei
	halt
	di
	call _cls
	ld	de,greetings2
	ld	hl,0x1800+32*17+8
	call	prstr
	ld	hl,0x1800+32*19+2
	call	prstr
	ld	hl,0x1800+32*21+5
	call	prstr
	ld	hl,0x1800+32*23+5
	call	prstr
	ret

	

victory_text:	
	di
	_setvdpwvram 0x1000
	ld	hl,ram_tileset
	call	write_256
	
	; set colours
	_setvdpwvram 0x3000
	ld	bc,0x0001
1:	ld	a,0x51
	call	set4
	ld	a,0x41
	call	set4
	djnz	1b
	dec	c
	jr	nz,1b

	call _cls
	
	ld	de,greetings
	; ld	hl,0x1800+32*16+5
	ld	hl,0x1800+32*17+5
	call	prstr
	; ld	hl,0x1800+32*17+3
	ld	hl,0x1800+32*19+3
	call	prstr
	; ld	hl,0x1800+32*18+2
	ld	hl,0x1800+32*21+2
	call	prstr
	; ld	hl,0x1800+32*19+7
	ld	hl,0x1800+32*23+7
	call	prstr
	ret
	
victory_text1:
	call _cls	
	ld	de,greetings1	
	ld	hl,0x1800+32*17+8
	; ld	hl,0x1800+32*20+8
	call	prstr
	ld	hl,0x1800+32*19+8
	; ld	hl,0x1800+32*21+8
	call	prstr
	; ld	hl,0x1800+32*22+6
	ld	hl,0x1800+32*21+6
	call	prstr
	; ld	hl,0x1800+32*23+8
	ld	hl,0x1800+32*23+8
	call	prstr
	ret


wait_music_or_key:	

1:	call	joy_read
	bit	4,a
	ret	nz			; end at key pressed
	halt
	ld	a,(PT3_SETUP)
	and	128
	ret nz 			; when music ends or loops
	jr	1b
	
wait_time_or_key:	
	ld	bc,10*60
wait_time_or_key_bc:
1:	push	bc
	halt
	call	joy_read
	bit	4,a
	pop	bc
	ret	nz			; end at key pressed
	dec	bc			; end after 10 secs
	ld	a,b
	or	c
	jr	nz,1b
	ret