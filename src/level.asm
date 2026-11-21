; =========================================================================
; LEVEL INITIALIZATION, MAP, OBJECT AND COMPLETION LOGIC
; Extracted unchanged from main.asm and collision.asm.
; =========================================================================
; TEAM OWNERSHIP (Project Guide): Uzwa - Module 3 (level/map setup) and Module 14 (game-state transitions);
; Hajra - Module 12 (blocks/items and pickups).

init_new_game:
    mov word [score_lo], 0
    mov word [score_hi], 0
    mov byte [coins], 0
    mov byte [lives], 3
    mov byte [power_state], 0
    mov word [flag_bonus], 0
    mov word [time_bonus], 0
    call reset_level_for_life
    ret

reset_level_for_life:
    push ds
    pop es
    mov si, orig_level_map
    mov di, work_level_map
    mov cx, (MAP_COLS * MAP_ROWS) / 2
    rep movsw

    mov word [player_x], MARIO_START_X
    mov byte [player_x_frac], 0
    mov word [player_y], MARIO_START_Y
    mov byte [player_y_frac], 0
    mov word [player_vx], 0
    mov word [player_vy], 0
    mov byte [grounded], 0
    mov byte [facing_dir], 1
    mov byte [power_state], 0
    mov byte [jump_hold_cnt], 0
    mov byte [invuln_timer], 0
    mov byte [stomp_combo], 0
    mov byte [mario_anim], 0
    mov byte [anim_tick], 0
    mov byte [land_timer], 0

    mov word [camera_x], 0
    mov word [game_seconds], 300
    mov byte [sec_tick_cnt], 0
    mov word [flag_y], 52
    mov byte [mush_active], 0
    mov byte [popup_coin_timer], 0

    mov di, particles
    xor ax, ax
    mov cx, (MAX_PARTICLES * PARTICLE_SZ) / 2
    rep stosw

    mov si, orig_enemies
    mov di, enemies
    mov cx, (MAX_ENEMIES * ENEMY_STRUCT_SZ) / 2
    rep movsw

    call clear_edge_keys
    ret

; =========================================================================
; STATE UPDATES: TITLE, PAUSED, DYING, LIFELOST, FLAGSLIDE, WIN, GAMEOVER
; =========================================================================

update_flagslide_state:
    cmp byte [flag_phase], 0
    jne .phase_walk

    mov bx, 128
    cmp byte [power_state], 1
    jne .chk_mario_slide
    mov bx, 112

.chk_mario_slide:
    xor al, al
    cmp [player_y], bx
    jge .mario_at_base
    add word [player_y], 3
    cmp [player_y], bx
    jl .chk_flag_slide
    mov [player_y], bx
.mario_at_base:
    or al, 1

.chk_flag_slide:
    cmp word [flag_y], 128
    jge .flag_at_base
    add word [flag_y], 3
    cmp word [flag_y], 128
    jl .chk_both
    mov word [flag_y], 128
.flag_at_base:
    or al, 2

.chk_both:
    cmp al, 3
    jne .done
    mov byte [flag_phase], 1
    mov byte [facing_dir], 1
    mov byte [grounded], 1
    ret

.phase_walk:
    cmp byte [flag_phase], 1
    jne .phase_tally

    mov bx, 144
    cmp byte [power_state], 1
    jne .set_walk_y
    mov bx, 128
.set_walk_y:
    mov [player_y], bx

    cmp word [player_x], 928
    jge .at_castle
    add word [player_x], 2
    inc byte [anim_tick]
    test byte [anim_tick], 3
    jnz .done
    xor byte [mario_anim], 1
    ret
.at_castle:
    mov byte [flag_phase], 2
    ret

.phase_tally:
    cmp word [game_seconds], 0
    je .finish_level

    mov cx, 4
.tally_loop:
    cmp word [game_seconds], 0
    je .finish_level
    dec word [game_seconds]
    mov ax, 50
    call add_score_ax
    add word [time_bonus], 50
    loop .tally_loop
    ret

