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
reg_push:
    jsr reg_get
direct_push:
    ldx $3F
    sta $40,x
    dex
    sty $40,x
    dex
    stx $3F
    rts
direct_pop:
    txa
    ldx $3F
    sta $3F
    ldy $40,x
    inx
    lda $40,x
    inx
    pha
    txa
    ldx $3F
    sta $3F
    pla
    rts
reg_pop:
    jsr direct_pop
    jmp reg_set
reg_negate:
    inx
    txa
    asl
    tax
    clc
    lda $0,x
    eor #$FF
    adc #$1
    sta $0,x
    lda $1,x
    eor #$FF
    adc #$0
    sta $1,x
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
ptr_sub:
    tax
    lda $7E
    stx $7E
    sec
    sbc $7E
    sta $7E
    lda $7F
    sbc #$0
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
fetch_ptr:
    ldy #$1
    lda ($7E),y
    pha
    dey
    lda ($7E),y
    tay
    pla
    rts
transfer_ptr_to_reg:
    jsr fetch_ptr
    jmp reg_set
transfer_ptr_to_stk:
    jsr fetch_ptr
    jmp direct_push
transfer_reg_to_ptr:
    jsr reg_get
    jmp ptr_set_at
pop_to_ptr:
    jsr direct_pop
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
mult_eight:
; $60 * $61
	lda #$0
	sta $62
	ldx #$8
multLoop:
	lda $61
	and #$1
	beq noAdd
	lda $62
	clc
	adc $60
	sta $62
noAdd:
	asl $60
	lsr $61
	dex
	bne multLoop
    lda $62
	rts
add_to_vera:
    clc
    adc $9F20
    sta $9F20
    lda #$0
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
stk_add:
;add the top 2 values on the stack
    ldx $3F
    clc
    lda $40,x
    inx
    inx
    adc $40,x 
    dex
    lda $40,x
    inx
    inx
    adc $40,x
    dex
    stx $3F
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
cmp_sixteen:
;cmp r0 and r1
    lda $3
    cmp $5
    beq upper_byte_equal
    rts
upper_byte_equal:
    lda $2
    cmp $4
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
flip_carry:
    bcs turn_off_carry
    sec
    rts
turn_off_carry:
    clc
    rts
rectangle_collide:
;r1x, r1w, r1y, r1h, r2x, r2w, r2y, r2h
;Carry is set if there is a collision
    lda $3F
    pha
    ldx #$6
    jsr reg_push
    ldx #$7
    jsr reg_push
    jsr stk_add
    ldx #$4
    jsr reg_push
    ldx #$5
    jsr reg_push
    jsr stk_add
    ldx #$2
    jsr reg_push
    ldx #$3
    jsr reg_push
    jsr stk_add
    ldx #$0
    jsr reg_push
    ldx #$1
    jsr reg_push
    jsr stk_add
    ldx #$0
    ldy #$8
    jsr reg_mov
    ldx #$4
    ldy #$1
    jsr reg_mov
    ldx #$0
    jsr reg_pop
    jsr cmp_sixteen
    bcc restore_stack_and_ret
    ldx #$6
    ldy #$1
    jsr reg_mov
    ldx #$0
    jsr reg_pop
    jsr cmp_sixteen
    bcc restore_stack_and_ret
    ldx #$8
    ldy #$0
    jsr reg_mov
    ldx #$1
    jsr reg_pop
    jsr cmp_sixteen
    jsr flip_carry
    bcc restore_stack_and_ret
    ldx #$2
    ldy #$0
    jsr reg_mov
    ldx #$1
    jsr reg_pop
    jsr cmp_sixteen
    jsr flip_carry
restore_stack_and_ret:
    pla
    sta $3F
    rts
randinit:
	jsr entropy_get
	stx $3C
	and #$FC
	bne multiplierNotZero
	txa
	and #$FC
multiplierNotZero:
	ora #$1
	sta $3B
	tya
	ora #$1
	sta $3D
	rts
randbyte:
	lda $3B
	sta $60
	lda $3C
	sta $61
	jsr mult_eight
	clc
	adc $3D
	sta $3C
	rts
wait_one_jiffy:
    jsr RDTIM
    sta $60
continue_waiting:
    jsr RDTIM
    cmp $60
    beq continue_waiting
    rts


    



