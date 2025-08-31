title_level:
    lda #$FF
    sta $37
    lda #$C2
    sta $2
    lda #$D
    sta $3
    lda #$0
    sta $4
    lda #$A0
    sta $5
    lda #$0
    jsr set_level_base
    ldy #$3E
    jsr mem_cpy
    lda #$0
    jsr full_level_load
    lda #$9
    sta $3
    lda #$28
    sta $2
    ldx #$20
    ldy #$E
    jsr print_at
    lda $34
    cmp #$1
    beq no_continue
    lda #$C0
    sta $2
    lda #$0
    sta $3
    sta $4
    lda #$2
    sta $5
    jsr level_exit_init
    lda #$2E
    sta $2
    lda #$9
    sta $3
    ldy #$E
    ldx #$3
    jsr print_at
no_continue:
    lda #$99
    jsr set_clock
    lda #$FF
    sta $35
    lda #$0
    sta $36
    sta $8809
    sta $880A
    lda #$1
    sta $880D
    jsr clear_text_line
    lda #$0
    sta $7E
    jsr update_sprite_pos
    lda $8801
    jsr turn_on_sprite
    jsr logo_init
    jsr turn_on_logo
    jmp frame_loop_start
title_out:
    lda #$E
    jsr clear_text_line
    jsr turn_off_logo
    lda $8803
    sta $2
    lda $8804
    sta $3
    lda #$7C
    sta $4
    lda #$2
    sta $5
    jsr cmp_sixteen
    bcc continue_stage
    jsr reset_score
    lda #$1
    sta $34
    jmp stage_starter
continue_stage:
    jsr deduct_and_restore_score
    lda $34
    jmp stage_starter
game_over:
    lda #$3F
    sta $2
    lda #$9
    sta $3
    lda #$2
    jsr intermission
    jmp title_level 
logo_init:
    lda #$77
    sta $10
    lda #$0
    sta $11
    lda #$58
    sta $12
    lda #$0
    sta $13
logo_init_loop:
    ldx $11
    lda $949,x
    ldx $10
    jsr assign_data_to_sprite
    lda #$20
    sta $4
    lda #$0
    sta $5
    lda $12
    sta $2
    lda $13
    sta $3
    lda $10
    jsr set_sprite_pos
    inc $10
    inc $11
    clc
    lda #$10
    adc $12
    sta $12
    bcc no_logo_carry  
    inc $13
    clc
no_logo_carry:
    lda $11
    cmp #$9
    bne logo_init_loop
logo_on_done:
    rts
turn_on_logo:
    lda #$77
    pha
logo_turn_on_loop:
    pla
    cmp #$80
    beq logo_on_done
    adc #$1
    pha
    adc #$FF
    clc
    jsr turn_on_sprite
    jmp logo_turn_on_loop
turn_off_logo:
    lda #$77
    pha
logo_turn_off_loop:
    pla
    cmp #$80
    beq logo_on_done
    adc #$1
    pha
    adc #$FF
    clc
    jsr turn_off_sprite
    jmp logo_turn_off_loop
