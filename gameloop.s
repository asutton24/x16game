frame_loop_start:
    jsr RDTIM
    sta $3E
wait_for_frame_bottom:
    jsr RDTIM
    cmp $3E
    beq wait_for_frame_bottom
frame_loop:
    ;store current jiffy
    jsr RDTIM
    sta $3E
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
    cmp #$21
    bne update_entity_loop
    jsr randbyte
wait_for_frame_close:
    jsr RDTIM
    cmp $3E
    beq wait_for_frame_close
    jmp frame_loop


