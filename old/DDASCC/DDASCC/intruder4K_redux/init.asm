;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert a byte to ascii
; 
; in l input 
; in de pointer to output

Num2asc:
            ld  a,$17
            call Num1
Num2asc2:
            ld  a,l
            rrca
            rrca
            and $03
            call Num1
            ld  a,11
            call Num1
            ld  a,l
            and $03
            call Num1
            ld  a,$17
Num1:
            add a,$f1
            ld  (de),a
            inc de
            ret
            
            
    IF 1
Num2ascN:
            ld  h,0
            ld  bc,-10
            call    Num1N
            ld  c,-1

Num1N:       ld  a,$f0-1  ; '0' in the tileset

Num2N:       inc a
            add hl,bc
            jr  c,Num2N
            sbc hl,bc
        
            ld  (de),a
            inc de
            ret
    ENDIF
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

zeros:
              ld  b,32-16
              xor   a
1:            out (c),a
              djnz     1b
              dec d
              ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GENERAL INITIALIZIATION

INIT:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; screen init
;
              ld    a,15
              ld    (forclr),a
              ld    hl,0101h	 ; COLOR ,1,1
              ld    (bakclr),hl

              xor a
              ld  (0F3DBh),a     ; key clik off
              ld  (0F3DEh),a     ; KEY OFF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Opening screen
;

              ld   a,r
              and 15
              ld  (endroom+1),a    ;   select the room where the switch is

              call opening

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

              ld a,1
              call 05Fh          ; screen 1

              call bold_font
  
              ld   a,(RG1SAV)
              or   2
              ld   b,a
              ld   c,1
              call wrtvdp        ; sprites 16x16 mag

              ld      bc,(seed+1)
              ld      c,7
              call wrtvdp        ; color ,0,seed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Tileset = 1 tile

              ld a,255
              ld bc,8
              push bc
              ld hl,01Ch*8
              call filvrm       ; FOG

              pop bc
              ld hl,08h*8
              call filvrm       ; WALLS

              ld   hl,PCT + 1
              ld   a,0x41
              call wrtvrm      ; color for tiles 8-15 - WALLS

;   digits
              ld      hl,PCT + DIGITS/8
              ld      a,0xf4
              ld      bc,2
              call    filvrm      ; color for the DIGITS

;   switch
              ld      hl,switchoff
              ld      de,0x0000+SWITCH*8
              ld      bc,0x08
              call    ldirvm

              ld      hl,PCT + SWITCH/8
              ld      a,0xD1
              call    wrtvrm      ; color for the SWITCH
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Explosion        frames 0 - 3
;
              halt
              ld    hl,SPT
              call  setwrt   ; set sprites

              ld    hl,explosion
              ld    bc,4*32*256+98h
              otir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; bullet           frame 4
;
              ld  a,011000000b
              out (0x98),a
              out (0x98),a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MC & NPC sprites
              halt
              ld    hl,SPT+14*32
              call  setwrt   ; set sprites

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NPC sprites      frames 14 - 29
;
              ld    hl,npc_sprites
              ld    d,16

2:            ld    bc,4*256+98h
              otir
              ld    b,5
3:            dec hl
              outi
              jr nz,3B
              outi
              ld    b,4
3:            dec hl
              outi
              jr nz,3B
              outi
              outi

              call zeros
              jp  nz,2b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MC sprites right,frames 30 - 37
;
              halt

              ld    hl,newmc
              ld    d,5;8

2:            ld    b,16
3:            ld    a,(hl)
              inc   hl

              ld    e,1
rot:          rrca
              rl    e
              jr    nc,rot

              out (c),e
              djnz 3b

              call zeros
              jp  nz,2b

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MC sprites left,frames 38-45
;
              halt

              ld    hl,SPT+38*32
              call  setwrt   ; set sprites

              ld    hl,newmc
              ld    d,5;8

2:            ld    b,16
              otir

              call zeros
              jp  nz,2b


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RAM INIT

RINIT:
              xor  a
              ld   hl,endProgram
              ld   bc,endData-endProgram

