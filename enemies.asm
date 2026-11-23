; ENEMY AI, MOVEMENT, SHELLS, STOMPS AND COMBO SCORING

update_enemies:
    mov si, enemies
    xor cx, cx
.enemy_loop:
    cmp cx, MAX_ENEMIES
    jb .in_range
    jmp near .done
.in_range:
    cmp byte [si + 0], EN_NONE
    jne .check_vis
    jmp near .next_enemy
.check_vis:
    mov ax, [camera_x]
    sub ax, 32
    cmp [si + 2], ax
    jge .check_vis_r
    jmp near .next_enemy
.check_vis_r:
    mov ax, [camera_x]
    add ax, 352
    cmp [si + 2], ax
    jle .check_flat
    jmp near .next_enemy

.check_flat:
    cmp byte [si + 1], ES_FLAT
    jne .active_enemy
    cmp byte [si + 12], 0
    je .remove_enemy
    dec byte [si + 12]
    jmp near .next_enemy
.remove_enemy:
    mov byte [si + 0], EN_NONE
    mov byte [si + 1], ES_DEAD
    jmp near .next_enemy

.active_enemy:
    cmp byte [si + 12], 0
    je .move_horiz
    dec byte [si + 12]

.move_horiz:
    mov ax, [si + 8]
    add [si + 4], al
    mov al, ah
    cbw
    adc [si + 2], ax

    cmp word [si + 2], 2
    jg .chk_eright
    mov word [si + 2], 2
    neg word [si + 8]
    mov byte [si + 14], 1
    jmp .check_ewall
.chk_eright:
    cmp word [si + 2], WORLD_W - 18
    jl .check_ewall
    mov word [si + 2], WORLD_W - 18
    neg word [si + 8]
    mov byte [si + 14], -1

.check_ewall:
    cmp word [si + 8], 0
    je .enemy_grav
    mov ax, [si + 2]
    add ax, 14
    cmp word [si + 8], 0
    jg .ewall_sample
    mov ax, [si + 2]
    add ax, 1
.ewall_sample:
    mov dx, [si + 5]
    add dx, 8
    call get_tile_at_pixel
    call is_tile_solid
    jnc .enemy_grav
    neg word [si + 8]
    neg byte [si + 14]

.enemy_grav:
    add word [si + 10], GRAV_NORMAL
    cmp word [si + 10], MAX_VY_FALL
    jle .ey_step
    mov word [si + 10], MAX_VY_FALL
.ey_step:
    mov ax, [si + 10]
    add [si + 7], al
    mov al, ah
    cbw
    adc [si + 5], ax

    mov dx, [si + 5]
    add dx, 16
    mov ax, [si + 2]
    add ax, 4
    call get_tile_at_pixel
    call is_tile_solid
    jc .eland
    mov ax, [si + 2]
    add ax, 11
    call get_tile_at_pixel
    call is_tile_solid
    jnc .epit
.eland:
    mov ax, [si + 5]
    add ax, 16
    and ax, 0FFF0h
    sub ax, 16
    mov [si + 5], ax
    mov byte [si + 7], 0
    mov word [si + 10], 0

.epit:
    cmp word [si + 5], PIT_DEATH_Y
    jl .eanim
    mov byte [si + 0], EN_NONE
    mov byte [si + 1], ES_DEAD
    jmp .next_enemy

.eanim:
    inc byte [si + 13]

    cmp byte [si + 1], ES_SHELL_MOVE
    jne .mario_vs_enemy
    call check_shell_vs_enemies

.mario_vs_enemy:
    call check_mario_vs_enemy
    cmp byte [game_state], ST_PLAYING
    jne .done

.next_enemy:
    add si, ENEMY_STRUCT_SZ
    inc cx
    jmp near .enemy_loop
.done:
    ret
check_shell_vs_enemies:
    push bx
    push cx
    push dx
    push di

    mov di, enemies
    xor dx, dx
