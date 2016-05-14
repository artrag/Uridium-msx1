; -------------------------------------------------------
;
; void	demiz (char* source,char* destination);
;
;	de <- source
;	bc <- destination

psect	text

global		_demiz
_demiz:
	ex	de,hl
	ld	e,c
	ld	d,b

; -------------------------------------------------------
; MSX-O-Mizer v1.5f datas depacker
; Improved from Metalbrain's z80 version.
; -------------------------------------------------------
; source in hl
; dest in de

; 328 bytes which must be aligned on 8 bits boundary
; mom_map_bits    	=       0xe000
; 26 bytes located in ram
; mom_offset_table	=       0xe000 + 328
				


mom_depack:         push    de
                    ld      iy, mom_map_bits + 0xf0
                    ld      b, 52
mom_init_bits:      
                    db      0xFD,0x7D       ;LD   A,IYL
                    and     15
                    jr      nz, mom_node
                    ld      de, 1
mom_node:           rrd
                    ld      (iy), a
                    ld      (iy + 36), e
                    ld      (iy + 72), d

                    db       0xFD,0x2C      ;INC  IYL

                    inc     a
                    push    hl
                    ld      hl, 0
                    scf
mom_set_bit:        adc     hl, hl
                    dec     a
                    jr      nz, mom_set_bit
                    add     hl, de
                    ex      de, hl
                    pop     hl
                    bit     0, b
                    jr      z, mom_wait_step
                    inc     hl
mom_wait_step:      djnz    mom_init_bits
                    ld      a, (hl)
                    inc     hl

                    db      0xDD,0x67       ;LD   IXH,A

                    pop     de
mom_lit_copy:       ldi
mom_main_loop:      call    mom_get_bit
                    jr      c, mom_lit_copy
                    ld      c, -17
mom_get_index:      call    mom_get_bit
                    inc     c
                    jr      nc, mom_get_index
                    ld      a, c
                    ret     z
                    push    de
                    call    mom_get_pair
                    push    bc
                    jr      nz, mom_out_range
                    ld      de, 0x0220
                    dec     c
                    jr      z, mom_go_for_it
                    ld      de, 0x0410
                    dec     c
                    jr      z, mom_go_for_it
mom_out_range:      ld      de, 0x0400
mom_go_for_it:      pop     af
                    ex      af, af'
                    call    mom_get_bits
                    add     a, e
                    call    mom_get_pair
                    pop     de
                    push    hl
                    ld      h, d
                    ld      l, e
                    sbc     hl, bc
                    ex      af, af'
                    push    af
                    pop     bc
                    ldir
                    pop     hl
                    jr      mom_main_loop
mom_get_pair:       
                    db      0xFD,0x6F       ;LD   IYL,A

                    ld      d, (iy)
                    call    mom_get_bits
                    add     a,(iy + 36)
                    ld      c, a
                    ld      a, b
                    adc     a,(iy + 72)
                    ld      b, a
                    ret
mom_get_bits:       ld      bc, 0
mom_getting_bits:   dec     d
                    ld      a, c
                    ret     m
                    call    mom_get_bit
                    rl      c
                    rl      b
                    jr      mom_getting_bits
mom_get_bit:        
                    db       0xDD,0x7C      ;LD   A,IXH 

                    add     a,a
                    jr      nz, mom_byte_done
                    ld      a, (hl)
                    inc     hl
                    rla
mom_byte_done:     

                    db       0xDD,0x67      ;LD   IXH,A
                    ret

; 328 bytes which must be aligned on 8 bits boundary
; mom_map_bits    =       0xe000
psect	mizdata,RELOC=100h

mom_map_bits:
					ds	328+26
					