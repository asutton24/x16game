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
;button is pressed if z flag is clear
check_left:
    jsr get_player_input
    and #$2
    rts
check_right:
    jsr get_player_input
    and #$1
    rts
check_b:
    jsr get_player_input
    and #$80
    rts
check_a:
    jsr get_player_input
    and #$40
    rts
verify_valid_dpad:
    jsr get_player_input
    and #$3
    cmp #$3
    rts
;called within entity update
player_update:
    jsr apply_gravity
    jsr get_entity_vel
    jsr verify_valid_dpad
    beq skip_dpad_checks
    jsr check_right
    beq right_not_pressed
    lda #$0
    ldy #$2
    tax
    jsr reg_set
    jmp skip_dpad_checks
right_not_pressed:
    jsr check_left
    beq skip_dpad_checks
    lda #$FF
    ldy #$FE
    ldx #$1
    jsr reg_set
skip_dpad_checks:
    jsr set_entity_vel

player_init:
    lda #$0
    jsr set_entity_base
    jsr destroy_entity
    