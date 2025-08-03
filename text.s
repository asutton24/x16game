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



