stash_position:
    lda $3
    ldy $2
    jsr direct_push
    lda $5
    ldy $4
    jmp direct_push
stash_params:
    lda $7
    ldy $6
    jsr direct_push
    lda $9
    ldy $8
    jmp direct_push
restore_params:
    jsr direct_pop
    sty $8
    sta $9
    jsr direct_pop
    sty $6
    sta $7
    rts
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
    jsr stash_params
    jsr stash_position
    jsr find_empty_entity
    pla
    jsr entity_init
    jsr restore_position
    jsr set_entity_pos
    jsr return_to_entity_base
    lda #$0
    ldy #$D
    sta ($7E),y
    jsr update_sprite_pos
    jmp restore_params
check_enemy_death:
    jsr return_to_entity_base
    ldy #$D
    lda ($7E),y
    bpl enemy_alive
    jsr destroy_entity
    sec
    rts
enemy_alive:
    clc
    rts
nuke_enemies:
    ldy #$20
    lda #$88
    sta $7F
    sty $7E
keep_destroying_enemies:
    ldy #$0
    lda ($7E),y
    cmp #$4
    beq dont_destroy_exit
    jsr destroy_entity
dont_destroy_exit:
    jsr goto_next_entity
    lda #$8C
    cmp $7F
    bne keep_destroying_enemies
    rts
nuke_everything:
    ldy #$20
    lda #$88
    sta $7F
    sty $7E
keep_destroying_everything:
    jsr destroy_entity
    jsr goto_next_entity
    lda #$8C
    cmp $7F
    bne keep_destroying_everything
    rts
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
    ldy #$77
    lda #$22
    jsr set_hitbox
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
    ldx #$E
    ldy #$28
    jsr load_anim
    jsr get_entity_sprite_index
    jsr turn_on_sprite
    ldy #$61
    lda #$4E
    jsr set_hitbox
    rts
level_exit_update:
    jsr check_collision_with_player
    bcc level_not_over
    lda #$1
    sta $36
level_not_over:
    rts
spike_init:
; pos in r0-r1
    lda #$5
    jsr enemy_init_starter
    ldx #$E
    ldy #$23
    jsr load_anim
    jsr get_entity_sprite_index
    jsr turn_on_sprite
    ldy #$11
    lda #$EE
    jsr set_hitbox
    rts
spike_update:
    jsr check_collision_with_player
    bcc spike_not_touching_player
    jsr damage_player
    jmp destroy_entity
spike_not_touching_player:
    rts
chaser_init:
;pos in r0-r1
    lda #$6
    jsr enemy_init_starter
    ldx #$E
    ldy #$2D
    jsr load_anim
    jsr get_entity_sprite_index
    jsr turn_on_sprite
    ldy #$42
    lda #$8D
    jmp set_hitbox
chaser_update:
    jsr check_enemy_death
    bcc chaser_alive
    rts
chaser_alive:
    jsr apply_gravity
    jsr check_collision_with_player
    bcc chaser_not_touching_player
    jsr damage_player
chaser_fell:
    jmp destroy_entity
chaser_not_touching_player:
    jsr out_of_bounds
    bcs chaser_fell
    lda $3E
    and #$F
    bne dont_realign_chaser
    jsr what_side_of_player_am_i_on
    bcc set_chaser_positive_vel
    jsr get_entity_vel
    ldy #$F8
    lda #$FF
    sty $2
    sta $3
    jsr set_entity_vel
    jsr get_entity_sprite_index
    jmp face_left
set_chaser_positive_vel:
    jsr get_entity_vel
    ldy #$9
    lda #$0
    sty $2
    sta $3
    jsr set_entity_vel
    jsr get_entity_sprite_index
    jmp face_right
dont_realign_chaser:
    rts
drone_init:
; param 1 holds how many frames the drone will travel (low byte only), param 2: 0000 for right 0100 for down 0001 for left 0101 for up
    lda #$7
    jsr enemy_init_starter
    jsr return_to_entity_base
    ldy #$2
    lda #$FF
    sta ($7E),y
    ldy #$D
    lda #$9
    sta ($7E),y
    lda $6
    ldy #$13
    sta ($7E),y
    iny
    sta ($7E),y
    ldy #$7
    lda $9
    beq horizontal_drone
    iny
    iny
horizontal_drone:
    lda $8
    beq drone_pos_vel
    lda #$F9
    sta ($7E),y
    iny
    lda #$FF
    sta ($7E),y 
    bmi drone_vel_set
drone_pos_vel:
    lda #$7
    sta ($7E),y
    iny
    lda #$0
    sta ($7E),y 
drone_vel_set:
    ldx #$E
    ldy #$32
    jsr load_anim
    jsr get_entity_sprite_index
    jsr turn_on_sprite
    ldy #$46
    lda #$86
    jmp set_hitbox
drone_update:
    jsr check_enemy_death
    bcc drone_still_alive
    rts
drone_still_alive:
    jsr return_to_entity_base
    ldy #$13
    lda ($7E),y
    sec
    sbc #$1
    bne drone_same_dir
    jsr get_entity_vel
    ldx #$0
    jsr reg_negate
    ldx #$1
    jsr reg_negate
    jsr set_entity_vel
    jsr return_to_entity_base
    ldy #$14
    lda ($7E),y
    dey
drone_same_dir:
    sta ($7E),y
    jsr check_collision_with_player
    bcc drone_not_touching_player
    jsr damage_player
    jmp destroy_entity
drone_not_touching_player:
    rts


