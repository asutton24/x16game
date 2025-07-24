frame_loop_start:
    lda #$FF
    sta $3E
    jsr RDTIM
    and #$FE
    sta $3A
wait_for_frame_bottom:
    jsr RDTIM
    and #$FE
    cmp $3A
    beq wait_for_frame_bottom
frame_loop:
    ;store current jiffy
    inc $3E
    jsr RDTIM
    sta $3A
    lda #$0
    jsr set_entity_base
    lda #$0
update_entity_loop:
    pha
    jsr entity_update
    jsr goto_next_entity
    pla
    clc
    adc #$1
    cmp #$20
    bne update_entity_loop
    jsr randbyte
wait_for_frame_close:
    jsr RDTIM
    and #$FE
    cmp $3A
    beq wait_for_frame_close
    jmp frame_loop


