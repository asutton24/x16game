create_projectile:
;0 for player projectile 1 for enemy, pos and vel in r0 - r3
    pha
    jsr find_empty_entity
    pla
    clc
    adc #$2
    jsr entity_init
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
    lda #$B
    jsr ptr_add
    ldy #$77
    lda #$22
    jmp ptr_set_at

