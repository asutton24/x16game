reset_score:
    lda #$0
    sta $2E
    sta $2F
    sta $30
    sta $31
    rts
cache_score:
    lda $30
    sta $2E
    lda $31
    sta $2F
    rts
deduct_and_restore_score:
    lda $2F
    bne deduct_score
    lda $2E
    cmp #$10
    bcs deduct_score
    lda #$0
    sta $2E
    sta $2F
    sta $30
    sta $31
    rts
deduct_score:
    sed
    sec
    lda $2E
    sbc #$10
    sta $2E
    sta $30
    lda $2F
    sbc #$0
    sta $2F
    sta $31
    cld
    rts
tally_level_score:
    sed
    clc
    lda #$8
    adc $39
    clc
    adc $30
    sta $30
    lda #$0
    adc $31
    sta $31
    cld
    rts
final_stage_score:
    lda $37
    asl
    asl
    asl
    asl
    clc
    sed
    adc $30
    sta $30
    lda #$0
    adc $31
    sta $31
    cld
    jmp cache_score
score_out:
    lda $31
    lsr
    lsr
    lsr
    lsr
    ora #$30
    sta $968
    lda $31
    and #$F
    ora #$30
    sta $969
    lda $30
    lsr
    lsr
    lsr
    lsr
    ora #$30
    sta $96A
    lda $30
    and #$F
    ora #$30
    sta $96B
    rts
    