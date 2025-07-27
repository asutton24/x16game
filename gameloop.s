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
    lda $880D
    bmi player_death_reset
    jsr randbyte
wait_for_frame_close:
    jsr RDTIM
    and #$FE
    cmp $3A
    beq wait_for_frame_close
    jmp frame_loop
player_death_reset:
    lda $8801
    pha
    jsr turn_off_sprite
    jsr nuke_enemies
    jsr swap_ptrs
    jsr load_enemies
    jsr return_to_player_start
    jsr swap_ptrs
    lda #$88
    ldy #$0
    sty $7E
    sta $7F
    jsr update_sprite_pos
    pla
    jsr turn_on_sprite
    jmp frame_loop_start