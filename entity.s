set_entity_base:
    tay
    lda #$0
    sty $2
    sta $3
    ldx #$5
    jsr shift_left
    lda #$88
    ldy #$0
    sty $4
    sta $5
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
get_entity_vel:
    jsr return_to_entity_base
    lda #$7
    jmp skip_get_pos_indexing
get_entity_pos:
    jsr return_to_entity_base
    lda #$3
skip_get_pos_indexing:
    jsr ptr_add
    ldx #$0
    jsr transfer_ptr_to_reg
    jsr ptr_double_inc
    ldx #$1
    jmp transfer_ptr_to_reg
set_entity_vel:
    jsr return_to_entity_base
    lda #$7
    jmp skip_set_pos_indexing
set_entity_pos:
    jsr return_to_entity_base
    lda #$3
skip_set_pos_indexing:
    jsr ptr_add
    ldx #$0
    jsr transfer_reg_to_ptr
    jsr ptr_double_inc
    ldx #$1
    jmp transfer_reg_to_ptr
get_entity_sprite_index:
    jsr return_to_entity_base
    ldy #$1
    lda ($7E),y
    rts
entity_init:
; entity type in a, number in x
    pha
    txa
    jsr set_entity_base
    jsr destroy_entity
    pla
    ldy #$0
    sta ($7E),y
    tya
    ldy #$1F
    sta ($7E),y
    jsr assign_sprite
    jsr get_entity_sprite_index
    pha
    jsr turn_on_sprite
    pla
    tax
    lda #$0
    jsr assign_data_to_sprite
    lda #$0
    sta $2
    sta $3
    jsr ptr_double_inc
    lda #$0
    tay
    sta ($7E),y
    jsr ptr_inc
    ldx #$0
    jsr transfer_reg_to_ptr
    jsr ptr_double_inc
    ldx #$0
    jsr transfer_reg_to_ptr
    jsr ptr_double_inc
    ldx #$0
    jsr transfer_reg_to_ptr
    jsr ptr_double_inc
    ldx #$0
    jsr transfer_reg_to_ptr
    rts
apply_gravity:
    lda $3E
    and #$3
    beq valid_gravity_frame
    rts
valid_gravity_frame:
    jsr get_entity_vel
    ldx #$0
    jsr reg_push
    lda #$0
    ldy #$1
    sty $2
    sta $3
    jsr add_sixteen
    ldy $2
    lda $3
    sty $4
    sta $5
    ldx #$0
    jsr reg_pop
    jmp set_entity_vel
apply_y_velocity:
    jsr return_to_entity_base
    lda #$2
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
    ldy $2
    lda $3
    sty $6
    sta $7
    jsr ptr_double_inc
    ldx #$0
    jsr transfer_ptr_to_reg
    jsr fixed_to_int
    ldy $2
    lda $3
    sty $4
    sta $5
    ldy $6
    lda $7
    sty $2
    sta $3
    pla
    jsr set_sprite_pos
    rts
entity_solid_collision:
;entity in main ptr, solid object in reserve
    jsr swap_ptrs
    ldx #$4
    jsr transfer_ptr_to_reg
    jsr ptr_double_inc
    ldx #$6
    jsr transfer_ptr_to_reg
    jsr ptr_double_inc
    ldx #$5
    jsr transfer_ptr_to_reg
    jsr ptr_double_inc
    ldx #$7
    jsr transfer_ptr_to_reg
    jsr ptr_double_inc
    jsr swap_ptrs
    jsr return_to_entity_base
    lda #$3
    jsr ptr_add
    jsr transfer_ptr_to_stk
    jsr ptr_double_inc
    jsr transfer_ptr_to_stk
    lda #$6
    jsr ptr_add
    ldy #$0
    lda ($7E),y
    pha
    and #$F
    asl
    asl
    tay
    lda #$0
    jsr direct_push
    jsr stk_add
    ldx #$2
    jsr reg_pop
    pla
    and #$F0
    lsr
    lsr
    tay
    lda #$0
    jsr direct_push
    jsr stk_add
    ldx #$0
    jsr reg_pop
    jsr ptr_inc
    ldy #$0
    lda ($7E),y
    pha
    and #$F
    asl
    asl
    tay
    lda #$0
    sty $8
    sta $9
    pla
    and #$F0
    lsr
    lsr
    tay
    lda #$0
    sty $4
    sta $5
    jmp rectangle_collide
apply_y_correction:
    jsr return_to_entity_base
    lda #$2
    jmp skip_x_correction_index
apply_x_correction:
; have entity in ptr
    jsr return_to_entity_base
    lda #$0
skip_x_correction_index:
    clc
    adc #$8
    jsr ptr_add
    ldy #$0
    lda ($7E),y
    bpl positive_vel
    lda #$0
    ldy #$1
    jsr direct_push
    jmp negative_val_pushed
positive_vel:
    lda #$FF
    ldy #$FF
    jsr direct_push
negative_val_pushed:
    lda #$5
    jsr ptr_sub
    jsr transfer_ptr_to_stk
    jsr stk_add
    jsr pop_to_ptr
    rts
