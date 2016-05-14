; -------------------------------------------------------
; MSX-O-Mizer v1.5f datas depacker         *VRAM version*
; Improved from Metalbrain's z80 version.
; -------------------------------------------------------
; source in hl
; dest (in vram) in de
; (interrupts better be disabled during the depacking)

; 328 bytes which must be aligned on 8 bits boundary
mom_map_bits_vram   =       0xe000

mom_depack_vram:    push    de
                    ld      iy, mom_map_bits_vram + 0xf0
                    ld      b, 52
mom_init_bits_vram: ld      a, iyl
                    and     15
                    jr      nz, mom_node_vram
                    ld      de, 1
mom_node_vram:      rrd
                    ld      (iy), a
                    ld      (iy + 36), e
                    ld      (iy + 72), d
                    inc     iyl
                    inc     a
                    push    hl
                    ld      hl, 0
                    scf
mom_set_bit_vram:   adc     hl, hl
                    dec     a
                    jr      nz, mom_set_bit_vram
                    add     hl, de
                    ex      de, hl
                    pop     hl
                    bit     0, b
                    jr      z, mom_wait_step_vram
                    inc     hl
mom_wait_step_vram: djnz    mom_init_bits_vram
                    ld      a, (hl)
                    inc     hl
                    ld      ixh, a
                    pop     de
mom_lit_copy_vram:  ld      a, (hl)
                    inc     hl
                    call    mom_write_byte_vram
mom_main_loop_vram: call    mom_get_bit_vram
                    jr      c, mom_lit_copy_vram
                    ld      c, -17
mom_get_index_vram: call    mom_get_bit_vram
                    inc     c
                    jr      nc, mom_get_index_vram
                    ld      a, c
                    ret     z
                    push    de
                    call    mom_get_pair_vram
                    push    bc
                    jr      nz, mom_out_range_vram
                    ld      de, 0x0220
                    dec     c
                    jr      z, mom_go_for_it_vram
                    ld      de, 0x0410
                    dec     c
                    jr      z, mom_go_for_it_vram
mom_out_range_vram: ld      de, 0x0400
mom_go_for_it_vram: pop     af
                    ex      af, af'
                    call    mom_get_bits_vram
                    add     a, e
                    call    mom_get_pair_vram
                    pop     de
                    push    hl
                    ld      h, d
                    ld      l, e
                    sbc     hl, bc
                    ex      af, af'
                    push    af
                    pop     bc
mom_copy_bytes_to_vram:
                    ld      a, l
                    out     (0x99), a
                    ld      a, h
                    nop
                    out     (0x99), a
                    inc     hl
                    in      a, (0x98)
                    call    mom_write_byte_vram
                    dec     bc
                    ld      a, b
                    or      c
                    jr      nz, mom_copy_bytes_to_vram
                    pop     hl
                    jr      mom_main_loop_vram
mom_get_pair_vram:  ld      iyl, a
                    ld      d, (iy)
                    call    mom_get_bits_vram
                    add     (iy + 36)
                    ld      c, a
                    ld      a, b
                    adc     (iy + 72)
                    ld      b, a
                    ret
mom_get_bits_vram:  ld      bc, 0
mom_getting_bits_vram:
                    dec     d
                    ld      a, c
                    ret     m
                    call    mom_get_bit_vram
                    rl      c
                    rl      b
                    jr      mom_getting_bits_vram
mom_get_bit_vram:   ld      a, ixh
                    add     a
                    jr      nz, mom_byte_done_vram
                    ld      a, (hl)
                    inc     hl
                    rla
mom_byte_done_vram: ld      ixh, a
                    ret
mom_write_byte_vram:
                    push    af
                    ld      a, e
                    out     (0x99), a
                    ld      a, d
                    or      0x40
                    out     (0x99), a
                    pop     af
                    inc     de
                    out     (0x98), a
                    ret
