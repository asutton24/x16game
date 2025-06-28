free_all_sprites:
    ldx #$10
    lda #$0
free_sprite_loop:
    sta $87F0,x
    dex
    bpl free_sprite_loop
    rts
convert_acm_to_spr_record:
;offet from $87F0 stored in x, loads bit mask into a
    pha
    lsr
    lsr
    lsr
    tax
    pla
    and #$7
    tay
    iny
    lda #$0
    sec
shift_mask_loop:
    rol
    dey
    bne shift_mask_loop
    rts
check_sprite_availability:
    jsr convert_acm_to_spr_record
    and $87F0,x
    cmp #$0
    rts
reserve_sprite:
    jsr convert_acm_to_spr_record
    ora $87F0,x
    sta $87F0,x
    rts
free_sprite:
    jsr convert_acm_to_spr_record
    eor #$FF
    and $87F0,x
    sta $87F0,x
    rts
find_available_sprite:
    lda #$0
find_availibility_loop:
    pha
    jsr check_sprite_availability
    pla
    tax
    inx
    txa
    bne find_availibility_loop
    rts
align_vera_to_attributes:
    tay
    lda #$0
    tax
    jsr reg_set
    ldx #$1
    ldy #$8
    jsr reg_set
    jsr mult_sixteen
    lda #$FC
    ldy #$0
    ldx #$1
    jsr reg_set
    jsr add_sixteen
    lda $2
    sta $9F20
    lda $3
    sta $9F21
    lda $9F22
    and #$E
    ora #$11
    sta $9F22
    rts
calculate_spritesheet_address:
    tay
    lda #$0
    tax
    jsr reg_set
    ldy #$4
    ldx #$1
    jsr reg_set
    jsr mult_sixteen
    lda #$9
    ldy #$80
    ldx #$1
    jsr reg_set
    jsr add_sixteen
    rts
assign_data_to_sprite:
;x holds the attribute, a holds the sprite table index
    pha
    txa
    jsr align_vera_to_attributes
    pla
    jsr calculate_spritesheet_address
    ldx #$0
    jsr reg_get
    sty $9F23
    sta $9F23
    rts
initialize_sprite:
    jsr align_vera_to_attributes
    lda #$80
    sta $9F23
    lda #$9
    sta $9F23
    lda #$0
    ldx #$5
sprite_init_zero_loop:
    sta $9F23
    dex
    bne sprite_init_zero_loop
    lda #$50
    sta $9F23
    rts
turn_off_sprite:
    jsr align_vera_to_attributes
    lda #$6
    jsr add_to_vera
    lda $9F22
    and #$F
    sta $9F22
    lda $9F23
    and #$F3
    sta $9F23
    rts
turn_on_sprite:
    jsr turn_off_sprite
    ora #$C
    sta $9F23
    rts
set_sprite_pos:
;x in r0, y in r1
    pha
    ldx #$0
    ldy #$3
    jsr reg_mov
    ldx #$1
    ldy #$4
    jsr reg_mov
    pla
    jsr align_vera_to_attributes
    lda #$2
    jsr add_to_vera
    lda $8
    sta $9F23
    lda $9
    sta $9F23
    lda $A
    sta $9F23
    lda $B
    sta $9F23
    rts