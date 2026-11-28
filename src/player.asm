update_player:
    cmp byte [invuln_timer], 0
    je .chk_land_timer
    dec byte [invuln_timer]
.chk_land_timer:
    cmp byte [land_timer], 0
    je .horiz_input
    dec byte [land_timer]

.horiz_input:
    mov bx, MAX_VX_WALK
    mov dx, ACCEL_WALK
    cmp byte [key_shift], 1
    jne .chk_air_accel
    mov bx, MAX_VX_RUN
    mov dx, ACCEL_RUN
.chk_air_accel:
    cmp byte [grounded], 1
    je .dir_buttons
    mov dx, ACCEL_AIR

.dir_buttons:
    mov al, [key_left]
    cmp al, [key_right]
    je .apply_friction

    cmp byte [key_right], 1
    je .move_right

    mov byte [facing_dir], -1
    cmp word [player_vx], 0
    jle .accel_left
    cmp byte [grounded], 1
    jne .accel_left
    sub word [player_vx], SKID_DECEL
    jmp .clamp_vx
.accel_left:
    sub [player_vx], dx
    jmp .clamp_vx

.move_right:
    mov byte [facing_dir], 1
    cmp word [player_vx], 0
    jge .accel_right
    cmp byte [grounded], 1
    jne .accel_right
    add word [player_vx], SKID_DECEL
    jmp .clamp_vx
.accel_right:
    add [player_vx], dx
    jmp .clamp_vx

.apply_friction:
    mov dx, FRICTION_GND
    cmp byte [grounded], 1
    je .do_fric
    mov dx, DRAG_AIR
.do_fric:
    mov ax, [player_vx]
    or ax, ax
    jz .clamp_vx
    js .fric_neg
    sub ax, dx
    jns .store_fric
    xor ax, ax
    jmp .store_fric
.fric_neg:
    add ax, dx
    js .store_fric
    xor ax, ax
.store_fric:
    mov [player_vx], ax

.clamp_vx:
    mov ax, [player_vx]
    cmp ax, bx
    jle .chk_neg_max
    mov [player_vx], bx
    jmp .apply_x
.chk_neg_max:
    neg bx
    cmp ax, bx
    jge .apply_x
    mov [player_vx], bx

.apply_x:
    mov ax, [player_vx]
    add [player_x_frac], al
    mov al, ah
    cbw
    adc [player_x], ax

    mov ax, [camera_x]
    cmp word [player_x], ax
    jge .chk_world_right
    mov [player_x], ax
    mov byte [player_x_frac], 0
    mov word [player_vx], 0

.chk_world_right:
    cmp word [player_x], WORLD_W - 16
    jle .resolve_x
    mov word [player_x], WORLD_W - 16
    mov byte [player_x_frac], 0
    mov word [player_vx], 0

.resolve_x:
    call resolve_player_x_collision

    cmp byte [edge_space], 1
    jne .gravity_step
    mov byte [edge_space], 0
    cmp byte [grounded], 1
    jne .gravity_step

    mov byte [grounded], 0
    mov byte [jump_hold_cnt], JUMP_HOLD_MAX
    mov ax, [player_vx]
    or ax, ax
    jns .abs_vx_ok
    neg ax
.abs_vx_ok:
    cmp ax, 0200h
    jae .fast_jump
    mov word [player_vy], JUMP_VEL_WALK
    jmp .gravity_step
.fast_jump:
    mov word [player_vy], JUMP_VEL_RUN

.gravity_step:
    mov dx, GRAV_NORMAL
    cmp word [player_vy], 0
    jge .add_grav
    cmp byte [key_space], 1
    jne .end_hold
    cmp byte [jump_hold_cnt], 0
    je .add_grav
    dec byte [jump_hold_cnt]
    mov dx, GRAV_HOLD
    jmp .add_grav
.end_hold:
    mov byte [jump_hold_cnt], 0

.add_grav:
    add [player_vy], dx
    cmp word [player_vy], MAX_VY_FALL
    jle .apply_y
    mov word [player_vy], MAX_VY_FALL

