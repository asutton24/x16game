print_at:
;msg pointer in r0, x holds column, y holds row
    txa
    asl
    sta $9F20
    tya
    clc
    adc #$B0
    sta $9F21
    lda #$21
    sta $9F22
    ldy #$0
continue_print:
    lda ($2),y
    beq done_printing
    cmp #$41
    bcc not_a_letter
    sbc #$40
not_a_letter:
    sta $9F23
    inc $2
    bne continue_print
    inc $3
    jmp continue_print
done_printing:
    rts
align_to_text_line:
;line num in a
    clc
    adc #$B0
    sta $9F21
    lda #$0
    sta $9F20
    rts
next_text_line:
    inc $9F21
    lda #$0
    sta $9F20
    rts
store_line:
;basic loop used for line commands, set $9F20-21 before
    ldx #$21
    stx $9F22
store_line_loop:
    sta $9F23
    ldx $9F20
    cpx #$50
    bcc store_line_loop
    clc
    rts
clear_text_line:
    jsr align_to_text_line
    lda #$20
    jmp store_line
clear_full_text:
    ldy #$0
clear_full_text_loop:
    tya
    jsr clear_text_line
    jsr next_text_line
    iny
    cpy #$1D
    bne clear_full_text_loop
    rts
set_text_color:
    tay
    lda #$1
    sta $9F20
    lda #$B0
    sta $9F21
text_color_loop:
    tya
    jsr store_line
    jsr next_text_line
    inc $9F20
    lda $9F21
    cmp #$CE
    bne text_color_loop
    rts
refresh_hud_data:
    lda $37
    and #$F
    ora #$30
    sta $917
    lda $39
    and #$F
    ora #$30
    sta $91E
    rts
draw_hud:
    jsr refresh_hud_data
    lda #$9
    sta $3
    lda #$11
    sta $2
    ldx #$3
    ldy #$1
    jsr print_at
    lda #$19
    sta $2
    ldx #$1E
    ldy #$1
    jmp print_at
update_hud_time:
    lda $39
    cmp #$99
    bne timer_active
    rts
timer_active:
    and #$F
    ora #$30
    sta $91E
    lda #$9
    sta $3
    lda #$1E
    sta $2
    ldx #$23
    ldy #$1
    jmp print_at
update_hud_lives:
    lda $37
    cmp #$FF
    bne lives_active
    rts
lives_active:
    and #$F
    ora #$30
    sta $917
    lda #$9
    sta $3
    lda #$17
    sta $2
    ldx #$9
    ldy #$1
    jmp print_at
intermission:
    pha
    ldx #$0
    jsr reg_push
    lda #$0
    jsr note_handler
    jsr GRAPH_clear
    lda #$E
    jsr clear_text_line
    ldx #$0
    jsr reg_pop
    jsr str_len
    lsr
    sta $60
    sec
    lda #$13
    sbc $60
    tax
    ldy #$E
    jsr print_at
    pla
    jsr clock_wait
    lda #$E
    jmp clear_text_line
