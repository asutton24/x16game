start:
    lda #$80
    jsr screen_mode
    ldx #$0
    jsr reg_zero
    jsr GRAPH_init
    lda #$1
    ldx #$1
    ldy #$0
    jsr GRAPH_set_colors
    jsr GRAPH_clear
    lda #$0
    jsr set_level_base
    jsr draw_playfield
    rts