no_correction_needed:
    lda $60
    jsr update_collision_byte
    rts
check_collision_and_correct:
; $0 in a for x, $1 for y
; ptrs should be aligned for collisions
    ldx #$0
    stx $60
check_collision_and_correct_loop:
    pha
    jsr return_to_entity_base
    jsr entity_solid_collision
    pla
    bcc no_correction_needed
    pha
    jsr swap_ptrs
    lda #$8
    jsr ptr_sub
    jsr swap_ptrs
    pla
    pha
    bne y_correction_needed
    jsr apply_x_correction
    lda #$1
    sta $60
    pla
    jmp check_collision_and_correct_loop
y_correction_needed:
    jsr apply_y_correction
    lda #$2
    sta $60
    pla
    jmp check_collision_and_correct_loop
update_grounded_byte:
    jsr return_to_entity_base
    ldy #$9
    lda ($7E),y
    sta $2
    iny
    lda ($7E),y
    sta $3
    ldy #$1F
    lda ($7E),y
    pha
    lda #$0
    sta $4
    sta $5
    jsr cmp_sixteen
    bne grounded_affected
    pla
    rts
grounded_affected:
    lda $3
    bmi clear_grounded
    pla
    pha
    and #$2
    beq clear_grounded
    pla
    ora #$4
    ldy #$1F
    sta ($7E),y
    rts
clear_grounded:
    pla
    and #$FB
    ldy #$1F
    sta ($7E),y
no_collision_update:
    rts
update_collision_byte:
    beq no_collision_update
    pha
    jsr return_to_entity_base
    ldy #$1F
    pla
    cmp #$1
    bne update_y_collision
    lda #$FE
    and ($7E),y
    ora #$1
    sta ($7E),y 
    rts
update_y_collision:
    cmp #$2
    lda #$FD
    and ($7E),y
    ora #$2
    sta ($7E),y
    rts
get_collision_byte:
    jsr return_to_entity_base
    ldy #$1F
    lda ($7E),y
    rts
reset_collision_byte:
    jsr return_to_entity_base
    ldy #$1F
    lda ($7E),y
    and #$FC
    sta ($7E),y
    rts
; set carry if entity is touching the ground
is_on_ground:
    jsr return_to_entity_base
    ldy #$1F
    lda ($7E),y
    and #$2
    beq not_on_ground
    jsr get_entity_vel
    lda $5
    bmi not_on_ground
    sec
    rts
not_on_ground:
    clc
    rts
correct_velocity_vector:
    jsr return_to_entity_base
    ldy #$1F
    lda ($7E),y
    pha
    jsr get_entity_vel
    pla
    pha
    and #$1
    beq no_x_vel_fix
    lda #$0
    sta $2
    sta $3
no_x_vel_fix:
    pla
    and #$2
    beq no_y_vel_fix
    lda #$0
    sta $4
    sta $5
no_y_vel_fix:
    jmp set_entity_vel
skip_colliders:
    jsr swap_ptrs
    inc $3F
    inc $3F
    jsr apply_x_velocity
    jsr apply_y_velocity
    jsr reset_collision_byte
    jmp no_solid_colliders
entity_update:
;entity should be in main ptr, level in reserve
    jsr return_to_entity_base
    ldy #$0
    lda ($7E),y
    bne is_valid_entity
    rts
is_valid_entity:
    pha
    jsr swap_ptrs
    jsr return_to_level_base
    jsr ptr_double_inc
    jsr transfer_ptr_to_stk
    lda #$2
    jsr ptr_sub
    ldy $7E
    lda $7F
    jsr direct_push
    jsr stk_add
    jsr direct_pop
    jsr direct_push
    sty $7E
    sta $7F
    ldy #$0
    lda ($7E),y
    beq skip_colliders
    pha
    jsr return_to_entity_base
    ldx #$4
    ldy #$7
zero_vel_loop:
    lda ($7E),y
    bne not_zero_vel
    iny
    dex
    bne zero_vel_loop
    pla
    jmp skip_colliders
not_zero_vel:
    jsr ptr_inc
    jsr swap_ptrs
    jsr reset_collision_byte
    jsr apply_x_velocity
    pla
solid_colliders_x_loop:
    pha
    lda #$0
    jsr check_collision_and_correct
    pla
    sec
    sbc #$1
    bne solid_colliders_x_loop
    jsr swap_ptrs
    jsr direct_pop
    sty $7E
    sta $7F
    ldy #$0
    lda ($7E),y
    pha
    jsr ptr_inc
    jsr swap_ptrs
    jsr apply_y_velocity
    pla
solid_colliders_y_loop:
    pha
    lda #$1
    jsr check_collision_and_correct
    pla
    sec
    sbc #$1
    bne solid_colliders_y_loop
no_solid_colliders:
    jsr update_grounded_byte
    pla
    jsr entity_behavior_switch
    jsr correct_velocity_vector
    jsr update_sprite_pos
    jsr update_animation
    rts
entity_behavior_switch:
    cmp #$1
    bne not_player_entity
    jsr player_update
not_player_entity:
    rts






    


