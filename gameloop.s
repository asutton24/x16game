frame_loop:
    ;store current jiffy
    jsr RDTIM
    sta $3E
    jsr joystick_scan
    lda #$0
    jsr set_entity_base
    jsr entity_update
wait_for_frame_close:
    jsr randbyte
    jsr RDTIM
    cmp $3E
    beq wait_for_frame_close
    jmp frame_loop


