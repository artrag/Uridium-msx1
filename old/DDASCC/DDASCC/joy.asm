
; Bit    	Description
;0        Input joystick pin 1      (up)
;1        Input joystick pin 2      (down)
;2        Input joystick pin 3      (left)
;3        Input joystick pin 4      (right)
;4        Input joystick pin 6      (trigger A)
;5        Input joystick pin 7      (trigger B)

_joy:
        di
        ld      a,15
        out     (0xa0),a    ; read/write from r#15

        in      a,(0xa2)
        and     255-64
        out     (0xa1),a    ; set joystick in port 1

        ld      a,14
        out     (0xa0),a    ; read/write from r#14

        in      a,(0xa2)
        ld      l,a
        ei
        ret

