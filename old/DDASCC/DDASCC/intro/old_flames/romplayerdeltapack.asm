CHGMOD:      equ    #005F
LDIRMV:      equ    #0059
CALSLT:      EQU    #001C
EXPTBL:      EQU    #FCC1

ntiles:     equ     256


        
        OUTPUT vplayer.rom
		org	4000h
		dw	"BA",START,0,0,0
        

;-------------------------------------
; Instead of CHGMOD
;-------------------------------------

_vdpinit:
            di
            ld hl,_vdpregs
            ld bc,0x8099
1:          outi
            inc b
            out (c),b
            inc b
            bit 3,b
            jr z,1b

            ei
            ret

_vdpregs:
          defb 0x02 ; Reg# 0 000000[M3][EV]
          defb 0x62 ; Reg# 1 [4/16k][BLANK][IE][M1][M2]0[SIZE][MAG]
          defb 0x06 ; Reg# 2 0000[NAME TABLE BASE ADDRESS]          = 1800h
          defb 0xFF ; Reg# 3 [COLOR BASE ADDRESS]                   = 2000h ; regular mode for colors
          defb 0x03 ; Reg# 4 00000[PATTERN GENERATOR BASE ADDRESS]  = 0000h  ; regular mode for patterns
          
          defb 0x36 ; Reg# 5 0[SPRITE ATTRIBUTE TABLE BASE ADDRESS] = 1b00h
          defb 0x07 ; Reg# 6 00000[SPRITE PTRN GNRTR BASE ADDRESS]  = 3800h
          defb 0x01 ; Reg# 7 [TEXT COLOR 4bts][BACKDROP COLOR 4bts]


;-------------------------------------
; set pages and subslot
;-------------------------------------
;
powerup:

        call    0x138
        rrca
        rrca
        and     0x03
        ld      c,a
        ld      b,0
        ld      hl,EXPTBL
        add     hl,bc
        or      (hl)
        ld      b,a
        inc     hl
        inc     hl
        inc     hl
        inc     hl
        ld      a,(hl)
        and     0x0c
        or      b
        
        ld      h,0x80
        call    0x24        
    
        ret

;-------------------------------------
; Entry point
;-------------------------------------       
START:
        call    powerup
        
        call    RESET_VDP
        

.REWIND:

        ld      e,nf
        exx                

        ld      hl, SAMPLE_START

        call    PLAY_SAMPLE
        
        jr      .REWIND
        ret
        
        

;-------------------------------------
; Resets the vdp
;-------------------------------------

RESET_VDP:

        call    _vdpinit

        ld      hl,patandcol
        ld      de,0xc000
        call    mom_depack_rom
        call    mom_depack_rom        
        
        ld      hl,0xc000;  patterns and colors

        xor     a
        out     (0x99),a
        ld      a,0x0000/256 + 0x40 ; PGT
        out     (0x99),a

        call    outs         

        xor     a
        out     (0x99),a
        ld      a,0x0800/256 + 0x40 ; PGT
        out     (0x99),a

        call    outs
        
        xor     a
        out     (0x99),a
        ld      a,0x1000/256 + 0x40 ; PGT
        out     (0x99),a
    
        call    outs
        
        xor     a
        out     (0x99),a
        ld      a,0x2000/256 + 0x40 ; PCT
        out     (0x99),a
        
        call    outs
        
        xor     a
        out     (0x99),a
        ld      a,0x2800/256 + 0x40 ; PCT
        out     (0x99),a

        call    outs

        xor     a
        out     (0x99),a
        ld      a,0x3000/256 + 0x40 ; PCT
        out     (0x99),a
        
outs:
        
        ld      de,ntiles*8
        ld      c,0x98
         
1:      outi
        dec e
        jr nz,1b
        dec d
        jr nz,1b
         
        ret         

;-------------------------------------
; replayer core
;-------------------------------------

PLAY_SAMPLE:

        ld      de,0xc000      ; destination
        call    mom_depack_rom
        

        call    setframe
        
        exx
        dec e                       ; first keyframe extracted 
        exx
        
2:
        ld      de,0xc000+1024      ; destination
        call    mom_depack_rom

        push    hl
        
        ld      hl,0xc000
        ld      de,0xc000+1024
        ld      bc,768
1:      ld      a,(de)
        add     a,(hl)
        ld      (hl),a
        inc     hl
        inc     de
        dec     c
        jp      nz,1b
        dec     b
        jp      nz,1b

        pop     hl                   ; full frame rebuilt

        call    setframe
        
        exx
        dec e
        exx
                
        jp     nz,2b               ; last frame
              
        ret

setframe:
        push    hl        
        halt
        xor a
        out     (0X99),a
        ld      a,0x18 + 64
        out     (0X99),a       
        ld      bc,0X98
        ld      hl,0xc000           ; plot a 768 bytes frame from here
        otir                                  
        otir                                  
        otir                                          
        pop     hl
        ret

; -------------------------------------------------------
; MSX-O-Mizer v1.5f datas depacker    *ROM based version*
; Improved from Metalbrain's z80 version.
; -------------------------------------------------------
; source in hl
; dest in de

; 328 bytes which must be aligned on 8 bits boundary
mom_map_bits_rom    =       0xF100
; 26 bytes located in ram
mom_offset_table    =       0xF100 + 328

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

;-------------------------------------
; tile data
;-------------------------------------

patandcol:  incbin tiles.pat.bin.miz
            incbin tiles.col.bin.miz

;-------------------------------------
; Sample data
;-------------------------------------
SAMPLE_START:


        include romdatadeltapack.asm
        

SAMPLE_END:



FINISH:













