frame_loop:
    ;store current jiffy
    jsr RDTIM
    sta $3E
    jsr joystick_scan
    lda #$0
    jsr set_entity_base
    jsr apply_x_velocity
    jsr apply_y_velocity
    jsr update_sprite_pos
wait_for_frame_close:
    jsr randbyte
    jsr RDTIM
    cmp $3E
    beq wait_for_frame_close
    jmp frame_loop
rect_collide_tester:
    lda #$20
    ldy #$0
    sta $7F
    sty $7E
    lda #$1F
    sta $3F
    lda #$30
    sta $7D
    sty $7C
    lda #$A
    sta $60
full_collision_loop:
    lda #$0
    pha
copy_loop:
    pla
    pha
    tax
    jsr transfer_ptr_to_reg
    jsr ptr_double_inc
    pla
    tax
    inx
    txa
    pha
    cpx #$8
    bne copy_loop
    pla
    jsr swap_ptrs
    jsr rectangle_collide
    lda #$0
    adc #$0
    ldy #$0
    sta ($7E),y
    jsr ptr_inc
    jsr swap_ptrs
    lda $60
    sec
    sbc #$1
    sta $60
    bne full_collision_loop
    rts

*= $2000
dcb $E1 $B $E1 $BE $85 $46 $B0 $8D $FD $10 $A4 $8B $39 $1A $CC $B4 $40 $53 $FC $66 $7F $12 $A $18 $9C $12 $3 $5D $32 $13 $92 $82 $B7 $5B $2B $42 $4E $1 $A6 $16 $6B $10 $26 $87 $50 $6 $BB $31 $58 $77 $30 $0 $CD $71 $2C $80 $88 $55 $A6 $70 $8F $D7 $DD $27 $78 $34 $36 $12 $19 $3F $8E $4D $D8 $F $23 $36 $91 $4F $3B $F $F3 $0 $54 $9 $AD $53 $D5 $0 $32 $B4 $71 $33 $FA $9 $82 $70 $44 $65 $E7 $79 $72 $41 $A0 $19 $B3 $D $E7 $13 $A0 $44 $B6 $77 $CB $21 $FC $3A $50 $1C $9B $81 $EF $8 $55 $3 $CC $8 $22 $3D $6E $9 $D7 $A8 $C2 $64 $6D $6B $47 $D0 $13 $21 $17 $25 $6E $35 $79 $0 $5E $1 $61 $2 $75 $1E $24 $2F $DD $88 $2E $B4 $66 $6


