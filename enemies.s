create_projectile:
;0 for player projectile 1 for enemy, pos and vel in r0 - r3
    pha
    jsr push_current_ptr
    lda $3
    ldy $2
    jsr direct_push
    lda $5
    ldy $4
    jsr direct_push
    jsr find_empty_entity
    pla
    clc
    adc #$2
    jsr entity_init
    jsr direct_pop
    sty $4
    sta $5
    jsr direct_pop
    sty $2
    sta $3
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
    rts
