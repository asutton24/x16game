sound_init:
    lda #$A
    sta $1
    jsr psg_init
    lda #$0
    ldx #$40
    jsr bas_psgwav
    lda #$4
    sta $1
    rts
note_handler:
    lda #$A
    sta $1
    ldx $33
    lda #$0
    tay
    jsr bas_psgnote
    lda #$0
    sta $33
    lda #$4
    sta $1
    rts