.finish_level:
    mov byte [game_state], ST_WIN
    call clear_edge_keys
.done:
    ret

update_win_state:
    cmp byte [edge_enter], 1
    je .to_menu
    cmp byte [edge_esc], 1
    je .to_menu
    ret
.to_menu:
    mov byte [edge_enter], 0
    mov byte [edge_esc], 0
    mov byte [game_state], ST_TITLE
    mov byte [menu_cursor], 0
    ret

update_level_timer:
    inc byte [sec_tick_cnt]
    cmp byte [sec_tick_cnt], FPS_HZ
    jb .done
    mov byte [sec_tick_cnt], 0
    cmp word [game_seconds], 0
    je .time_up
    dec word [game_seconds]
    cmp word [game_seconds], 0
    jne .done
.time_up:
    call start_player_death
.done:
    ret

update_mushroom:
    cmp byte [mush_active], 0
    jne .active
    ret
.active:
    cmp byte [mush_rise], 0
    je .move_mush
    dec byte [mush_rise]
    dec word [mush_y]
    jmp near .check_mario_pickup

.move_mush:
    mov ax, [mush_vx]
    add [mush_x_frac], al
    mov al, ah
    cbw
    adc [mush_x], ax

    cmp word [mush_x], 2
    jg .chk_mush_right
    mov word [mush_x], 2
    mov word [mush_vx], MUSH_SPEED
    jmp .mush_grav
.chk_mush_right:
    cmp word [mush_x], WORLD_W - 18
    jl .mush_wall
    mov word [mush_x], WORLD_W - 18
    mov word [mush_vx], -MUSH_SPEED
    jmp .mush_grav

.mush_wall:
    mov ax, [mush_x]
    add ax, 14
    cmp word [mush_vx], 0
    jg .test_mwall
    mov ax, [mush_x]
    add ax, 1
.test_mwall:
    mov dx, [mush_y]
    add dx, 8
    call get_tile_at_pixel
    call is_tile_solid
    jnc .mush_grav
    neg word [mush_vx]

.mush_grav:
    add word [mush_vy], GRAV_NORMAL
    cmp word [mush_vy], MAX_VY_FALL
    jle .mush_y_step
    mov word [mush_vy], MAX_VY_FALL
.mush_y_step:
    mov ax, [mush_vy]
    add [mush_y_frac], al
    mov al, ah
    cbw
    adc [mush_y], ax

    mov dx, [mush_y]
    add dx, 16
    mov ax, [mush_x]
    add ax, 4
    call get_tile_at_pixel
    call is_tile_solid
    jc .mush_land
    mov ax, [mush_x]
    add ax, 11
    call get_tile_at_pixel
    call is_tile_solid
    jnc .mush_pit
.mush_land:
    mov ax, [mush_y]
    add ax, 16
    and ax, 0FFF0h
    sub ax, 16
    mov [mush_y], ax
    mov byte [mush_y_frac], 0
    mov word [mush_vy], 0

.mush_pit:
    cmp word [mush_y], PIT_DEATH_Y
    jl .check_mario_pickup
    mov byte [mush_active], 0
    ret

.check_mario_pickup:
    mov ax, [player_x]
    add ax, 13
    cmp ax, [mush_x]
    jl .done
    mov ax, [mush_x]
    add ax, 14
    mov bx, [player_x]
    add bx, 2
    cmp ax, bx
    jl .done

    call get_mario_height
    mov ax, [player_y]
    add ax, bx
    cmp ax, [mush_y]
    jl .done
    mov ax, [mush_y]
    add ax, 16
    cmp ax, [player_y]
    jl .done

    mov byte [mush_active], 0
    mov ax, 1000
    call add_score_ax
    cmp byte [power_state], 0
    jne .done
    mov byte [power_state], 1
    sub word [player_y], 16
.done:
    ret

award_coin:
    inc byte [coins]
    cmp byte [coins], 100
    jb .done
    sub byte [coins], 100
    call award_extra_life