FILLRAM:
        ; --- FILL RAM ---
		; --- A = Value to fill ---
		; --- HL = Origin ---
		; --- BC = Length ( -1 ) ---

              ld	(hl),a		    ; Write a
              ld	d,h				; d = h
              ld	e,l				; de = hl
              inc	de				; de = hl + 1
              ldir					; Copy
              ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite data
;
explosion:
              include "explosion.asm"
newmc:
              include "mc_sprites.asm"
npc_sprites:
              include "npc_sprites.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; tile data
;
switch:
              include "switch.asm"              
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OPENING SCREEN
;
opening:
              ld a,1
              call chgmod          ; screen 1

              call bold_font
                            
;              ld      de,0x300
;              ld      hl,char_data
;              ld      bc,char_data_size
;              call    ldirvm
;              
;              ld      de,0x200c
;              ld      hl,char_color
;              ld      bc,char_color_size
;              call    ldirvm

              ld    hl,0
              ld    bc,32*8
              xor   a
              call  filvrm

;              ld    hl,0x1800+0x20*23
;              call    setwrt   
;              ld    b,32
;              xor   a
;1:            out   (0x98),a
;              inc   a
;              djnz 1b

              ld  a,(level)
              or  0
              jr  z,1f
              
              ld      de,0x1800+0x20*12+11
              ld      hl,lvl
              ld      bc,0x07
              call    ldirvm
            
              ld  a,(level)
              ld    l,a
              ld    de,dummy
              call  Num2ascN
              ld    a,(dummy)
              cp    240
              jr    z,3f
              out (0x98),a
3:            ld    a,(dummy+1)
              out (0x98),a
1:
               
              ld  a,(level)
              or  0
              jr  nz,1f           ; print "game over" only when in level 0
              
              ld      de,0x1800+0x20*15+12
              ld      hl,gameover
              ld      bc,0x09
              call    ldirvm
              
1:
              ld      de,0x1800+0x20*18+6
              ld      hl,prssky
              ld      bc,0x14
              call    ldirvm

              ld      de,0x1800+0x20*20+8
              ld      hl,gotoroom
              ld      bc,0x0e
              call    ldirvm

              ld  a,(endroom+1)
              ld    l,a
              ld    de,dummy
              call  Num2asc2
              ld    a,(dummy)
              out (0x98),a
              ld    a,(dummy+1)
              out (0x98),a
              ld    a,(dummy+2)
              out (0x98),a

1:
              ld      a,8
              call    0141h
              bit     0,a        ; fire 1
              ret     z
              jr      1b

;              ld      hl,0x1840
;              call    setwrt   
;              
;              ld      hl,titles
;              ld      bc,0x0098         
;1:            halt
;              exx
;              ld      a,8
;              call    0141h
;              bit     0,a        ; fire 1
;              jr      z,2f
;              exx
;              outi
;              jr      nz,1b
;            
;2:
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;; Vacia el buffer (256 bytes)
;
;            ld hl,BUFFER
;            xor a
;            ld b,a
;_CLEAR:
;            ld (hl),a
;            inc hl
;            djnz _CLEAR
;
;           
;_RESTART:
;            ld hl,TEXT ; comienzo del texto del scroll
;_SCROLLER:
;            ld      a,8
;            call    0141h
;            bit     0,a        ; fire 1
;            ret     z
;
;            ld de,BUFFER+32*8   ; guarda la dirección de la columna "32"
;            ld a,(hl)           ; carga el siguiente caracter a imprimir
;            inc hl
;            cp 27               ; es el codigo ASCII 27
;            jr z,_RESTART       ; si es cierto, reinicia el scroll
;            push hl             ; si no lo es...
;            ld l,a
;            ld h,0
;            add hl,hl
;            add hl,hl
;            add hl,hl
;            ld bc,endData-32*8
;;;            ld bc,0x1bbf-32*8
;            add hl,bc           ; ...calcula la posicion en la fuente de los datos del caracter...
;            ld bc,8
;            ldir                ; ...y los vuelca a la columna virtual que queda fuera de pantalla (la 32)
;            
;            ld b,8              ; repetiremos el scroll 8 veces hasta que un caracter haya sido desplazado fuera de pantalla
;_SCROLL:
;            push bc
;
;            halt                ; sincroniza con el vblank
;_WAIT:
;            ld hl,0
;            call setwrt         ; prepara para escritura el VDP al inicio de la ultima fila de caracteres 
;            
;            ld hl,BUFFER
;            push hl
;            ld c,98h
;            ld b,0
;_OUT_LOOP:
;            outi
;            jr  nz,_OUT_LOOP
;;            otir                ; vuelca del buffer a la VRAM 256 bytes
;            pop de              ; DE=BUFFER
;            ld hl,BUFFER-8
;            ld bc,256+8         ; repetimos tantas veces como bytes tenemos en el buffer
;_SHIFT:
;            ld a,(de)           ; cargamos un byte de un caracter
;            sla a               ; lo desplazamos a la izquierda a traves del carry
;            ld (de),a           ; y lo volvemos a dejar en su sitio
;            ld a,0              ; ¡importante!, A debe ser 0 pero no podemos modificar el contenido del carry
;            rla                 ; rotamos a la izquierda A a traves del carry, introducimos el bit que desplazamos anteriormente
;            or (hl)             ; lo mezclamos con el byte que esta a su "izquierda"
;            ld (hl),a           ; y lo dejamos tambien en su sitio
;            inc hl              ; nos posicionamos en los siguientes caracteres
;            inc de
;            dec bc
;            ld a,b
;            or c                ; hemos acabado
;            jr nz,_SHIFT        ; si no repetimos
;
;            pop bc
;            djnz _SCROLL        ; repetimos hasta sacar un caracter fuera de pantalla
;
;            pop hl
;            jr _SCROLLER
;



