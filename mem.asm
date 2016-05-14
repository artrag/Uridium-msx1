

; *** MEMORY SUBROUTINES ***

RAM8K:			equ		0
RAM16K:			equ		1
RAM32K:			equ		2
RAM48K:			equ		3
RAM64K:			equ		4

; Especiales para lineal y carga de Roms

NORAML:			equ		0		; No hay Ram para cargar algo de 16k
RAML16K:		equ		1		; Podemos cargar algo de 16k
RAML32K:		equ		2		; Podemos cargar algo de 32k linealmente
RAML48K:		equ		3		; Podemos cargar algo de 48k linealmente


EXPTBL:			equ		0FCC1h
SLTTBL:         equ     0FCC5h
BOTTOM:			equ		0FC48h


RDSLT:			equ		000Ch
WRSLT:			equ		0014h



				org		04000h
				db		041h,042h
				dw		initmain
				ds		12
				
				
initmain:
				di	
				im		1
				ld		sp,0F380h
				call	searchramnormal					; Se busca Ram normalmente
                
				call	searchramall					; Se buscan TODA la Ram
                
				call	searchramlineal					; Se analiza si va linealmente
										
				
				jp		$
				
				
; *** BUSQUEDA NORMAL DE 1 SLOT CON RAM PARA CADA PAGINA ***				
				
; ---------------------------
; SEARCHRAMNORMAL
; Busca la 64k de Ram
; Independiente slot
; ---------------------------

searchramnormal:

				
				
				ld		a,RAM8K
				ld		(ramtypus),a
				ld		a,(EXPTBL)
				ld		(rampage0),a
				ld		(rampage1),a
				ld		(rampage2),a
				ld		(rampage3),a

				xor		a
				ld		(ramcheck0),a
				ld		(ramcheck1),a
				ld		(ramcheck2),a
				ld		(ramcheck3),a


				call	search_slotram			; Cogemos la Ram de sistema, porque el sistema ya entiende que es la mejor
				ld		a,(slotram)
				ld		(rampage3),a
				
				; Comprobar 8k o 16k
				
				ld		c,0C0h
				call	checkmemdirect
				jr		c,searchramnormalend
				
				ld		a,RAM16K
				ld		(ramtypus),a
				
searchramnormal00:				
				
				; Buscamos Ram en las otras paginas
				
				ld		c,00h
				call	checkmem
				
				jr		c,searchramnormal40
				
				ld		(rampage0),a


				ld		a,1
				ld		(ramcheck0),a


				
searchramnormal40:
				ld		c,40h
				call	checkmem
				jr		c,searchramnormal80
				ld		(rampage1),a
				ld		a,1
				ld		(ramcheck1),a
				

searchramnormal80:

				ld		c,80h
				call	checkmem
				jr		c,searchramnormalend
				ld		(rampage2),a
				ld		a,1
				ld		(ramcheck2),a
			

				
searchramnormalend:

				; Examinar la cantidad y apuntarla
				
				ld		a,(ramtypus)
				cp		RAM8K
				ret		z
				
				
				
				
				ld		a,(ramcheck2)
				or		a
				ret		z
				
				
				ld		a,RAM32K
				ld		(ramtypus),a

				ld		a,(ramcheck1)
				or		a
				ret		z
				

				ld		a,RAM48K
				ld		(ramtypus),a

				ld		a,(ramcheck0)
				or		a
				ret		z
				
				ld		a,RAM64K
				ld		(ramtypus),a
				ret
				
				
				
; *** BUSQUEDA DE TODOS LOS SLOT CON RAM PARA CADA PAGINA ***				
				


;---------------------
; SEARCHRAMALL
; Busca la Ram, y analiza
; Para buscar toda
; ------------------------

searchramall:

				ld		c,00h
				ld		hl,rambuffer0
				ld		de,ramcounter0
				call	searchramallgen
				
				
				ld		c,40h
				ld		hl,rambuffer1
				ld		de,ramcounter1
				call	searchramallgen

				
				ld		c,80h
				ld		hl,rambuffer2
				ld		de,ramcounter2
				call	searchramallgen
		
				ret
				
; HL : Buffer
; DE : Contador
; C: pagina				
				
searchramallgen:
				ld		a,0FFh
				ld		(thisslt),a
				xor		a
				ld		(de),a
				
searchramallgen0:				
				push	hl
				push	de
				
