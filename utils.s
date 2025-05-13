*= $1000
;y holds low byte, a holds high
reg_set:
    inx
    pha
    txa
    asl
    tax
    pla
    sta $01,x
    sty $00,x
    rts
reg_get:
    inx
    txa
    asl
    tax
    lda $01,x
    ldy $00,x
    rts
reg_zero:
    inx
    txa
    asl
    tax
    lda #$0
    sta $01,x
    sta $00,x
    rts
ptr_set:
    sta $7F
    sty $7E
    rts
ptr_inc:
    inc $7E
    bne skip_ptr_inc_h
    inc $7F
skip_ptr_inc_h:
    rts
ptr_double_inc:
    jsr ptr_inc
    jmp ptr_inc
transfer_ptr_to_reg:
    ldy #$1
    lda ($7E),y
    pha
    dey
    lda ($7E),y
    tay
    pla
    jmp reg_set
add_sixteen:
;add r1 to r0
    lda $02
    adc $04
    sta $02
    lda $03
    adc $05
    sta $03
    rts
sub_sixteen:
;subtract r1 from r0
    lda $02
    sbc $04
    sta $02
    lda $03
    sbc $05
    sta $03
    rts