bold_font:
	    ;; ----------------------------
	    ;; Create bold font
	    ;; ----------------------------
	    ld      bc,$0400
	    ld      de,endData
	    ld      hl,$0000
	    call    ldirmv

	    ld      hl,endData
	    ld      b,$0
_blod_font_loop:

	    ld      a,(hl)
	    rrca
	    or      (hl)
	    ld      (hl),a
        inc     hl
	    ld      c,a
   	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    or      c
	    ld      (hl),a
	    inc     hl
   	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    ld      (hl),a
	    inc     hl
   	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    ld      (hl),a
	    inc     hl
   	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    ld      (hl),a
	    inc     hl

	    inc     hl
   	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    ld      (hl),a
	    dec     hl
        ld      c,a
   	
	    ld      a,(hl)
	    rrca
	    or      (hl)
	    or      c
	    ld      (hl),a
	    inc     hl
   	
	    inc     hl
   	
	    xor     a
	    ld      (hl),a	
	    inc     hl
   	
        djnz    _blod_font_loop

        ld      de,$0000
        ld      hl,endData
        ld      bc,$0400
        call    ldirvm
        
        ld      de,$0780
        ld      hl,endData+$180
        ld      bc,$0080
        call    ldirvm
        
        ld      de,$07d0
        ld      hl,endData+$240
        ld      bc,$0010
        call    ldirvm
        
        ld      de,$07e0
        ld      hl,endData+$1d0
        ld      bc,$0010
        call    ldirvm
        
        ld      de,$07e8
        ld      hl,endData+$280
        ld      bc,$0010
        call    ldirvm
        
        ld      de,$07f0
        ld      hl,endData+$298
        ld      bc,$0010
        call    ldirvm
        
        ret

;;----------------------------------------------
;; SCROLLER TEXT
;; Use ASCII code 27 (ESC) to define end
;;----------------------------------------------
;TEXT:
;            db "find the switch in the maze that controls the self destruction of the mad robots "
;            db "                                ",27


