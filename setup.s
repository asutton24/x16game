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
    lda #$1F
    sta $3F
    lda #$80
    jsr screen_mode
    lda #$0
    ldx #$0
    jsr reg_zero
    jsr GRAPH_init
    lda #$0
    tax
    tay
    jsr GRAPH_set_colors
    jsr GRAPH_clear
    lda #$20
    sta $2
    lda #$9
    sta $3
    lda #$1
    jsr set_text_color
    lda #$0
    sta $35
    tax
    jsr load_sprite_sheet
    jsr ram_init
    lda #$1
    ldx #$0
    jsr entity_init
    jsr player_init
    jmp title_level
