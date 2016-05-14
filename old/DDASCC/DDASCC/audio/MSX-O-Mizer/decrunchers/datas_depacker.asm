; -------------------------------------------------------
; MSX-O-Mizer v1.5f datas depacker
; Improved from Metalbrain's z80 version.
; -------------------------------------------------------
; source in hl
; dest in de

; 328 bytes which must be aligned on 8 bits boundary
mom_map_bits        =       0xe000

mom_depack:         push    de
                    ld      iy, mom_map_bits + 0xf0
                    ld      b, 52
mom_init_bits:      ld      a, iyl
                    and     15
                    jr      nz, mom_node
                    ld      de, 1
mom_node:           rrd
                    ld      (iy), a
                    ld      (iy + 36), e
                    ld      (iy + 72), d
                    inc     iyl
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
                    ld      ixh, a
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
mom_get_pair:       ld      iyl, a
                    ld      d, (iy)
                    call    mom_get_bits
                    add     (iy + 36)
                    ld      c, a
                    ld      a, b
                    adc     (iy + 72)
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
mom_get_bit:        ld      a, ixh
                    add     a
                    jr      nz, mom_byte_done
                    ld      a, (hl)
                    inc     hl
                    rla
mom_byte_done:      ld      ixh, a
                    ret
