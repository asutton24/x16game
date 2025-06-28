get_player_input:
    lda #$1
    jsr joystick_get
    pha
    tya
    beq use_controller_input
    pla
    lda #$0
    jsr joystick_get
    pha
use_controller_input:
    txa
    and #$80
    lsr
    sta $60
    pla
    and #$BF
    ora $60
    rts
player_init:
    lda #$0
    jsr set_entity_base
    jsr destroy_entity
    