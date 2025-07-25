*= $1000
;y holds low byte, a holds high
;dynamic register addressing has been largely phased out for performance reasons
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
    lda #$0
    tay
    jmp reg_set
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
reg_pop:
    txa
    ldx $3F
    sta $3F
    inx
    ldy $40,x
    inx
    lda $40,x
    pha
    txa
    ldx $3F
    sta $3F
    pla
    jmp reg_set
direct_pop:
    ldx $3F
    inx
    ldy $40,x
    inx
    lda $40,x
    stx $3F
    rts
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
    adc #$0
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
ptr_zero_set_at:
    lda #$0
    tay
    sta ($7E),y
    iny
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
ptrs_equal:
    lda $7F
    cmp $7D
    beq check_low_ptr
    rts
check_low_ptr:
    lda $7E
    cmp $7C
    rts
push_current_ptr:
    ldy $7E
    lda $7F
    jmp direct_push
set_ptr_from_stk:
    jsr direct_pop
    sty $7E
    sta $7F
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
    inx
    lda $40,x
    inx
    inx
    adc $40,x
    sta $40,x 
    dex
    lda $40,x
    inx
    inx
    adc $40,x
    sta $40,x
    dex
    dex
    stx $3F
    clc
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
    lda #$0
    sta $2
    sta $3
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
;shift r0 left x times
shift_left:
    clc
    rol $2
    rol $3
    dex
    bne shift_left
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
ltoeq:
;set carry if less than or equal to based on flags
    beq ltoeq_equal
    bcc ltoeq_less
    clc
    rts
ltoeq_less:
    sec
ltoeq_equal:
    rts
rectangle_collide:
;r1x, r1w, r1y, r1h, r2x, r2w, r2y, r2h
;Carry is set if there is a collision
    lda $3F
    pha
    ldy $E
    lda $F
    jsr direct_push
    ldy $10
    lda $11
    jsr direct_push
    jsr stk_add
    ; r2y + r2h
    ldy $A
    lda $B
    jsr direct_push
    ldy $C
    lda $D
    jsr direct_push
    jsr stk_add
    ; r2x + r2w
    ldy $6
    lda $7
    jsr direct_push
    ldy $8
    lda $9
    jsr direct_push
    jsr stk_add
    ; r1y + r1h
    ldy $2
    lda $3
    jsr direct_push
    ldy $4
    lda $5
    jsr direct_push
    jsr stk_add
    ;r1x + r1w
    lda $2
    sta $12
    lda $3
    sta $13
    lda $A
    sta $4
    lda $B
    sta $5
    jsr direct_pop
    sty $2
    sta $3
    jsr cmp_sixteen
    bcc restore_stack_and_ret
    ldy $E
    lda $F
    sty $4
    sta $5
    jsr direct_pop
    sty $2
    sta $3
    jsr cmp_sixteen
    bcc restore_stack_and_ret
    ldy $12
    lda $13
    sty $2
    sta $3
    jsr direct_pop
    sty $4
    sta $5
    jsr cmp_sixteen
    jsr ltoeq
    bcc restore_stack_and_ret
    ldy $6
    lda $7
    sty $2
    sta $3
    jsr direct_pop
    sty $4
    sta $5
    jsr cmp_sixteen
    jsr ltoeq
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


    



