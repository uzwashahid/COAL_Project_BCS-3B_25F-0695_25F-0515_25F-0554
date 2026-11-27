
draw_all_enemies:
    mov di, enemies
    mov cx, MAX_ENEMIES
.loop:
    cmp byte [di + 0], EN_NONE
    jne .active
    jmp near .next
.active:
    mov ax, [di + 2]
    sub ax, [camera_x]
    cmp ax, -16
    jge .chk_r
    jmp near .next
.chk_r:
    cmp ax, 320
    jl .pos_ok
    jmp near .next
.pos_ok:
    mov [draw_x], ax
    mov ax, [di + 5]
    mov [draw_y], ax

    mov byte [flip_x], 0
    cmp byte [di + 14], 0
    jle .dir_set
    mov byte [flip_x], 1
.dir_set:
    cmp byte [di + 0], EN_GOOMBA
    jne .koopa

    cmp byte [di + 1], ES_FLAT
    je .g_flat
    test byte [di + 13], 04h
    jnz .g_walk2
    mov si, spr_goomba_0
    jmp .draw_e
.g_walk2:
    mov si, spr_goomba_1
    jmp .draw_e
.g_flat:
    mov si, spr_goomba_flat
    mov byte [flip_x], 0
    jmp .draw_e

.koopa:
    mov al, [di + 1]
    cmp al, ES_SHELL_IDLE
    je .k_shell
    cmp al, ES_SHELL_MOVE
    je .k_shell_spin
    test byte [di + 13], 04h
    jnz .k_walk2
    mov si, spr_koopa_0
    jmp .draw_e
.k_walk2:
    mov si, spr_koopa_1
    jmp .draw_e
.k_shell_spin:
    test byte [di + 13], 02h
    jnz .k_shell_alt
.k_shell:
    mov si, spr_koopa_shell
    mov byte [flip_x], 0
    jmp .draw_e
.k_shell_alt:
    mov si, spr_koopa_shell2
    mov byte [flip_x], 0

.draw_e:
    push cx
    push di
    mov bx, 16
    call blit_sprite_clipped
    pop di
    pop cx

.next:
    add di, ENEMY_STRUCT_SZ
    dec cx
    jz .done
    jmp near .loop
.done:
    ret

;----------------------------------------
draw_mario_sprite:
    cmp byte [invuln_timer], 0
    je .visible
    test byte [invuln_timer], 02h
    jz .visible
    ret

.visible:
    mov ax, [player_x]
    sub ax, [camera_x]
    mov [draw_x], ax
    mov ax, [player_y]
    mov [draw_y], ax

    mov byte [flip_x], 0
    cmp byte [facing_dir], 0
    jge .dir_ok
    mov byte [flip_x], 1
.dir_ok:
    cmp byte [game_state], ST_DYING
    je .small_die

    cmp byte [power_state], 1
    je .super_mario

    mov al, [mario_anim]
    cmp al, 0
    je .sm_stand
    cmp al, 1
    je .sm_walk1
    cmp al, 2
    je .sm_walk2
    cmp al, 3
    je .sm_walk1
    mov si, spr_mario_s_jump
    jmp .blit_sm
.sm_stand:
    mov si, spr_mario_s_stand
    jmp .blit_sm
.sm_walk1:
    mov si, spr_mario_s_walk1
    jmp .blit_sm
.sm_walk2:
    mov si, spr_mario_s_walk2
    jmp .blit_sm
.small_die:
    mov si, spr_mario_s_die
    mov byte [flip_x], 0
.blit_sm:
    mov bx, 16
    call blit_sprite_clipped
    ret
.super_mario:
    mov al, [mario_anim]
    cmp al, 0
    je .bg_stand
    cmp al, 1
    je .bg_walk1
    cmp al, 2
    je .bg_walk2
    cmp al, 3
    je .bg_walk1
    mov si, spr_mario_b_jump
    jmp .blit_bg
.bg_stand:
    mov si, spr_mario_b_stand
    jmp .blit_bg