searchramallgen1:
				
				push	bc
				call	sigslot
				pop		bc
				cp		0FFh
				jr		z,searchramallgenend
		
                push    bc
				call	checkmemgen_slot0
                pop     bc

				jr		c,searchramallgen1

				
				pop		de
				pop		hl
                    
                ld      a,(thisslt)
				ld		(hl),a
				inc		hl
				ld		a,(de)
				inc		a
				ld		(de),a
				jr		searchramallgen0
						
searchramallgenend:
				
				pop		de
				pop		hl				

				ret
				
				
; *** ANALISIS PARA INTENTAR POSICIONAR EL MAXIMO DE RAM LINEALMENTE ***				
				
; --------------------
; SEARCHRAMLINEAL
; Busca cuanta ram
; Tenemos en un slot
; linealmente
; Hace uso de:
;		SEARCHRAMNORMAL
;		SEARCHRAMALL
; --------------------				
				
		
searchramlineal:

				ld		a,(rampage3)
				ld		(ramlineal3),a				
				ld		a,NORAML
				ld		(ramlineal),a				
				ld		a,(ramtypus)
				cp		RAM8K
				ret		z						; 8k solo
				cp		RAM16K					
				ret		z						; 16k solo
				
				
				ld		a,(rampage2)
				ld		(ramlineal2),a				
				ld		a,RAML16K
				ld		(ramlineal),a	
				
				ld		a,(ramtypus)
				cp		RAM32K
				ret		z
				
				cp		RAM48K
				jp		z,searchramlineal48k



				;  64k a investigar
				
searchramlineal64k:

				; Comprobamos que los defectos son iguales
				
				ld		a,(rampage2)
				ld		(ramlineal2),a
				ld		(ramlineal1),a
				ld		(ramlineal0),a
				
				
				ld		hl,rampage1
				cp		(hl)
				jr		nz,searchramlineal64k0			; no es
				ld		hl,rampage0
				cp		(hl)
				jr		z,searchramlineal64kend
				
				; Miramos si los tres tienen 1 y se pira
				
				ld		a,(rambuffer2)
				cp		1
				jr		nz,searchramlineal64k0
				ld		hl,rambuffer1
				cp		(hl)
				jr		nz,searchramlineal64k0
				ld		hl,rambuffer0
				cp		(hl)
				jr		nz,searchramlineal64k0
				
				ret				; Los tres tienen 1 y no era la misma fuera
				
searchramlineal64k0:				
				

				
				; Esto va a ser superespectacular y no va a ir ... 

				ld		a,(ramcounter2)
				ld		b,a
				ld		hl,rambuffer2
				
searchramlineal64k1:				

				push	bc
				push	hl

				ld		a,(ramcounter1)
				ld		b,a
				ld		a,(hl)
				ld		hl,rambuffer1
				call	searchramlinealgen

				pop		hl
				pop		bc
				jr		nc,searchramlineal64k2
				
searchramlineal64k11:				
				
				inc		hl
				djnz	searchramlineal64k1
				
				jp		searchramlineal48k
				

searchramlineal64k2:

				; Buscar en el 3
				
				push	hl
				push	bc
				
				
				ld		a,(ramcounter0)
				ld		b,a
				ld		a,(hl)
				ld		hl,rambuffer0
				call	searchramlinealgen
				
				pop		bc
				pop		hl
				
				jr		c,searchramlineal64k11
				
				; Bingo!
				
				


searchramlineal64k3:
				ld		(ramlineal2),a
				ld		(ramlineal1),a
				ld		(ramlineal0),a



searchramlineal64kend:

				ld		a,RAML48K
				ld		(ramlineal),a
				ret



; Analisis de 48k
; Mirar si coinciden
; la pagina 2 y pagina 1

searchramlineal48k:

								
				ld		a,(rampage1)
				ld		(ramlineal1),a
				ld		hl,rampage2
				cp		(hl)
				jp		z,searchramlineal48kend	; Primero a ver si las 2 paginas encontradas son iguales y evitamos busquedas

				
				ld		a,(ramcounter1)
				ld		hl,ramcounter2
				cp		1
				jr		nz,searchramlineal48k0
				cp		(hl)
				ret		z				; Si solo hay 1 en ambos y no era la misma, fuera, no hay


searchramlineal48k0:

				ld		a,(ramcounter1)
				ld		b,a
				ld		hl,rambuffer1
searchramlineal48k1:	
			
				push	hl
				push	bc
				ld		a,(ramcounter2)
				ld		b,a
				ld		a,(hl)
				ld		hl,rambuffer2
				call	searchramlinealgen
				pop		bc
				pop		hl
				jr		nc,searchramlineal48k2
				
				inc		hl
				djnz	searchramlineal48k1
				ret
				

				

searchramlineal48k2:
				ld		(ramlineal2),a
				ld		(ramlineal1),a

searchramlineal48kend:

				ld		a,RAML32K
				ld		(ramlineal),a
				ret
				
				
; Analiza el slot pasado en A
; Con los de otro buffer
; HL buffer
; DE Contador				
; Cy = 1 No encontrado
				
searchramlinealgen:				
				ld		c,a
				ld		a,(de)
				ld		b,a
				
searchramlinealgen0:				
				
				ld		a,(hl)
				cp		c
				ret		z
				inc		hl
				djnz	searchramlinealgen0
				scf
				ret
				
				
						
; *** RUTINAS GENERICAS ****				

			
; ---------------------
; CHECKMEM
; C : Page
; Cy : NotFound
; ----------------------

checkmem:

				ld		a,0FFh
				ld		(thisslt),a
checkmem0:				
				push	bc
				call	sigslot
				pop		bc
				cp		0FFh
				jr		z,.checkend
				
				push	bc
                call    checkmemgen_slot0
.checkend:
				pop		bc
				ld		a,(thisslt)
				ret		nc
				jr		checkmem0
			

; --------------------------
; CHECKMEMGEN_SLOT0
; C : Page
; A : Slot FxxxSSPP
; 00 : 0
; 40:  1
; 80 : 2
; Returns :
; Cy = 1 Not found
; If C = 0 uses checkmemgenpage0
; -------------------------------

checkmemgen_slot0:                
			
                ld      b,a                
                ld      a,c
                or      a
                ld      a,b
                jp      z,checkmemgenpage0


			
; --------------------------
; CHECKMEMGEN
; C : Page
; A : Slot FxxxSSPP
; 00 : 0
; 40:  1
; 80 : 2
; Returns :
; Cy = 1 Not found
; -------------------------------


checkmemgen:
				push	bc
				push	hl
				ld		h,c
				ld		l,010h
				
checkmemgen1:  
				
				push	af
				call	RDSLT
				cpl	
				ld		e,a
				pop		af
				
				push	de
				push	af
				call	WRSLT
				pop		af
				pop		de
				
				push	af
				push	de
				call	RDSLT
				pop		bc
				ld		b,a
				ld		a,c
				cpl	
				ld		e,a
				pop		af
				
				push	af
				push	bc
				call	WRSLT
				pop		bc
				ld		a,c
				cp		b
				jr		nz,checkmemgen2
				pop		af
				dec		l
				jr		nz,checkmemgen1
				pop		hl
				pop		bc
				or		a
				ret
checkmemgen2:
				pop		af
				pop		hl
				pop		bc
				scf
				ret


; --------------------------
; CHECKMEMGENPAGE0
; A : Slot FxxxSSPP
; Returns :
; Cy = 1 Not found
; -------------------------------
                
checkmemgenpage0:
                
                call    setslotpage0_mem
                ld      c,0
                call    checkmemdirect
                push    af
                call    recbios_mem
                pop     af
                ret





; ------------------------------
; RECBIOSMEM
; Posiciona la bios ROM
; -------------------------------
                    
recbios_mem:        
                    ld      a,(EXPTBL)
                
            

; ---------------------------
; SETSLOTPAGE0MEM
; Posiciona el slot pasado 
; en pagina 0 del Z80
; A: Formato FxxxSSPP
; ----------------------------
            
setslotpage0_mem:       
                    di

                    ld      b,a                 ; B = Slot param in FxxxSSPP format                
                    
                    
                    in      a,(0A8h)
                    and     011111100b
                    ld      d,a                 ; D = Primary slot value
                    
                    ld      a,b         
                    
                    and     03  
                    or      d
                    ld      d,a                 ; D = Final Value for primary slot 
                    
                    out     (0A8h),a
                    
                    ; Check if expanded
                    ld      a,b
                    bit     7,a                                                
                    ret     z                    ; Not Expanded
                    
                    and     03h                             
                    rrca
                    rrca
                    and     011000000b
                    ld      c,a                 
                    ld      a,d
                    and     00111111b
                    or      c
                    ld      c,a                 ; Primary slot value with main slot in page 3  

                    ld      a,b
                    and     00001100b
                    rrca
                    rrca    
                    and     03h
                    ld      b,a                 ; B = Expanded slot in page 3
                    ld      a,c
                    out     (0A8h),a            ; Slot : Main Slot, xx, xx, Main slot
                    ld      a,(0FFFFh)
                    cpl
                    and     011111100b
                    or      b
                    ld      (0FFFFh),a          ; Expanded slot selected 
                

                    ld      c,a

                                                ; Slot Final. Ram, rom c, rom c, Main
                    ld      a,d                 ; A = Final value
                    out     (0A8h),a


                    and     3                    
                    ld      de,SLTTBL    
                    add     a,e
                    ld      e,a
                    jr      nc,.nocarry
                    inc     d