.apply_y:
    mov ax, [player_vy]
    add [player_y_frac], al
    mov al, ah
    cbw
    adc [player_y], ax

    cmp word [player_y], HUD_H
    jge .resolve_y
    mov word [player_y], HUD_H
    mov byte [player_y_frac], 0
    cmp word [player_vy], 0
    jge .resolve_y
    mov word [player_vy], 0

.resolve_y:
    call resolve_player_y_collision
    call collect_overlapping_coins

    cmp word [player_y], PIT_DEATH_Y
    jl .chk_flagpole
    call start_player_death
    ret

.chk_flagpole:
    mov ax, [player_x]
    add ax, 12
    cmp ax, FLAGPOLE_X
    jge .grabbed_pole
    jmp near .update_anim

.grabbed_pole:
    mov ax, [player_y]
    cmp ax, 48
    jg .tier2
    mov ax, 5000
    jmp .award_flag
.tier2:
    cmp ax, 72
    jg .tier3
    mov ax, 2000
    jmp .award_flag
.tier3:
    cmp ax, 100
    jg .tier4
    mov ax, 800
    jmp .award_flag
.tier4:
    cmp ax, 124
    jg .tier5
    mov ax, 400
    jmp .award_flag
.tier5:
    mov ax, 100
.award_flag:
    mov [flag_bonus], ax
    call add_score_ax

    mov word [player_x], FLAGPOLE_X - 8
    mov byte [player_x_frac], 0
    mov word [player_vx], 0
    mov word [player_vy], 0
    mov byte [flag_phase], 0
    mov byte [game_state], ST_FLAGSLIDE
    ret

.update_anim:
    cmp byte [grounded], 0
    je .in_air_anim

    cmp byte [land_timer], 0
    je .ground_anim
    mov byte [mario_anim], 4
    ret

.ground_anim:
    mov ax, [player_vx]
    or ax, ax
    jnz .moving_anim
    mov byte [mario_anim], 0
    mov byte [anim_tick], 0
    ret

.moving_anim:
    jns .abs_ok
    neg ax
.abs_ok:
    inc byte [anim_tick]
    mov cl, 4
    cmp ax, 0200h
    jb .walk_cadence
    mov cl, 2
.walk_cadence:
    cmp [anim_tick], cl
    jb .done_anim
    mov byte [anim_tick], 0
    inc byte [mario_anim]
    cmp byte [mario_anim], 3
    jbe .done_anim
    mov byte [mario_anim], 1
.done_anim:
    ret

.in_air_anim:
    cmp word [player_vy], 0
    jl .jump_up_anim
    mov byte [mario_anim], 5
    ret
.jump_up_anim:
    mov byte [mario_anim], 4
    ret
collect_overlapping_coins:
    call get_mario_height
    mov si, [player_x]
    add si, 2
    mov di, [player_x]
    add di, 13
    mov cl, 4
    shr si, cl
    shr di, cl

    mov ax, [player_y]
    mov dx, [player_y]
    add dx, bx
    dec dx
    shr ax, cl
    shr dx, cl

.row_loop:
    cmp ax, dx
    jg .done
    cmp ax, 0
    jl .next_row
    cmp ax, MAP_ROWS
    jge .done

    mov bx, si
.col_loop:
    cmp bx, di
    jg .next_row
    cmp bx, 0
    jl .next_col
    cmp bx, MAP_COLS
    jge .next_row

    push ax
    push dx
    mov dl, MAP_COLS
    mul dl
    add ax, bx
    mov bp, ax
    cmp byte [work_level_map + bp], T_COIN
    jne .no_coin
    mov byte [work_level_map + bp], T_EMPTY
    call award_coin
    mov ax, 200
    call add_score_ax
.no_coin:
    pop dx
    pop ax

.next_col:
    inc bx
    jmp .col_loop
.next_row:
    inc ax
    jmp .row_loop
.done:
    ret
