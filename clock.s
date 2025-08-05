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
    clc
    rts
second_complete:
    lda #$30
    sta $38
    lda $39
    cmp #$99
    beq timer_not_up
    sec
    sbc #$1
    sta $39
    clc
    bne timer_not_up
    sec
timer_not_up:
    cld
wait_finished:
    rts
clock_wait:
    jsr set_clock
    jsr RDTIM
    and #$FE
    sta $3A
wait_for_clock_bottom:
    jsr RDTIM
    and #$FE
    cmp $3A
    beq wait_for_clock_bottom
begin_tick:
    sta $3A
    jsr clock_tick
    bcs wait_finished
tick_not_complete:
    jsr RDTIM
    and #$FE
    cmp $3A
    beq tick_not_complete
    bne begin_tick