.nocarry:
                    ld      a,c
                    ld      (de),a
                    

                    ret

setslotpage0_mem_end:
                

; --------------------------
; CHECKMEMDIRECT
; Chequea si hay memoria
; En pagina C
; Y 16 posiciones por arriba
; ---------------------------

checkmemdirect:

				ld		h,c
				ld		l,010h


checkmemdirect0:
				ld		a,(hl)
				cpl
				ld		c,a
				ld		(hl),a
				ld		a,(hl)
				ld		b,a
				cpl
				ld		(hl),a
				ld		a,b
				cp		c
				jr		nz,checkmemdirectno
				dec		l
				jr		nz,checkmemdirect0
				or		a
				ret
checkmemdirectno:
				scf
				ret

			
; ---------------------
; SEARCH_SLOTRAM
; Busca el slot de la ram
; Y almacena
; ----------------------				
				
search_slotram:
				call	0138h
				rlca
				rlca
				and		3
				ld		c,a
				ld		b,0
				ld		hl,0FCC1h
				add		hl,bc
				ld		a,(hl)
				and		080h
				or		c
				ld		c,a
				inc		hl
				inc		hl
				inc		hl
				inc		hl
				ld		a,(hl)
				rlca
				rlca
				rlca
				rlca
				and		0Ch
				or		c
				ld		(slotram),a
				
				ret
			
			
; -------------------------------------------------------
; SIGSLOT
; Returns in A the next slot every time it is called.
; For initializing purposes, THISSLT has to be #FF.
; If no more slots, it returns A=#FF.
; --------------------------------------------------------

;	; this code is programmed by Nestor Soriano aka Konamiman

sigslot:
				ld		a,(thisslt)		; Returns the next slot, starting by
				cp		0FFh			; slot 0. Returns #FF when there are not more slots
				jr		nz,sigslt1		; Modifies AF, BC, HL.  
				ld		a,(EXPTBL)
				and		010000000b
				ld		(thisslt),a
				ret

sigslt1:
				ld		a,(thisslt)
				cp		010001111b
				jr		z,nomaslt
				cp		000000011b
				jr		z,nomaslt
				bit		7,a
				jr		nz,sltexp
sltsimp:
				and		000000011b
				inc		a
				ld		c,a
				ld		b,0
				ld		hl,EXPTBL
				add		hl,bc
				ld		a,(hl)
				and		010000000b
				or		c
				ld		(thisslt),a
				ret

sltexp:
				ld		c,a
				and		000001100b
				cp		000001100b
				ld		a,c
				jr		z,sltsimp
				add		a,000000100b
				ld		(thisslt),a
				ret

nomaslt:
				ld		a,0FFh
				ret
sigslotend:				
			
			
			
				ds		06000h-$,0FFh
			
; *** VARS ***

rampage0:		equ		0E000h
rampage1:		equ		rampage0	+	1
rampage2:		equ		rampage1	+	1
rampage3:		equ		rampage2	+	1
ramcheck0:		equ		rampage3	+	1
ramcheck1:		equ		ramcheck0	+	1
ramcheck2:		equ		ramcheck1	+	1
ramcheck3:		equ		ramcheck2	+	1
ramtypus:		equ		ramcheck3	+	1	
slotram:		equ		ramtypus	+	1			

rambuffer0:		equ		slotram		+	1
rambuffer1:		equ		rambuffer0	+	16
rambuffer2:		equ		rambuffer1	+	16
rambuffer3:		equ		rambuffer2	+	16
ramcounter0:	equ		rambuffer3	+	16
ramcounter1:	equ		ramcounter0	+	1
ramcounter2:	equ		ramcounter1 +	1
ramcounter3:	equ		ramcounter2	+	1

thisslt:		equ		ramcounter3	+	1
ramlineal:		equ		thisslt		+	1
ramlineal0:		equ		ramlineal	+	1
ramlineal1:		equ		ramlineal0	+	1
ramlineal2:		equ		ramlineal1	+	1
ramlineal3:		equ		ramlineal2	+	1

				

