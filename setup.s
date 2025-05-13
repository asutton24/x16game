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
    jsr set_level_base
    jsr draw_playfield
    rts

