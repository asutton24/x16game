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
    and #$1
    rts
check_right:
    jsr get_player_input
    and #$2
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
    beq left_not_pressed
    jsr check_right
    beq right_not_pressed
    lda #$0
    ldy #$2
    sty $2
    sta $3
    jmp skip_dpad_checks
right_not_pressed:
    jsr check_left
    beq skip_dpad_checks
    lda #$FF
    ldy #$FE
    sty $2
    sta $3
    jmp skip_dpad_checks
left_not_pressed:
    lda #$0
    sta $2
    sta $3
skip_dpad_checks:
    jsr get_collison_byte
    and #$4
    beq skip_jump_check
    jsr check_a
    beq skip_jump_check
    ldy #$E8
    lda #$FF
    sty $4
    sta $5
skip_jump_check:
    jsr set_entity_vel
    rts
player_init:
    jsr return_to_entity_base
    ldy #$B
    lda #$20
    sta ($7E),y
    iny
    lda #$CF
    sta ($7E),y
    rts