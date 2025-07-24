;code stub
*= $801
dcb $0B $08 $01 $00 $9E $32 $33 $30 $31 $00 $00 $00
*= $8FD
jmp start
;LVL00.BIN, $900, len = 9
dcb $4C $56 $4C $30 $30 $2E $42 $49 $4E
;SPR0.BIN, $909, len = 8
dcb $53 $50 $52 $30 $2E $42 $49 $4E
*= $E00
;animation segment
;idle player sprite $E00
dcb $00 $00 $00 $00 $01
;shooting idle sprite $E05
dcb $00 $00 $00 $00 $05
;running player sprite $E0A
dcb $04 $00 $04 $04 $01
;running shooting sprite $E0F
dcb $04 $00 $04 $04 $05
;idle jumping sprite $E14
dcb $00 $00 $00 $00 $09
;shooting jumping sprite $E19
dcb $00 $00 $00 $00 $0A
;bullet sprite $E1E
dcb $00 $00 $00 $00 $0B
;spike sprite $E23
dcb $00 $00 $00 $00 $0C
;exit sprite $E28
dcb $00 $00 $00 $00 $0D
;chaser animation $E2D
dcb $02 $00 $02 $02 $0E