update_player_sprite:
    jsr return_to_entity_base
    ldy #$2
    lda ($7E),y
    pha
    ldy #$1E
    lda ($7E),y
    pha
    iny
    lda ($7E),y
    pha
    jsr get_entity_vel
    jsr return_to_entity_base
    clc
    lda $3
    bpl not_left_facing
    ldy #$1
    lda ($7E),y
    jsr face_left
    lda #$1
    ldy #$1D
    sta ($7E),y
    sec
    jmp skip_right_facing
not_left_facing:
    bne set_right_facing
    lda $2
    beq skip_right_facing
set_right_facing:
    ldy #$1
    lda ($7E),y
    jsr face_right
    lda #$0
    ldy #$1D
    sta ($7E),y
    sec
skip_right_facing:
    pla
    ldx #$E
    and #$4
    bne not_jumping_spr
    clc
    pla
    beq not_jmpsht_spr
    pla
    cmp #$5
    beq skip_jmpsht_change
    ldy #$19
    jsr load_anim
    ldy #$2
    lda #$5
    sta ($7E),y
skip_jmpsht_change:
    rts
not_jmpsht_spr:
    pla
    cmp #$4
    beq skip_jmpsht_change
    ldy #$14
    jsr load_anim
    ldy #$2
    lda #$4
    sta ($7E),y
    rts
not_jumping_spr:
    lda #$0
    sta $4
    sta $5
    jsr cmp_sixteen
    beq not_running_spr
    pla
    beq not_runshot_spr
    pla
    cmp #$3
    beq skip_jmpsht_change
    ldy #$F
    jsr load_anim
    ldy #$2
    lda #$3
    sta ($7E),y
    rts
not_runshot_spr:
    pla
    cmp #$2
    beq skip_jmpsht_change
    ldy #$A
    jsr load_anim
    ldy #$2
    tya
    sta ($7E),y
    rts
not_running_spr:
    pla
    beq not_idleshot
    pla
    cmp #$1
    beq skip_jmpsht_change
    ldy #$5
    jsr load_anim
    ldy #$2
    lda #$1
    sta ($7E),y
    rts
not_idleshot:
    pla
    beq skip_jmpsht_change
    ldy #$0
    jsr load_anim
    ldy #$2
    lda #$0
    sta ($7E),y
    rts
get_player_input:
    lda #$1
    jsr joystick_get
    pha
    tya
    beq use_controller_input
    pla
    lda #$0
    jsr joystick_get
    pha
use_controller_input:
    txa
    and #$80
    lsr
    sta $60
    pla
    and #$BF
    ora $60
    rts
;button is pressed if z flag is clear
check_left:
    jsr get_player_input
    and #$1
    rts
check_right:
    jsr get_player_input
    and #$2
    rts
check_b:
    jsr get_player_input
    and #$80
    rts
check_a:
    jsr get_player_input
    and #$40
    rts
verify_valid_dpad:
    jsr get_player_input
    and #$3
    cmp #$3
    rts
decrement_shooting_hold:
    sec
    sbc #$1
    sta ($7E),y
    jmp skip_shooting_check
;called within entity update
player_update:
    jsr apply_gravity
    jsr get_entity_vel
    jsr verify_valid_dpad
    beq left_not_pressed
    jsr check_right
    beq right_not_pressed
    lda #$0
    ldy #$8
    sty $2
    sta $3
    jmp skip_dpad_checks
right_not_pressed:
    jsr check_left
    beq skip_dpad_checks
    lda #$FF
    ldy #$F9
    sty $2
    sta $3
    jmp skip_dpad_checks
left_not_pressed:
    lda #$0
    sta $2
    sta $3
skip_dpad_checks:
    jsr get_collision_byte
    and #$4
    beq skip_jump_check
    jsr check_b
    bne skip_jump_check
    ldy #$EE
    lda #$FF
    sty $4
    sta $5
skip_jump_check:
    jsr set_entity_vel
    jsr return_to_entity_base
    ldy #$1E
    lda ($7E),y
    bne decrement_shooting_hold
    jsr check_a
    bne skip_shooting_check
    lda #$10
    ldy #$1E
    sta ($7E),y
    ldy #$1D
    lda ($7E),y
    pha
    jsr get_entity_pos
    pla
    bne negative_proj_dir
    lda #$0
    ldy #$14
    sty $6
    sta $7
    bpl finished_proj_dir
negative_proj_dir:
    lda #$FF
    ldy #$EC
    sty $6
    sta $7
finished_proj_dir:
    lda #$0
    sta $8
    sta $9
    jsr create_projectile
skip_shooting_check:
    jsr update_player_sprite
    rts
player_init:
    jsr return_to_entity_base
    ldy #$B
    lda #$51
    sta ($7E),y
    iny
    lda #$6E
    sta ($7E),y
    ldy #$10
    lda #$0
    sta ($7E),y
    ldy #$2
    sta ($7E),y
    ldy #$1E
    sta ($7E),y
    dey
    sta ($7E),y
    ldy #$1
    lda ($7E),y
    pha
    tax
    lda #$1
    jsr assign_data_to_sprite
    jsr update_sprite_pos
    pla
    jsr turn_on_sprite
    rts
check_collision_with_player:
;entity 0 should ALWAYS be the player
    lda $7D
    ldy $7C
    jsr direct_push
    lda #$88
    ldy #$0
    sty $7C
    sta $7D
    jsr entity_entity_collision
    jsr direct_pop
    sta $7D
    sty $7C
    rts
damage_player:
    dec $880D
    rts
what_side_of_player_am_i_on:
; carry means you are on the right of the player
    jsr get_entity_pos
    lda $8803
    sta $4
    lda $8804
    sta $5
    jmp cmp_sixteen