stash_position:
    lda $3
    ldy $2
    jsr direct_push
    lda $5
    ldy $4
    jmp direct_push
restore_position:
    jsr direct_pop
    sty $4
    sta $5
    jsr direct_pop
    sty $2
    sta $3
    rts
enemy_init_starter:
    pha
    jsr stash_position
    jsr find_empty_entity
    pla
    jsr entity_init
    jsr restore_position
    jmp set_entity_pos
create_projectile:
;0 for player projectile 1 for enemy, pos and vel in r0 - r3
    pha
    jsr push_current_ptr
    jsr stash_position
    jsr find_empty_entity
    pla
    clc
    adc #$2
    jsr entity_init
    jsr restore_position
    jsr set_entity_pos
    ldx #$3
copy_proj_vel_to_r0:
    lda $6,x
    sta $2,x
    dex
    bpl copy_proj_vel_to_r0
    jsr set_entity_vel
    ldx #$E
    ldy #$1E
    jsr load_anim
    jsr update_sprite_pos
    jsr return_to_entity_base
    ldy #$1
    lda ($7E),y
    jsr turn_on_sprite
    lda #$B
    jsr ptr_add
    ldy #$77
    lda #$22
    jsr ptr_set_at
    jmp set_ptr_from_stk
update_projectile:
    jsr out_of_bounds
    bcc projectile_still_exists
    jsr destroy_entity
    rts
projectile_still_exists:
    jsr return_to_entity_base
    ldy #$1F
    lda ($7E),y
    and #$3
    beq no_projectile_solid_collision
    jsr destroy_entity
    rts
no_projectile_solid_collision:
    ldy #$0
    lda ($7E),y
    cmp #$2
    beq player_based_projectile
    jsr check_collision_with_player
    bcc not_colliding_with_player
    jsr damage_player
    jsr destroy_entity
not_colliding_with_player:
    rts
player_based_projectile:
    jsr swap_ptrs
    jsr push_current_ptr
    lda #$88
    ldy #$20
    jsr ptr_set
check_all_entities_loop:
    ldy #$0
    lda ($7E),y
    cmp #$5
    bcc not_valid_enemy
    clc
    jsr entity_entity_collision
    bcc not_valid_enemy
    jsr damage_entity
    jsr set_ptr_from_stk
    jsr swap_ptrs
    jsr destroy_entity
    rts
not_valid_enemy:
    jsr goto_next_entity
    lda $7F
    cmp #$8C
    bne check_all_entities_loop
    jsr set_ptr_from_stk
    jsr swap_ptrs
    rts
level_exit_init:
    lda #$4
    jsr enemy_init_starter
    ldx #$3
    ldy #$28
    jsr load_anim
    jsr get_entity_sprite_index
    jsr turn_on_sprite
    ldy #$B
    lda #$61
    sta ($7E),y
    iny
    lda #$4E
    sta ($7E),y
    rts
level_exit_update:
    jsr check_collision_with_player
    bcc level_not_over
    lda #$1
    sta $36
level_not_over:
    rts
spike_init:
    lda #$5
    jsr enemy_init_starter
    ldx #$E
    ldy #$23
    jsr load_anim
    jsr get_entity_sprite_index
    jsr turn_on_sprite
    ldy #$B
    lda #$11
    sta ($7E),y
    iny
    lda #$EE
    sta ($7E),y
    rts
spike_update:
    jsr check_collision_with_player
    bcc spike_not_touching_player
    jsr damage_player
    jsr destroy_entity
spike_not_touching_player:
    rts


