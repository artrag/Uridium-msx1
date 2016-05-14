; -------------------------------------------------------
; MSX-O-Mizer v1.5f datas depacker    *ROM based version*
; Improved from Metalbrain's z80 version.
; -------------------------------------------------------
; source in hl
; dest in de

; 328 bytes which must be aligned on 8 bits boundary
mom_map_bits_rom    =       0xe000
; 26 bytes located in ram
mom_offset_table    =       0xe000 + 328

mom_depack_rom:     push    de
                    ld      bc, mom_offset_table
                    push    bc
                    ld      de, bc
                    ld      bc, 26
                    ldir
                    push    hl
                    pop     af
                    pop     hl
                    push    af
                    ld      iy, mom_map_bits_rom + 0xf0
                    ld      b, 52
mom_init_bits_rom:  ld      a, iyl
                    and     15
                    jr      nz, mom_node_rom
                    ld      de, 1
mom_node_rom:       rrd
                    ld      (iy), a
                    ld      (iy + 36), e
                    ld      (iy + 72), d
                    inc     iyl
                    inc     a
                    push    hl
                    ld      hl, 0
                    scf
mom_set_bit_rom:    adc     hl, hl
                    dec     a
                    jr      nz, mom_set_bit_rom
                    add     hl, de
                    ex      de, hl
                    pop     hl
                    bit     0, b
                    jr      z, mom_wait_step_rom
                    inc     hl
mom_wait_step_rom:  djnz    mom_init_bits_rom
                    pop     hl
                    ld      a, (hl)
                    inc     hl
                    ld      ixh, a
                    pop     de
mom_lit_copy_rom:   ldi
mom_main_loop_rom:  call    mom_get_bit_rom
                    jr      c, mom_lit_copy_rom
                    ld      c, -17
mom_get_index_rom:  call    mom_get_bit_rom
                    inc     c
                    jr      nc, mom_get_index_rom
                    ld      a, c
                    ret     z
                    push    de
                    call    mom_get_pair_rom
                    push    bc
                    jr      nz, mom_out_range_rom
                    ld      de, 0x0220
                    dec     c
                    jr      z, mom_go_for_it_rom
                    ld      de, 0x0410
                    dec     c
                    jr      z, mom_go_for_it_rom
mom_out_range_rom:  ld      de, 0x0400
mom_go_for_it_rom:  pop     af
                    ex      af, af'
                    call    mom_get_bits_rom
                    add     a, e
                    call    mom_get_pair_rom
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
                    jr      mom_main_loop_rom
mom_get_pair_rom:   ld      iyl, a
                    ld      d, (iy)
                    call    mom_get_bits_rom
                    add     (iy + 36)
                    ld      c, a
                    ld      a, b
                    adc     (iy + 72)
                    ld      b, a
                    ret
mom_get_bits_rom:   ld      bc, 0
mom_getting_bits_rom:
                    dec     d
                    ld      a, c
                    ret     m
                    call    mom_get_bit_rom
                    rl      c
                    rl      b
                    jr      mom_getting_bits_rom
mom_get_bit_rom:    ld      a, ixh
                    add     a
                    jr      nz, mom_byte_done_rom
                    ld      a, (hl)
                    inc     hl
                    rla
mom_byte_done_rom:  ld      ixh, a
                    ret
