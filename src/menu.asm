; =========================================================================
; MENU NAVIGATION AND GAME-STATE SCREENS
; Extracted unchanged from main.asm, level.asm and graphics.asm.
; =========================================================================
; TEAM OWNERSHIP (Project Guide): Uzwa - Module 14 (title, pause, win and game-over state/screens).

update_title_state:
    cmp byte [controls_view], 1
    jne .main_menu
    jmp near .in_controls

.main_menu:
    cmp byte [edge_up], 1
    jne .chk_down
    mov byte [edge_up], 0
    cmp byte [menu_cursor], 0
    je .wrap_bottom
    dec byte [menu_cursor]
    jmp .chk_down
.wrap_bottom:
    mov byte [menu_cursor], 2

.chk_down:
    cmp byte [edge_down], 1
    jne .chk_enter
    mov byte [edge_down], 0
    inc byte [menu_cursor]
    cmp byte [menu_cursor], 3
    jb .chk_enter
    mov byte [menu_cursor], 0

.chk_enter:
    cmp byte [edge_enter], 1
    jne .chk_esc
    mov byte [edge_enter], 0
    mov al, [menu_cursor]
    cmp al, 0
    je .start_new
    cmp al, 1
    je .open_controls
    mov byte [quit_flag], 1
    ret
.start_new:
    call init_new_game
    mov byte [game_state], ST_PLAYING
    ret
.open_controls:
    mov byte [controls_view], 1
    ret

.chk_esc:
    cmp byte [edge_esc], 1
    jne .done
    mov byte [edge_esc], 0
    mov byte [quit_flag], 1
.done:
    ret

.in_controls:
    cmp byte [edge_enter], 1
    je .close_controls
    cmp byte [edge_esc], 1
    je .close_controls
    ret
.close_controls:
    mov byte [edge_enter], 0
    mov byte [edge_esc], 0
    mov byte [controls_view], 0
    ret

update_paused_state:
    cmp byte [edge_p], 1
    jne .chk_esc
    mov byte [edge_p], 0
    mov byte [game_state], ST_PLAYING
    ret

.chk_esc:
    cmp byte [edge_esc], 1
    jne .chk_up
    mov byte [edge_esc], 0
    mov byte [game_state], ST_TITLE
    mov byte [menu_cursor], 0
    ret

.chk_up:
    cmp byte [edge_up], 1
    jne .chk_down
    mov byte [edge_up], 0
    cmp byte [pause_cursor], 0
    je .p_wrap_bot
    dec byte [pause_cursor]
    jmp .chk_down
.p_wrap_bot:
    mov byte [pause_cursor], 2

.chk_down:
    cmp byte [edge_down], 1
    jne .chk_enter
    mov byte [edge_down], 0
    inc byte [pause_cursor]
    cmp byte [pause_cursor], 3
    jb .chk_enter
    mov byte [pause_cursor], 0

.chk_enter:
    cmp byte [edge_enter], 1
    jne .done
    mov byte [edge_enter], 0
    mov al, [pause_cursor]
    cmp al, 0
    je .resume
    cmp al, 1
    je .restart
    mov byte [game_state], ST_TITLE
    mov byte [menu_cursor], 0
    ret
.resume:
    mov byte [game_state], ST_PLAYING
    ret
.restart:
    call init_new_game
    mov byte [game_state], ST_PLAYING
.done:
    ret

update_gameover_state:
    cmp byte [edge_enter], 1
    jne .chk_esc
    mov byte [edge_enter], 0
    call init_new_game
    mov byte [game_state], ST_PLAYING
    ret
.chk_esc:
    cmp byte [edge_esc], 1
    jne .done
    mov byte [edge_esc], 0
    mov byte [game_state], ST_TITLE
    mov byte [menu_cursor], 0
.done:
    ret

; NOTE: update_win_state lives in level.asm.

render_title_screen:
    mov ax, [buffer_seg]
    mov es, ax
    xor di, di
    mov ax, 2020h
    mov cx, (160 * 320) / 2
    rep stosw

    mov word [cur_col], 0
.gloop:
    cmp word [cur_col], 20
    jge .after_g
    mov ax, [cur_col]
    mov cl, 4
    shl ax, cl
    mov [draw_x], ax
    mov word [draw_y], 160
    mov si, spr_ground_top
    mov bx, 16
    mov byte [flip_x], 0
    call blit_sprite_clipped
    mov word [draw_y], 176
    mov si, spr_ground_deep
    call blit_sprite_clipped
    inc word [cur_col]
    jmp .gloop

.after_g:
    mov di, 192 * 320
    mov ax, 1F1Fh
    mov cx, (8 * 320) / 2
    rep stosw

    mov word [draw_x], 24
    call draw_scenic_hill
    mov word [draw_x], 40
    mov word [draw_y], 20
    call draw_cloud_cluster
    mov word [draw_x], 220
    mov word [draw_y], 28
    call draw_cloud_cluster

    mov word [draw_x], 48
    mov word [draw_y], 128
    mov si, spr_mario_b_stand
    mov bx, 32
    mov byte [flip_x], 0
    call blit_sprite_clipped

    mov word [draw_x], 244
    mov word [draw_y], 144
    mov si, spr_goomba_0
    mov bx, 16
    call blit_sprite_clipped

    mov word [draw_x], 268
    mov word [draw_y], 144
    mov si, spr_koopa_0
    call blit_sprite_clipped

    cmp byte [controls_view], 1
    jne .draw_main_banner
    jmp near .draw_controls_modal

