;make sure player is initialized first!
full_level_load:
    jsr set_level_base
    jsr GRAPH_clear
    jsr draw_playfield
    jsr load_enemies
    jsr return_to_level_base
    ldy #$7
    lda ($7E),y
    pha
    dey
    lda ($7E),y
    clc
    adc $7E
    sta $7E
    pla
    adc $7F
    sta $7F
    lda #$0
pull_extras:
    pha
    jsr transfer_ptr_to_reg
    jsr ptr_double_inc
    pla
    tax
    inx
    txa
    cmp #$4
    bne pull_extras
    jsr swap_ptrs
    lda #$88
    ldy #$0
    sty $7E
    sta $7F
    jsr set_entity_pos
    ldy $6
    lda $7
    sty $2
    sta $3
    ldy $8
    lda $9
    sty $4
    sta $5
    jsr level_exit_init
    rts
set_level_base:
    tax
    and #$7
    asl
    asl
    clc
    adc #$A0
    sta $7F
    txa
    lsr
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
    and #$FC
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
    ldy #$0
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
load_enemies:
    jsr return_to_level_base
    ldy #$5
    lda ($7E),y
    pha
    dey
    lda ($7E),y
    clc
    adc $7E
    sta $7E
    pla
    adc $7F
    sta $7F
    ldy #$0
    lda ($7E),y
    beq end_playfield_draw_loop
    pha
    jsr ptr_inc
enemy_loader:
    ldy #$0
    lda ($7E),y
    pha
    jsr ptr_inc
    ldy #$7
    ldx #$7
keep_loading_regs:
    lda ($7E),y
    sta $2,x
    dex
    dey
    bpl keep_loading_regs
    lda #$8
    jsr ptr_add
    jsr swap_ptrs
    pla
    cmp #$5
    bne not_spike_init
    jsr spike_init
    jmp done_init
not_spike_init:
    cmp #$6
    bne not_chaser_init
    jsr chaser_init
    jmp done_init
not_chaser_init:
    cmp #$7
    bne not_drone_init
    jsr drone_init
not_drone_init:
done_init:
    jsr swap_ptrs
    pla
    sec
    sbc #$1
    pha
    bne enemy_loader
    pla
    rts