.bg_walk1:
    mov si, spr_mario_b_walk1
    jmp .blit_bg
.bg_walk2:
    mov si, spr_mario_b_walk2
.blit_bg:
    mov bx, 32
    call blit_sprite_clipped
    ret
;----------------------------------------------------------
blit_sprite_clipped:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, [buffer_seg]
    mov es, ax

    mov [spr_h], bx
    mov [spr_ptr], si
    mov word [spr_row_idx], 0

.row_loop:
    mov ax, [spr_row_idx]
    cmp ax, [spr_h]
    jae .done

    mov dx, [draw_y]
    add dx, ax
    cmp dx, HUD_H
    jl .next_row
    cmp dx, PLAY_BOTTOM_Y
    jge .done

    push ax
    mov ax, dx
    mov di, 320
    mul di
    mov di, ax
    pop ax

    mov bx, ax
    shl bx, 1
    shl bx, 1
    shl bx, 1
    shl bx, 1
    add bx, [spr_ptr]

    xor cx, cx
.col_loop:
    cmp cx, 16
    jae .next_row

    mov ax, [draw_x]
    add ax, cx
    cmp ax, 0
    jl .next_col
    cmp ax, SCREEN_W
    jge .next_row

    push di
    add di, ax

    mov si, cx
    cmp byte [flip_x], 1
    jne .read_px
    mov si, 15
    sub si, cx
.read_px:
    mov al, [bx + si]
    or al, al
    jz .skip_px
    mov [es:di], al
.skip_px:
    pop di
.next_col:
    inc cx
    jmp .col_loop

.next_row:
    inc word [spr_row_idx]
    jmp .row_loop

.done:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; =========================================================================
; FIXED TOP 16-PIXEL PROFESSIONAL HUD (Y = 0..15)
; =========================================================================

.draw_time_normal:
    mov bl, 8
.draw_time_val:
    mov dh, 1
    mov dl, 23
    mov cx, 3
    call draw_uint_padded
.skip_time_blink:

    mov dh, 1
    mov dl, 29
    mov bl, 8
    mov si, hud_val_x
    call print_at_color

    mov dh, 1
    mov dl, 30
    mov bl, 12
    xor ax, ax
    mov al, [lives]
    mov cx, 2
    call draw_uint_padded

    mov word [draw_x], 282
    mov word [draw_y], 4
    mov si, spr_heart_full
    cmp byte [game_state], ST_DYING
    jne .draw_h1
    mov si, spr_heart_empty
.draw_h1:
    call blit_8x8_hud

    mov word [draw_x], 294
    mov word [draw_y], 4
    mov si, spr_heart_empty
    cmp byte [power_state], 1
    jne .draw_h2
    mov si, spr_heart_full
.draw_h2:
    call blit_8x8_hud
    ret


.rloop:
    mov cx, 8
.cloop:
    lodsb
    or al, al
    jz .skip
    mov [es:di], al
.skip:
    inc di
    loop .cloop
    add di, 312
    dec dx
    jnz .rloop

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop ax
    ret
;----------------------------------------------------
blit_buffer:
    mov dx, 03DAh
.wait_end:
    in al, dx
    test al, 08h
    jnz .wait_end
.wait_start:
    in al, dx
    test al, 08h
    jz .wait_start

    push ds
    push es
    mov ax, [buffer_seg]
    mov ds, ax
    mov ax, 0A000h
    mov es, ax
    xor si, si
    xor di, di
    mov cx, 32000
    rep movsw
    pop es
    pop ds
    ret
;----------------------------------

fill_rect:
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    mov di, [buffer_seg]
    mov es, di

    push ax
    mov ax, bx
    mov di, 320
    push dx
    mul di
    pop dx
    pop di
    add di, ax

    mov al, [fill_col]
    mov bx, 320
    sub bx, cx

.rloop:
    push cx
    rep stosb
    add di, bx
    pop cx
    dec dx
    jnz .rloop

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret


