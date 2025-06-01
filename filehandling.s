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
    tax
    jsr reg_set
    ldy #$80
    ldx #$1
    jsr reg_set
    jsr mult_sixteen
    lda #$30
    ldy #$0
    ldx #$1
    jsr reg_set
    jsr add_sixteen
    ldx #$0
    jsr reg_get
    pha
    tya
    tax
    pla
    tay
    lda #$3
    jsr LOAD
    rts

