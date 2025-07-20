;debug logging
reset_logging:
    lda #$40
    sta $71
    lda #$0
    sta $70
    sta $72
    rts
log_a:
    ldy #$0
    sta ($70),y
    inc $70
    bne finished_logging_inc
    inc $71
finished_logging_inc:
    inc $72
    rts
log_reg:
    jsr reg_get
    pha
    tya
    ldy #$0
    sta ($70),y
    pla
    iny
    sta ($70),y
    lda #$2
    clc
    adc $70
    sta $70
    lda #$0
    adc $71
    sta $71
    inc $72
    rts
log_position:
    lda $7F
    pha
    lda $7E
    pha
    jsr get_entity_pos
    ldx #$0
    jsr log_reg
    ldx #$1
    jsr log_reg
    pla
    sta $7E
    pla
    sta $7F
    rts
log_carry:
    php
    pha
    lda #$0
    tay
    adc #$0
    jsr log_a
    pla
    plp
    rts
log_r0_r7:
    pha
    php
    ldx #$0
log_reg_loop:
    txa
    pha
    jsr log_reg
    pla
    tax
    inx
    cpx #$8
    bne log_reg_loop
    lda $72
    sec
    sbc #$7
    sta $72
    plp
    pla
    rts