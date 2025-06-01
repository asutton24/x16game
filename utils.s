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
reg_mov:
;move x to y
    inx
    txa
    asl
    tax
    iny
    tya
    asl
    tay
    lda $00,x
    pha
    lda $01,x
    pha
    tya
    tax
    pla
    sta $01,x
    pla
    sta $00,x
    rts
ptr_set:
    sta $7F
    sty $7E
    rts
ptr_add:
    clc
    adc $7E
    sta $7E
    lda $7F
    adc #$00
    sta $7F
    rts
ptr_set_at:
    pha
    tya
    tax
    pla
    ldy #$1
    sta ($7E),y
    txa
    dey
    sta ($7E),y
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
transfer_reg_to_ptr:
    jsr reg_get
    jmp ptr_set_at
swap_ptrs:
    lda $7E
    pha
    lda $7F
    pha
    lda $7C
    sta $7E
    lda $7D
    sta $7F
    pla
    sta $7D
    pla
    sta $7C
    rts
add_to_vera:
    clc
    adc $9F20
    sta $9F20
    adc $9F21
    sta $9F21
    clc
    rts
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
mult_sixteen:
;multiply r0 and r1, r2 is destroyed
    lda $2
    sta $6
    lda $3
    sta $7
    ldy #$10
    ldx #$0
    jsr reg_zero
mult_sixteen_loop:
    lda $6
    and #$1
    beq no_add_needed
    clc
    jsr add_sixteen
no_add_needed:
    clc
    rol $4
    rol $5
    clc
    ror $7
    ror $6 
    dey
    bne mult_sixteen_loop
    rts
fixed_to_int:
;Converts fixed point number in r0 to integer
    clc
    ror $3
    ror $2
    clc
    ror $3
    ror $2
    rts


