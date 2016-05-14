; Generic Move2 data. 

_npc16_left:
	db	0, 0, 4, 36
	db	3, low sin1_270, low sin1_0,32
	db	0,0, -4,48

_npc16_right:	
	db	0,0, 4,36
	db	3, low sin1_90, low sin1_0, 32
	db	0,0, -4,48
	
;=================================================================================
;	W	A	R	N	I	N	G	!	!
;
;=================================================================================
;!!!!!! IMPORTANT SOME OF THE DATA BELOW HAS TO BE IN A 256byte range!!!!
;       Because we jump in these data strings using only the lowbyte of the addres
;=================================================================================	
NPC3_actiondata:
	; no data as timer always > 0 when leaving screen.
NPC4_actiondata:
	; no data as timer always > 0 when leaving screen.
	
NPC5_actiondata:
	db	2,0,low sin0_270,8		; fix X - var Y
NPC5_actiondata_sub:	
	db	10				; move dx towards MC
	db	8,4				; set timer
	db	9,low NPC5_actiondata_sub	; jump to location
	
NPC6_actiondata:
	db	0,0,0,32
	db	11,128


NPC7_actiondata:
	db	7,0,0,0,127,140
	db	2,0,low sin0_270,255
	
NPC8_actiondata:
	db	12,8
	db	9,low NPC8_actiondata	

NPC9_actiondata:
NPC9_actiondata_hit:
	db	5,0,low sin0_90,255
	;db	0,0,-4,128

NPC13_actiondata:
	db	7,0,0,0,127,196
	db	2,0,low sin0_270,128
	;db	9, low NPC13_actiondata
	
NPC14_actiondata:
	db	8,255
	db	9,low NPC14_actiondata	
	
NPC6_animationdata:
;	db	p1,c1,p2,c2,t,255,low NPC6_animationdata
	db	NPC6_pattern,NPC6_color,NPC6_pattern2+4,NPC6_color2,NPC6_anispeed
	db	NPC6_pattern,NPC6_color,NPC6_pattern2,NPC6_color2,NPC6_anispeed
	db	255,low NPC6_animationdata	
	
NPC8_animationdata:
;	db	p1,c1,p2,c2,t,255,low NPC6_animationdata
	db	NPC8_pattern,NPC8_color,NPC8_pattern2+4,NPC8_color2,NPC8_anispeed
	db	NPC8_pattern,NPC8_color,NPC8_pattern2,NPC8_color2,NPC8_anispeed
	db	255,low NPC8_animationdata
	
NPC9_animationdata:
;	db	p1,c1,p2,c2,t,255,low NPC6_animationdata
	db	NPC9_pattern+4,14,NPC9_pattern2,NPC9_color2,NPC9_anispeed
	db	NPC9_pattern,NPC9_color,NPC9_pattern2,NPC9_color2-1,NPC9_anispeed
	db	255,low NPC9_animationdata
	
NPC13_animationdata:
;	db	p1,c1,p2,c2,t,255,low NPC6_animationdata
	db	NPC13_pattern+4,NPC13_color,NPC13_pattern2,NPC13_color2,NPC13_anispeed
	db	NPC13_pattern,NPC13_color,NPC13_pattern2,NPC13_color2-1,NPC13_anispeed
	db	255,low NPC13_animationdata	
	
NPC14_animationdata:
	db	0x9c,5, 0x00, 0,NPC14_anispeed
NPC14_animationdata_loop:	
	db	0xd0,13, 0xd8, 5,NPC14_anispeed
	db	0xd4,13, 0xd8, 5,NPC14_anispeed		
	db	255,low NPC14_animationdata_loop	