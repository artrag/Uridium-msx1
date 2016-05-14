;;--------------------------------------------------------------------
;;                        GAME SONG DATA
;;--------------------------------------------------------------------
        
game_song:
        db  1
        dw  pattern_rewind_track1
        dw  $0101
        db  1
        dw  pattern_rewind_track2
        dw  $0101
        db  1
        dw  pattern_rewind_track3
    

;;--------------------------------------------------------------------
;;                          TRACK DATA
;;--------------------------------------------------------------------
    
track1_data:
        dw  pattern_bd
        dw  pattern_hh
        dw  pattern_bd
        dw  pattern_hh
        dw  pattern_sd
        dw  pattern_hh
        dw  pattern_hh
        dw  pattern_hh
        dw  pattern_bd
        dw  pattern_hh
        dw  pattern_hh
        dw  pattern_hh
        dw  pattern_sd
        dw  pattern_hh
        dw  pattern_hh
        dw  pattern_hh
        dw  pattern_rewind_track1
    
        
track2_data:
        dw  pattern_melodyD1
        dw  pattern_baseB1
        dw  pattern_baseB1
        dw  pattern_melodyD1
        dw  pattern_baseB1
        dw  pattern_baseB1
        dw  pattern_base2
        dw  pattern_base2
        dw  pattern_base2
        dw  pattern_base2
        dw  pattern_base1
        dw  pattern_base1
        dw  pattern_base1
        dw  pattern_base1
        dw  pattern_rewind_track2
    
        
track3_data:
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1
        dw  pattern_melodyB1

        dw  pattern_melody
        dw  pattern_rewind_track3


;;--------------------------------------------------------------------
;;                        PATTERN DATA
;;--------------------------------------------------------------------

pattern_rewind_track1:
        dw  track1_data
        
pattern_rewind_track2:
        dw  track2_data

pattern_rewind_track3:
        dw  track3_data

pattern_melody:
        dw  $0a0c
        
        dw  $04ac
        dw  $0502
        dw  $1070       
        
        dw  $0462
        dw  $1070       
        
        dw  $0440
        dw  $1070       
        
        dw  $0400
        dw  $1070       
        
        dw  $04c8
        dw  $0501
        dw  $102a       
        
        dw  $0440
        dw  $0502
        dw  $1046       
        
        dw  $04ac
        dw  $102a       
        
        dw  $0400
        dw  $0503
        dw  $1046       
        
        dw  $0a06
        dw  $1070       
        
        dw  $0a00
        dw  $1070       

        dw  $2000       ; end of pattern

pattern_melodyB1:
        dw  $0480
        dw  $0504
        
        dw  $0a0d
        dw  $1006
        dw  $0a0b
        dw  $1003
        dw  $0a09
        dw  $1003
        dw  $0a06
        dw  $1002
        
        dw  $0a0b
        dw  $1006
        dw  $0a09
        dw  $1003       
        dw  $0a07
        dw  $1003
        dw  $0a04
        dw  $1002
        
        dw  $2000       ; end of pattern


pattern_melodyD1:
        dw  $0301
        dw  $0220
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1007
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1015
        
        dw  $0909
        dw  $1015
        dw  $0902
        dw  $1007
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1015
        
        dw  $0909
        dw  $1015
        dw  $0902
        dw  $1015
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1007
        
        dw  $0909
        dw  $1015
        dw  $0902
        dw  $1007
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1015
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1007
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1007
        
        dw  $0909
        dw  $1015
        dw  $0902
        dw  $1015
        
        dw  $0909
        dw  $1015
        dw  $0902
        dw  $1007
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1007
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1015
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1015
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1007
        
        dw  $0909
        dw  $1015
        dw  $0902
        dw  $1007
        
        dw  $0909
        dw  $1007
        dw  $0902
        dw  $1015

        dw  $2000       ; end of pattern



pattern_melodyC1:
        dw  $0909
        dw  $0300
        
        dw  $0278
        dw  $1070

        dw  $0909
        dw  $027e
        dw  $1070
        
        dw  $0909
        dw  $026a
        dw  $1070
        
        dw  $0909
        dw  $026f
        dw  $1070

        dw  $2000       ; end of pattern
        
pattern_baseB1:
        dw  $0c00
        dw  $0d0e

        dw  $0b48
        dw  $0240
        dw  $0302

        dw  $0910
        dw  $1018       
        dw  $0900
        dw  $1004

        dw  $0910
        dw  $1018       
        dw  $0900
        dw  $1004

        dw  $0910
        dw  $100c      
        dw  $0900
        dw  $1002

        dw  $0910
        dw  $1018    
        dw  $0900
        dw  $1012
        
        dw  $1070

        dw  $2000       ; end of pattern


pattern_baseD1:
        dw  $0c00
        dw  $0d0e

        dw  $0b36
        dw  $02b0
        dw  $0301

        dw  $0910
        dw  $1018       
        dw  $0900
        dw  $1004

        dw  $0910
        dw  $1018       
        dw  $0900
        dw  $1004

        dw  $0910
        dw  $100c      
        dw  $0900
        dw  $1002

        dw  $0910
        dw  $1018    
        dw  $0900
        dw  $1012
        
        dw  $2000       ; end of pattern



pattern_base1:
        dw  $0b48
        dw  $0240
        dw  $0302

        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       
        
        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       
        
        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       
        
        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       
        
        dw  $0910
        dw  $101a       
        dw  $0900
        dw  $1002       
        
        dw  $0b30
        dw  $0280
        dw  $0301
        
        dw  $0910
        dw  $101a       
        dw  $0900
        dw  $1002       
        
        dw  $2000       ; end of pattern

pattern_base2:
        dw  $0c00
        dw  $0d0e

        dw  $0b36
        dw  $02b0
        dw  $0301

        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       

        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       

        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       

        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       

        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       

        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       

        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       

        dw  $0910
        dw  $100c       
        dw  $0900
        dw  $1002       

        dw  $2000       ; end of pattern

    
pattern_bd:
        dw  $0059
        dw  $0103
        dw  $061f
        dw  $07b0
        dw  $080f
        dw  $1002       
        dw  $0105
        dw  $07b8
        dw  $080d
        dw  $1002       
        dw  $0107
        dw  $080b
        dw  $1003       
        dw  $2000       ; end of pattern
    
pattern_hh:
        dw  $0600
        dw  $0059
        dw  $0103
        dw  $07b1
        dw  $080e
        dw  $1001       
        dw  $0800
        dw  $1006       
        dw  $2000       ; end of pattern
        
pattern_sd:
        dw  $0059
        dw  $0103
        dw  $0610
        dw  $07b0
        dw  $080f
        dw  $1001       
        dw  $07b1
        dw  $080d
        dw  $1003       
        dw  $0809
        dw  $1003       
        dw  $2000       ; end of pattern
    