;------------------------------
;
;char_color:
;    db  $f1,$f1,$f1,$f1,$f1,$f1,$f1,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f5,$f5,$fe,$f1,$f1
;char_color_size: equ $ - char_color
;
;char_data:
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $00,$00,$00,$00,$00,$01,$03,$03
;    db  $00,$00,$00,$00,$00,$ff,$ff,$ff
;    db  $00,$00,$00,$00,$00,$3f,$ff,$ff
;    db  $00,$00,$00,$00,$00,$ef,$ff,$ff
;    db  $00,$00,$00,$00,$00,$cf,$ff,$ff
;    db  $00,$00,$00,$00,$00,$fe,$ff,$ff
;    db  $00,$00,$00,$00,$00,$01,$c3,$e7
;    db  $00,$00,$00,$00,$00,$f3,$ff,$ff
;    db  $00,$00,$00,$00,$00,$7f,$ff,$ff
;    db  $00,$00,$00,$00,$00,$f7,$ff,$ff
;    db  $00,$00,$00,$00,$00,$c0,$f0,$f8
;    db  $00,$00,$00,$00,$00,$fc,$ff,$ff
;    db  $00,$00,$00,$00,$00,$00,$00,$80
;    db  $03,$03,$03,$03,$01,$00,$00,$00
;    db  $c0,$c0,$e0,$e0,$e0,$e0,$e0,$e0
;    db  $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
;    db  $c0,$c0,$80,$00,$80,$c0,$e0,$e0
;    db  $00,$00,$00,$00,$01,$03,$03,$03
;    db  $03,$03,$01,$00,$00,$00,$00,$00
;    db  $ff,$ff,$ff,$00,$00,$00,$00,$00
;    db  $ff,$ff,$3f,$00,$00,$00,$00,$00
;    db  $ff,$fc,$f0,$00,$00,$00,$00,$00
;    db  $ff,$ff,$7f,$00,$00,$00,$00,$00
;    db  $c7,$c7,$83,$00,$00,$00,$00,$00
;    db  $ff,$ff,$fe,$00,$00,$00,$00,$00
;    db  $ff,$3f,$1f,$00,$00,$00,$00,$00
;    db  $ff,$ff,$ff,$07,$0f,$1f,$3f,$7f
;    db  $fb,$f1,$e0,$00,$00,$ff,$ff,$ff
;    db  $ff,$ff,$ff,$00,$00,$c0,$e0,$e0
;    db  $f8,$f0,$c0,$00,$00,$00,$00,$00
;    db  $ff,$fe,$fc,$00,$00,$00,$00,$00
;    db  $ff,$7f,$1f,$00,$00,$00,$00,$00
;    db  $fc,$e0,$00,$00,$00,$00,$00,$00
;    db  $00,$01,$01,$00,$00,$00,$00,$00
;    db  $ff,$ff,$ff,$ff,$01,$01,$01,$00
;    db  $e0,$c0,$c0,$80,$80,$80,$00,$00
;    db  $00,$00,$01,$03,$03,$07,$07,$07
;    db  $e0,$e0,$e0,$c0,$80,$00,$00,$00
;    db  $07,$03,$03,$01,$01,$01,$00,$00
;    db  $ff,$ff,$ff,$ff,$80,$80,$80,$00
;    db  $00,$80,$80,$00,$00,$00,$00,$00
;    db  $0f,$00,$00,$00,$00,$00,$00,$00
;    db  $ff,$07,$07,$03,$00,$00,$00,$00
;    db  $ff,$ff,$ff,$ff,$00,$00,$00,$00
;    db  $00,$00,$00,$80,$00,$00,$00,$00
;    db  $07,$07,$07,$07,$07,$07,$03,$01
;    db  $00,$80,$c0,$e0,$e0,$f0,$f0,$f0
;    db  $00,$00,$00,$01,$00,$00,$00,$00
;    db  $ff,$e0,$e0,$c0,$00,$00,$00,$00
;    db  $f0,$00,$00,$00,$00,$00,$00,$00
;    db  $1f,$1f,$0f,$00,$00,$00,$00,$00
;    db  $ff,$f9,$f0,$00,$00,$00,$00,$00
;    db  $f0,$f0,$e0,$00,$00,$00,$00,$00
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $c0,$c0,$f0,$f0,$f0,$f0,$f0,$f0
;    db  $01,$01,$07,$07,$07,$07,$07,$07
;    db  $c0,$c0,$f0,$f8,$f8,$fc,$fc,$f8
;    db  $03,$03,$01,$01,$00,$00,$00,$00
;    db  $80,$80,$e0,$e0,$f1,$f1,$71,$31
;    db  $30,$30,$70,$f0,$f0,$f0,$f0,$f1
;    db  $00,$00,$00,$40,$c0,$c0,$c0,$c0
;    db  $00,$00,$00,$08,$0c,$0c,$0c,$0e
;    db  $30,$30,$3c,$3c,$3c,$3c,$3c,$3c
;    db  $01,$01,$01,$01,$01,$01,$01,$01
;    db  $01,$00,$80,$c0,$c0,$c0,$c0,$c0
;    db  $fe,$7e,$3f,$3f,$1f,$1f,$1f,$1f
;    db  $00,$00,$80,$80,$80,$80,$80,$80
;    db  $0c,$0c,$3f,$3f,$3f,$3f,$3f,$3f
;    db  $01,$01,$07,$07,$8f,$8f,$8f,$8f
;    db  $80,$80,$e0,$e0,$e0,$e0,$e0,$e0
;    db  $08,$08,$0c,$0e,$0e,$0e,$0e,$0e
;    db  $7f,$1f,$0f,$07,$03,$01,$01,$00
;    db  $04,$04,$06,$07,$07,$07,$07,$07
;    db  $03,$03,$03,$83,$c3,$e3,$e3,$1f
;    db  $0f,$03,$01,$01,$00,$00,$00,$00
;    db  $f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0
;    db  $07,$07,$07,$07,$07,$07,$07,$07
;    db  $f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8
;    db  $00,$80,$80,$c0,$c0,$e0,$f0,$f0
;    db  $11,$11,$01,$09,$07,$03,$03,$01
;    db  $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
;    db  $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
;    db  $fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc
;    db  $c0,$c0,$c0,$01,$01,$80,$c0,$c0
;    db  $3f,$3f,$7f,$ff,$ff,$7f,$3f,$1f
;    db  $80,$80,$80,$80,$80,$80,$80,$80
;    db  $3f,$3f,$3f,$3f,$3f,$3f,$3f,$3f
;    db  $8f,$8f,$8f,$8f,$8f,$8f,$8f,$8f
;    db  $e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0
;    db  $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e
;    db  $00,$00,$00,$00,$00,$00,$00,$01
;    db  $07,$06,$04,$04,$04,$06,$07,$07
;    db  $1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f
;    db  $0e,$0e,$0e,$08,$08,$0c,$0e,$0e
;    db  $01,$01,$03,$0f,$0f,$03,$01,$00
;    db  $f0,$f0,$f0,$f0,$f0,$f0,$c0,$c0
;    db  $07,$07,$07,$07,$07,$07,$01,$01
;    db  $f8,$f8,$f8,$f8,$f8,$f0,$c0,$c0
;    db  $f8,$f8,$fc,$fc,$fe,$7f,$1f,$1f
;    db  $01,$01,$01,$01,$01,$01,$01,$81
;    db  $c0,$c0,$c0,$c0,$c0,$c0,$00,$00
;    db  $0f,$0f,$0f,$0f,$0f,$0f,$03,$03
;    db  $fc,$fc,$fc,$fc,$fc,$fc,$f0,$f0
;    db  $01,$01,$01,$01,$01,$01,$00,$00
;    db  $c0,$c0,$c0,$c0,$c0,$cf,$7f,$ff
;    db  $1f,$1f,$1f,$1f,$03,$e3,$f7,$ff
;    db  $80,$80,$80,$80,$c0,$ff,$ff,$ff
;    db  $3f,$3f,$3f,$3f,$3f,$fe,$fe,$ff
;    db  $8f,$8f,$8f,$0f,$1f,$1f,$3f,$7f
;    db  $e0,$e0,$e0,$e0,$e0,$e0,$80,$80
;    db  $0e,$0e,$0e,$0e,$0e,$0c,$08,$08
;    db  $01,$01,$03,$03,$07,$0f,$1f,$7f
;    db  $07,$07,$07,$07,$07,$06,$00,$00
;    db  $e3,$e3,$c3,$c3,$83,$03,$03,$03
;    db  $0e,$0e,$0e,$0e,$0e,$0e,$03,$03
;    db  $00,$00,$00,$00,$00,$00,$00,$c0
;    db  $ff,$ff,$ff,$0f,$0f,$0f,$1f,$ff
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $f0,$e0,$c0,$80,$80,$00,$00,$80
;    db  $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f
;    db  $00,$00,$c0,$c0,$c0,$c0,$c0,$c0
;    db  $07,$07,$1f,$1f,$1f,$1f,$1f,$1f
;    db  $f8,$f0,$e1,$e3,$c7,$8f,$1f,$1f
;    db  $80,$80,$80,$80,$80,$80,$80,$80
;    db  $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
;    db  $1c,$1c,$1f,$1e,$1e,$1c,$10,$00
;    db  $00,$00,$07,$1f,$1f,$3f,$1f,$1f
;    db  $3f,$00,$00,$ff,$ff,$ff,$fe,$fe
;    db  $80,$00,$00,$80,$80,$80,$00,$00
;    db  $7f,$0f,$0f,$7f,$7f,$7f,$1f,$1f
;    db  $c0,$c0,$c0,$c0,$c0,$80,$00,$00
;    db  $00,$10,$10,$18,$18,$1c,$00,$00
;    db  $0f,$0f,$07,$07,$03,$03,$00,$00
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $ff,$80,$00,$00,$ff,$00,$00,$f0
;    db  $ff,$00,$00,$00,$ff,$00,$00,$00
;    db  $ff,$00,$00,$00,$ff,$01,$01,$01
;    db  $ff,$00,$00,$00,$ff,$80,$80,$80
;    db  $ff,$01,$00,$00,$ff,$00,$00,$0f
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;    db  $00,$00,$00,$00,$00,$00,$00,$00
;char_data_size: equ $ - char_data