.done:
    ret

; NOTE: trigger_block_hit lives in collis.asm.

; =========================================================================
; MUSHROOM POWER-UP & VISUAL EFFECTS
; =========================================================================

orig_level_map:
times 60 db T_EMPTY
times 60 db T_EMPTY
times 60 db T_EMPTY
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db T_COIN,T_COIN,T_COIN,T_COIN,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,T_POLE_TOP,0,0,0,0

db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db T_BRICK,T_BRICK,T_BRICK,0,0,0,0,0,0,0,0,0,0,0,0,0,T_COIN,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,T_POLE,0,0,0,0

db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,T_COIN,T_COIN,T_COIN,T_COIN
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,T_COIN,T_COIN,T_COIN,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,T_POLE,0,0,0,0

db 0,0,0,0,0,0,T_QBLOCK_COIN,T_BRICK,T_BRICK,T_BRICK
db 0,0,0,0,T_QBLOCK_MUSH,0,0,0,0,0
db 0,0,0,0,0,0,0,0,T_QBLOCK_COIN,T_BRICK
db T_BRICK,T_BRICK,T_QBLOCK_MUSH,0,0,0,0,0,0,0
db 0,0,0,0,T_BRICK,T_BRICK,T_BRICK,T_QBLOCK_COIN,0,0
db 0,0,T_STONE,0,0,T_POLE,0,0,0,0

db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,T_PIPE_TL,T_PIPE_TR,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,T_STONE,T_STONE,0,0,T_POLE,0,0,0,0

db 0,0,0,0,0,0,0,0,0,0,T_PIPE_TL,T_PIPE_TR,0,0,0,0,0,0,0,0
db 0,0,0,0,T_PIPE_BL,T_PIPE_BR,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,T_PIPE_TL,T_PIPE_TR,0,0,0,T_COIN,T_COIN,T_COIN,0,T_STONE,T_STONE,T_STONE,0,0,T_POLE,0,0,0,0

db 0,0,0,0,0,0,0,0,0,0,T_PIPE_BL,T_PIPE_BR,0,0,0,0,0,0,0,0
db 0,0,0,0,T_PIPE_BL,T_PIPE_BR,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,T_PIPE_BL,T_PIPE_BR,0,0,0,0,0,0,T_STONE,T_STONE,T_STONE,T_STONE,0,0,T_STONE,0,0,0,0

db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,2
db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,2,2
db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

; =========================================================================
; INITIAL ENEMY PLACEMENTS (5 GOOMBAS + 2 KOOPAS = 7 ACTIVE ENEMIES)
; =========================================================================
orig_enemies:
    db EN_GOOMBA,ES_WALK
    dw 208
    db 0
    dw 144
    db 0
    dw -GOOMBA_SPEED,0
    db 0,0,-1,0

    db EN_GOOMBA,ES_WALK
    dw 336
    db 0
    dw 144
    db 0
    dw -GOOMBA_SPEED,0
    db 0,2,-1,0

    db EN_KOOPA,ES_WALK
    dw 432
    db 0
    dw 144
    db 0
    dw -KOOPA_SPEED,0
    db 0,0,-1,0

    db EN_GOOMBA,ES_WALK
    dw 512
    db 0
    dw 144
    db 0
    dw -GOOMBA_SPEED,0
    db 0,4,-1,0

    db EN_GOOMBA,ES_WALK
    dw 624
    db 0
    dw 144
    db 0
    dw -GOOMBA_SPEED,0
    db 0,1,-1,0

    db EN_KOOPA,ES_WALK
    dw 704
    db 0
    dw 144
    db 0
    dw -KOOPA_SPEED,0
    db 0,3,-1,0

    db EN_GOOMBA,ES_WALK
    dw 752
    db 0
    dw 144
    db 0
    dw -GOOMBA_SPEED,0
    db 0,0,-1,0

    times 16 db 0

; =========================================================================
; 256-COLOR PALETTE (INDICES 0..36)
; =========================================================================
