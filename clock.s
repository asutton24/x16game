set_clock:
;seconds in a, BCD
    sta $39
    lda #$30
    sta $38
    rts
clock_tick:
;carry set if time is zero
    sed
    lda $38
    sec
    sbc #$1
    beq second_complete
    sta $38
    cld
    rts
second_complete:
    lda #$30
    sta $38
    lda $39
    sec
    sbc #$1
    sta $39
    clc
    bne timer_not_up
    sec
timer_not_up:
    cld
    rts