load_level_into_ram:
;a holds the dest location, x holds file id
    pha
    txa
    and #$F
    clc
    adc #$30
    cmp #$3A
    bcc valid_low_nibble
    adc #$6
valid_low_nibble:
    sta $904
    txa
    lsr
    lsr
    lsr
    lsr
    clc
    adc #$30
    cmp #$3A
    bcc valid_high_nibble
    adc #$6
valid_high_nibble:
    sta $903
    lda #$1
    ldx #$8
    ldy #$2
    jsr SETLFS
    lda #$9
    ldx #$0
    tay
    jsr SETNAM
    pla
    pha
    and #$F
    asl
    ora #$A0
    tay
    ldx #$0
    pla
    lsr
    lsr
    lsr
    lsr
    clc
    adc #$1
    sta $0
    txa
    jsr LOAD
    rts
load_level_range:
;a holds destination, x holds file id, y holds number of levels
    sta $60
    stx $61
    sty $62
    jsr load_level_into_ram
    lda $60
    ldx $61
    ldy $62
    inx
    clc
    adc #$1
    dey
    bne load_level_range
    rts
load_sprite_sheet:
; A holds which sheet to load SPRX.BIN, x holds offset
    and #$F
    tay
    txa
    pha
    tya
    clc
    adc #$30
    cmp #$3A
    bcc valid_sprite_nibble
    adc #$6
valid_sprite_nibble:
    sta $90C
    lda #$1
    ldx #$8
    ldy #$2
    jsr SETLFS
    lda #$8
    ldx #$9
    ldy #$9
    jsr SETNAM
    pla
    tay
    lda #$0
    sty $2
    sta $3
    ldy #$80
    sty $4
    sta $5
    jsr mult_sixteen
    lda #$30
    ldy #$0
    sty $4
    sta $5
    jsr add_sixteen
    ldy $2
    lda $3
    pha
    tya
    tax
    pla
    tay
    lda #$3
    jsr LOAD
    rts
load_stage:
;load stage a at position 0
    and #$F
    ora #$30
    cmp #$3A
    bcc valid_stage_nibble
    adc #$6
valid_stage_nibble:
    sta $93A
    lda #$1
    ldx #$8
    ldy #$2
    jsr SETLFS
    lda #$8
    ldx #$37
    ldy #$9
    jsr SETNAM
    lda #$1
    sta $0
    lda #$0
    sta $7E
    tax
    ldy #$A0
    jsr LOAD
    lda #$A0
    sta $7F
    rts
