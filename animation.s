increment_frame:
    jsr align_vera_to_attributes
    clc
    lda #$1
    sta $9F22
    lda #$4
    adc $9F23
    sta $9F23
    php
    lda #$1
    jsr add_to_vera
    plp
    lda #$0
    adc $9F23
    sta $9F23
no_frame_update:
    rts
update_animation:
; have entity in main ptr
    jsr return_to_entity_base
    ldy #$10
    lda ($7E),y
    beq no_frame_update
    ldy #$E
    lda ($7E),y
    sec
    sbc #$1
    sta ($7E),y
    bne no_frame_update
    ldy #$11
    lda ($7E),y
    ldy #$E
    sta ($7E),y
    iny
    lda ($7E),y
    clc
    adc #$1
    iny
    cmp ($7E),y
    beq reset_to_base_frame
    dey
    sta ($7E),y
    ldy #$1
    lda ($7E),y
    jmp increment_frame
reset_to_base_frame:
    ldy #$1
    lda ($7E),y
    tax
    ldy #$12
    lda ($7E),y
    jsr assign_data_to_sprite
    ldy #$F
    lda #$0
    sta ($7E),y
    rts
load_anim:
;addr low in y, addr high in x
    stx $3
    sty $2
    jsr return_to_entity_base
    lda #$E
    jsr ptr_add
    ldy #$4
    lda ($02),y
    pha
load_anim_loop:
    lda ($02),y
    sta ($7E),y
    dey
    bpl load_anim_loop
    jsr return_to_entity_base
    ldy #$1
    lda ($7E),y
    tax
    pla
    jsr assign_data_to_sprite
    rts
