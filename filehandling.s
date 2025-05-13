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
    sta $903
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
    and #$3
    asl
    asl
    asl
    ora #$A0
    tay
    ldx #$0
    pla
    lsr
    lsr
    clc
    adc #$1
    sta $0
    txa
    jsr LOAD
    rts