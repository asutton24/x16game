set_level_base:
    tax
    and #$3
    asl
    asl
    asl
    clc
    adc #$A0
    sta $7F
    txa
    lsr
    lsr
    clc
    adc #$1
    sta $0
    rts
return_to_level_base:
    lda #$0
    sta $7E
    lda $7F
    and #$F8
    sta $7F
    rts
draw_playfield:
;assumes level has been loaded
    jsr return_to_level_base
    ldx #$0
    jsr transfer_ptr_to_reg
    lda $2
    sta $7E
    clc
    lda $7F
    adc $3
    sta $7F
    ldy #$0
    lda ($7E),y
    sta $60
    iny
    lda ($7E),y
    sta $62
    jsr ptr_double_inc
playfield_draw_loop:
    dey
    lda ($7E),y
    tax
    ldy $62
    jsr GRAPH_set_colors
    jsr ptr_inc
    ldx #$0
    stx $61
pf_rect_loader:
    ldx $61
    jsr transfer_ptr_to_reg
    jsr ptr_double_inc
    inc $61
    ldx $61
    cpx #$4
    bne pf_rect_loader
    jsr reg_zero
    sec
    jsr GRAPH_draw_rect
    dec $60
    bne playfield_draw_loop
end_playfield_draw_loop:
    rts
