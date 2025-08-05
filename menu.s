load_title:
    lda #$D2
    sta $2
    lda #$D
    sta $3
    lda #$0
    sta $4
    lda #$A0
    sta $5
    lda #$0
    jsr set_level_base
    jsr mem_cpy
    lda #$0
    jsr full_level_load
    lda #$9
    sta $2
    lda #$28
    sta $3
    ldx #$1E
    ldy #$10
    jsr print_at
    lda $34
    cmp #$1
    beq no_continue
    lda #$C0
    sta $2
    lda #$0
    sta $3
    sta $4
    lda #$2
    sta $5
    jsr level_exit_init
    lda #$2E
    sta $2
    lda #$9
    sta $3
    ldy #$10
    ldx #$2
    jsr print_at
no_continue:
    rts

