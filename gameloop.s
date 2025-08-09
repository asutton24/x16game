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
    jsr clock_tick
    bcs player_death_reset
    lda $880D
    bmi player_death_reset
    lda $36
    cmp #$1
    beq level_complete_reset
    jsr update_hud_time
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
    dec $37
    bne player_has_lives
    jsr nuke_everything
    jmp game_over
player_has_lives:
    jsr update_hud_lives
    jsr swap_ptrs
    jsr load_enemies
    jsr return_to_player_start
    jsr swap_ptrs
    lda #$88
    ldy #$0
    sty $7E
    sta $7F
    jsr update_sprite_pos
    lda #$8
    jsr set_clock
    pla
    jsr turn_on_sprite
    jmp frame_loop_start
level_complete_reset:
    lda $8801
    pha
    jsr turn_off_sprite
    jsr nuke_everything
    jsr swap_ptrs
    inc $35
    lda $35
    bne not_level_file
    jmp title_out
not_level_file:
    jsr full_level_load
    bcc level_load_successful
    inc $34
    lda $34
    jmp stage_starter
level_load_successful:
    lda #$88
    ldy #$0
    sty $7E
    sta $7F
    jsr update_sprite_pos
    pla
    jsr turn_on_sprite
    lda #$0
    sta $36
    lda #$8
    jsr set_clock
    jmp frame_loop_start
