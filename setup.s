ram_init:
    jsr free_all_sprites
    lda #$3F
entity_ram_init:
    pha
    jsr entity_clear
    pla
    sec
    sbc #$1
    bpl entity_ram_init
    lda #$7F
sprite_attribute_init:
    pha
    jsr initialize_sprite
    pla
    sec
    sbc #$1
    bpl sprite_attribute_init
    clc
    lda $9F29
    ora #$40
    sta $9F29
    lda #$1F
    sta $3F
    jsr randinit
    rts
start:
    lda #$80
    jsr screen_mode
    lda #$0
    ldx #$0
    jsr load_level_into_ram
    ldx #$0
    jsr reg_zero
    jsr GRAPH_init
    lda #$0
    tax
    tay
    jsr GRAPH_set_colors
    jsr GRAPH_clear
    lda #$0
    ldx #$0
    jsr load_level_into_ram
    lda #$0
    jsr set_level_base
    jsr swap_ptrs
    lda #$0
    ldx #$0
    jsr load_sprite_sheet
    jsr ram_init
    lda #$1
    ldx #$0
    jsr entity_init
    lda #$0
    ldy #$1
    tax
    jsr reg_set
    ldx #$1
    tay
    jsr reg_set
    jsr set_entity_vel
    ldx #$1
    ldy #$0
    jsr reg_mov
    lda #$0
    ldy #$FC
    ldx #$1
    jsr reg_set
    lda #$0
    jsr set_entity_pos
    jmp frame_loop