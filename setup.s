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
    rts
start:
    jsr ram_init
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
    jsr load_sprite_sheet
    lda #$0
    jsr initialize_sprite
    lda #$0
    ldx #$0
    jsr assign_data_to_sprite
    lda #$0
    ldy #$FF
    ldx #$0
    jsr reg_set
    ldy #$80
    ldx #$1
    jsr reg_set
    lda #$0
    jsr set_sprite_pos
    lda #$0
    jsr turn_on_sprite
    rts
    lda #$0
    jsr set_level_base
    jsr draw_playfield
    rts