.draw_main_banner:
    mov ax, 44
    mov bx, 20
    mov cx, 232
    mov dx, 46
    call draw_framed_panel

    mov dh, 3
    mov dl, 10
    mov bl, 9
    mov si, str_title_main
    call print_shadowed

    mov dh, 5
    mov dl, 9
    mov bl, 25
    mov si, str_title_sub
    call print_shadowed

    mov ax, 84
    mov bx, 76
    mov cx, 152
    mov dx, 68
    call draw_framed_panel

    mov dh, 11
    mov dl, 14
    mov bl, 8
    mov si, str_menu_start
    call print_at_color

    mov dh, 13
    mov dl, 14
    mov bl, 8
    mov si, str_menu_ctrl
    call print_at_color

    mov dh, 15
    mov dl, 14
    mov bl, 8
    mov si, str_menu_exit
    call print_at_color

    xor ax, ax
    mov al, [menu_cursor]
    shl ax, 1
    add al, 11
    mov dh, al
    mov dl, 12
    mov bl, 25
    mov si, str_cursor_arrow
    call print_at_color

    call blit_buffer
    ret

.draw_controls_modal:
    mov ax, 36
    mov bx, 24
    mov cx, 248
    mov dx, 126
    call draw_framed_panel

    mov dh, 4
    mov dl, 14
    mov bl, 25
    mov si, str_ctrl_hdr
    call print_at_color

    mov dh, 6
    mov dl, 7
    mov bl, 8
    mov si, str_ctrl_1
    call print_at_color

    mov dh, 8
    mov dl, 7
    mov si, str_ctrl_2
    call print_at_color

    mov dh, 10
    mov dl, 7
    mov si, str_ctrl_3
    call print_at_color

    mov dh, 12
    mov dl, 7
    mov si, str_ctrl_4
    call print_at_color

    mov dh, 14
    mov dl, 7
    mov si, str_ctrl_5
    call print_at_color

    mov dh, 17
    mov dl, 10
    mov bl, 12
    mov si, str_ctrl_back
    call print_at_color

    call blit_buffer
    ret

render_paused_screen:
    call render_world_scene
    call draw_hud

    mov ax, 84
    mov bx, 56
    mov cx, 152
    mov dx, 84
    call draw_framed_panel

    mov dh, 8
    mov dl, 16
    mov bl, 25
    mov si, str_paused_hdr
    call print_at_color

    mov dh, 11
    mov dl, 14
    mov bl, 8
    mov si, str_pause_res
    call print_at_color

    mov dh, 13
    mov dl, 14
    mov si, str_pause_rst
    call print_at_color

    mov dh, 15
    mov dl, 14
    mov si, str_pause_quit
    call print_at_color

    xor ax, ax
    mov al, [pause_cursor]
    shl ax, 1
    add al, 11
    mov dh, al
    mov dl, 12
    mov bl, 25
    mov si, str_cursor_arrow
    call print_at_color

    call blit_buffer
    ret

render_win_screen:
    call render_world_scene
    call draw_hud

    mov ax, 52
    mov bx, 40
    mov cx, 216
    mov dx, 112
    call draw_framed_panel

    mov dh, 6
    mov dl, 13
    mov bl, 12
    mov si, str_win_hdr
    call print_at_color

    mov dh, 9
    mov dl, 9
    mov bl, 8
    mov si, str_win_flag
    call print_at_color
    mov dh, 9
    mov dl, 24
    mov bl, 25
    mov ax, [flag_bonus]
    mov cx, 4
    call draw_uint_padded

    mov dh, 11
    mov dl, 9
    mov bl, 8
    mov si, str_win_time
    call print_at_color
    mov dh, 11
    mov dl, 23
    mov bl, 25
    mov ax, [time_bonus]
    mov cx, 5
    call draw_uint_padded

    mov dh, 13
    mov dl, 9
    mov bl, 8
    mov si, str_final_score
    call print_at_color
    mov dh, 13
    mov dl, 22
    mov bl, 36
    call draw_score_6digit

    mov dh, 16
    mov dl, 10
    mov bl, 12
    mov si, str_press_enter
    call print_at_color

    call blit_buffer
    ret

render_gameover_screen:
    mov ax, [buffer_seg]
    mov es, ax
    xor di, di
    mov ax, 1F1Fh
    mov cx, 32000
    rep stosw

    call draw_hud

    mov ax, 64
    mov bx, 52
    mov cx, 192
    mov dx, 92
    call draw_framed_panel

    mov dh, 8
    mov dl, 15
    mov bl, 9
    mov si, str_gameover_hdr
    call print_at_color

    mov dh, 11
    mov dl, 10
    mov bl, 8
    mov si, str_final_score
    call print_at_color
    mov dh, 11
    mov dl, 23
    mov bl, 36
    call draw_score_6digit

    mov dh, 14
    mov dl, 10
    mov bl, 12
    mov si, str_retry_prompt
    call print_at_color

    mov dh, 16
    mov dl, 12
    mov bl, 18
    mov si, str_esc_menu
    call print_at_color

    call blit_buffer
    ret