;titles:
;    db  $60,$60,$60,$61,$62,$62,$63,$62,$62,$64,$62,$62,$65,$66,$62,$67,$62,$68,$66,$69,$6a,$6b,$69,$62,$6c,$69,$6a,$6c,$6d,$60,$60,$60
;    db  $60,$60,$60,$6e,$98,$99,$9a,$9b,$9c,$9d,$9e,$9f,$a0,$a1,$a2,$a3,$a4,$a5,$a6,$a7,$a8,$a9,$98,$aa,$ab,$a7,$a8,$ac,$6f,$60,$60,$60
;    db  $60,$60,$60,$60,$ad,$ae,$af,$b0,$b1,$70,$b2,$b3,$b4,$a1,$b5,$b6,$b7,$b8,$b9,$ba,$bb,$bc,$ad,$bd,$be,$ba,$bf,$c0,$71,$60,$60,$60
;    db  $60,$60,$60,$72,$c1,$c2,$c3,$c4,$c5,$70,$c6,$c7,$c8,$c9,$ca,$cb,$cc,$cd,$ce,$cf,$d0,$d1,$c1,$d2,$d3,$cf,$d4,$d5,$d6,$60,$60,$60
;    db  $60,$60,$60,$73,$74,$74,$75,$76,$77,$78,$74,$79,$7a,$7b,$d8,$d9,$da,$db,$7c,$7d,$74,$7e,$77,$74,$7f,$77,$79,$80,$81,$60,$60,$60
;    db  $60,$60,$60,$60,$82,$83,$e8,$e9,$e9,$e9,$ea,$84,$85,$dc,$dd,$d9,$de,$df,$e0,$86,$87,$eb,$e9,$e9,$e9,$ec,$88,$89,$60,$60,$60,$60
;    db  $60,$60,$60,$60,$60,$60,$8a,$8b,$8c,$8c,$8c,$8d,$8e,$e1,$e2,$e3,$e4,$e5,$e6,$8f,$90,$8c,$8c,$8c,$91,$92,$60,$60,$60,$60,$60,$60
;    db  $60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$93,$74,$94,$74,$74,$74,$95,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60,$60


lvl:
    dm " LEVEL "
    
gameover:
    dm "GAME OVER"
    
prssky:    
    dm "PRESS SPACE TO START"
    
gotoroom:    
    dm "LOOK FOR ROOM "
;------------------------------    
dummy:      ds 8 
;BUFFER:     ds 33*8 ; buffer con una fila completa de caracteres (32) mas 1
