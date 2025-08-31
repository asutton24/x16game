;code stub
*= $801
dcb $0B $08 $01 $00 $9E $32 $33 $30 $31 $00 $00 $00
*= $8FD
jmp start
;LVL00.BIN, $900, len = 9
dcb $4C $56 $4C $30 $30 $2E $42 $49 $4E
;SPR0.BIN, $909, len = 8
dcb $53 $50 $52 $30 $2E $42 $49 $4E
;LIVES 0, $911, len = 8
dcb $4C $49 $56 $45 $53 $20 $30 $0
;TIME 0, $919, len = 7
dcb $54 $49 $4D $45 $20 $30 $0
;PHASE 1, $920, len = 8
dcb $50 $48 $41 $53 $45 $20 $31 $0
;START, $928, len = 6
dcb $53 $54 $41 $52 $54 $0
;CONTINUE, $92E, len = 9
dcb $43 $4F $4E $54 $49 $4E $55 $45 $0
;STG0.BIN, $937, len = 8
dcb $53 $54 $47 $30 $2E $42 $49 $4E
;GAME OVER, $93F, len = 10
dcb $47 $41 $4D $45 $20 $4F $56 $45 $52 $0
;OCTATHLON, $949, len = 9, sprite data
dcb $1B $1C $1D $1E $1D $1F $20 $1B $21
;YOU WIN!, $952, len = 9
dcb $59 $4F $55 $20 $57 $49 $4E $21 $0
;FINAL SCORE: 0000, $95B, len = 18 
dcb $46 $49 $4E $41 $4C $20 $53 $43 $4F $52 $45 $3A $20 $30 $30 $30 $30 $0
;THANKS FOR PLAYING!, $96D, len = 20
dcb $54 $48 $41 $4E $4B $53 $20 $46 $4F $52 $20 $50 $4C $41 $59 $49 $4E $47 $21 $0
*= $DA0
;sentinel location table
dcb $0 $2 $40 $1 $C0 $2 $40 $1 $40 $0 $80 $1 $80 $4 $80 $1
dcb $40 $1 $0 $2 $80 $3 $0 $2 $0 $2 $80 $2 $C0 $2 $80 $2
*= $DC2
;title level info
dcb $8 $0 $1C $0 $35 $0 $36 $0 $2 $0 $1 $0 $0 $90 $0 $40
dcb $1 $60 $0 $0 $5 $0 $95 $0 $36 $1 $56 $0 $3 $0 $0 $40
dcb $2 $0 $5 $80 $1 $0 $0 $0 $0 $20 $0 $C0 $3 $E0 $4 $0
dcb $0 $20 $0 $C0 $3 $0 $0 $2 $0 $1 $40 $4 $0 $2
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
;drone animation $E32
dcb $01 $00 $02 $01 $10
;turret sprite $E37
dcb $00 $00 $00 $00 $12
;jumper animation $E3C
dcb $01 $00 $02 $01 $13
;target sprite $E41
dcb $00 $00 $00 $00 $15
;ghost animation $E46
dcb $04 $00 $02 $04 $16
;sentinel animation $E4B
dcb $03 $00 $03 $03 $18
