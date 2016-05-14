;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SAT update
; sprite multiplexing
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;nbytes:
;                 ld    a,(NNPCs)
;                 inc   a
;                 add   a,a
;                 add   a,a
;                 ld    b,a
;                 ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

update_SAT:
                ld    c,098h
                ld    a,(RG8SAV)
                bit   6,a
    	        jr    z,no5th

    	        and   31
    	        add   a,a
    	        add   a,a
CURR_PLAN:      add   a,0
    	        ld    e,a                  ; curr_plan + = (vdps0 & 31)*4; 5->20

		; sprt is the 32*4=128 copy of the SPRATR in RAM,
		; n_sprt holds the number of valid bytes in sprt,
		; curr_plan is the VDP sprite plan in sprt that is currently mapped on plane 0 (max priority)

                ld    b,NNPCS*4+4

		;   in A rest of E(=5th SPRITE * 4) / B


1:              sub    b
                jr     nc,1b
                add    a,b

                jr    z,no5th

                ld    (CURR_PLAN+1),a      ; curr_plan -= (curr_plan/(n_sprt)) * (n_sprt);
                ld    e,a
    	        ld    d,0

                ld    hl,SAT
                call  setwrt

                ld    hl,MSAT
                add   hl,de                ; hl = sprt + curr_plan

                ld    a,NNPCS*4+4
                sub   e
    	        ld    b,a                  ;  b = n_sprt -curr_plan
    	        otir

                ld    b,e                  ;  b = curr_plan
                jr    1f
no5th:
                xor   a
                ld   (CURR_PLAN+1),a

                ld    hl,SAT
                call  setwrt

                ld    b,NNPCS*4+4

1:              ld    hl,MSAT
                otir

                ld    a,208
                out   (98h),a

                ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
