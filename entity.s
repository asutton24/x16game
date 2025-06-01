set_entity_base:
    tay
    lda #$0
    ldx #$1
    jsr reg_set
    ldy #$20
    ldx #$0
    jsr reg_set
    jsr mult_sixteen
    lda #$88
    ldy #$0
    ldx #$1
    jsr reg_set
    jsr add_sixteen
    lda $2
    sta $7E
    lda $3
    sta $7F
    rts
return_to_entity_base:
    lda $7E
    and #$E0
    sta $7E
    rts
goto_next_entity:
    jsr return_to_entity_base
    lda #$20
    jsr ptr_add
    rts
entity_clear:
    jsr set_entity_base
    lda #$FF
    ldy #$0
    jsr ptr_set_at
    rts
destroy_entity:
    jsr return_to_entity_base
    ldy #$1
    lda ($7E),y
    cmp #$FF
    beq no_sprite_assigned
    jsr free_sprite
no_sprite_assigned:
    lda #$FF
    ldy #$0
    jsr ptr_set_at
    rts
apply_y_velocity:
    lda #$2
    jsr return_to_entity_base
    jmp skip_x_vel_indexing
apply_x_velocity:
    jsr return_to_entity_base
    lda #$0
skip_x_vel_indexing:
    clc
    adc #$3
    pha
    jsr ptr_add
    ldx #$0
    jsr transfer_ptr_to_reg
    lda #$4
    jsr ptr_add
    ldx #$1
    jsr transfer_ptr_to_reg
    jsr add_sixteen
    jsr return_to_entity_base
    pla
    jsr ptr_add
    ldx #$0
    jsr transfer_reg_to_ptr
    rts
assign_sprite:
    jsr return_to_entity_base
    jsr find_available_sprite
    jsr reserve_sprite
    ldy #$1
    sta ($7E),y
    rts
update_sprite_pos:
    jsr return_to_entity_base
    jsr ptr_inc
    ldy #$0
    lda ($7E),y
    pha
    jsr ptr_double_inc
    ldx #$0
    jsr transfer_ptr_to_reg
    jsr fixed_to_int
    ldx #$0
    ldy #$2
    jsr reg_mov
    jsr ptr_double_inc
    ldx #$0
    jsr transfer_ptr_to_reg
    jsr fixed_to_int
    ldx #$0
    ldy #$1
    jsr reg_mov
    ldx #$2
    ldy #$0
    jsr reg_mov
    pla
    jsr set_sprite_pos
    rts