.loop:
    cmp dx, MAX_ENEMIES
    jae .done
    cmp dx, cx
    je .next
    cmp byte [di + 0], EN_NONE
    je .next
    cmp byte [di + 1], ES_FLAT
    je .next

    mov ax, [si + 2]
    add ax, 14
    cmp ax, [di + 2]
    jl .next
    mov ax, [di + 2]
    add ax, 14
    cmp ax, [si + 2]
    jl .next

    mov ax, [si + 5]
    add ax, 14
    cmp ax, [di + 5]
    jl .next
    mov ax, [di + 5]
    add ax, 14
    cmp ax, [si + 5]
    jl .next

    mov byte [di + 0], EN_NONE
    mov byte [di + 1], ES_DEAD
    mov ax, 500
    call add_score_ax

.next:
    add di, ENEMY_STRUCT_SZ
    inc dx
    jmp .loop
.done:
    pop di
    pop dx
    pop cx
    pop bx
    ret

check_mario_vs_enemy:
    mov ax, [player_x]
    add ax, 13
    mov bx, [si + 2]
    inc bx
    cmp ax, bx
    jl .no_hit_far

    mov ax, [si + 2]
    add ax, 14
    mov bx, [player_x]
    add bx, 2
    cmp ax, bx
    jl .no_hit_far

    call get_mario_height
    mov ax, [player_y]
    add ax, bx
    dec ax
    mov dx, [si + 5]
    add dx, 2
    cmp ax, dx
    jl .no_hit_far

    mov ax, [si + 5]
    add ax, 15
    cmp ax, [player_y]
    jge .hit_ok
.no_hit_far:
    jmp .no_hit
.hit_ok:

    cmp byte [si + 1], ES_SHELL_IDLE
    jne .not_idle_shell

    mov byte [si + 1], ES_SHELL_MOVE
    mov byte [si + 12], 8
    mov ax, 400
    call add_score_ax

    mov ax, [player_x]
    cmp ax, [si + 2]
    jg .kick_left
    mov word [si + 8], SHELL_SPEED
    mov byte [si + 14], 1
    jmp .shell_bounce
.kick_left:
    mov word [si + 8], -SHELL_SPEED
    mov byte [si + 14], -1
.shell_bounce:
    cmp word [player_vy], 0
    jle .no_hit
    mov word [player_vy], -0280h
    ret

.not_idle_shell:
    cmp word [player_vy], 0
    jle .side_hit

    call get_mario_height
    mov ax, [player_y]
    add ax, bx
    mov dx, [si + 5]
    add dx, 10
    cmp ax, dx
    jg .side_hit

    mov word [player_vy], -0380h
    cmp byte [key_space], 1
    jne .stomp_score
    mov word [player_vy], -0440h
    mov byte [jump_hold_cnt], 6

.stomp_score:
    call award_stomp_combo

    cmp byte [si + 0], EN_GOOMBA
    jne .stomp_koopa
    mov byte [si + 1], ES_FLAT
    mov word [si + 8], 0
    mov byte [si + 12], FPS_HZ
    ret

.stomp_koopa:
    mov byte [si + 1], ES_SHELL_IDLE
    mov word [si + 8], 0
    mov byte [si + 12], 8
    ret

.side_hit:
    cmp byte [si + 1], ES_SHELL_MOVE
    jne .chk_invuln
    cmp byte [si + 12], 0
    jne .no_hit

.chk_invuln:
    cmp byte [invuln_timer], 0
    jne .no_hit
    call damage_mario
.no_hit:
    ret

damage_mario:
    cmp byte [power_state], 1
    jne .kill_small
    mov byte [power_state], 0
    add word [player_y], 16
    mov byte [invuln_timer], FPS_HZ * 2
    ret
.kill_small:
    call start_player_death
    ret
award_stomp_combo:
    push bx
    xor bx, bx
    mov bl, [stomp_combo]
    cmp bl, 10
    jae .extra_life
    shl bx, 1
    mov ax, [stomp_table + bx]
    call add_score_ax
    inc byte [stomp_combo]
    pop bx
    ret
.extra_life:
    call award_extra_life
    pop bx
    ret