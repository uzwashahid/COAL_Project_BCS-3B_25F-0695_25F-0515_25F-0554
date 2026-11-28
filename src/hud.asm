draw_hud:
    xor ax, ax
    xor bx, bx
    mov cx, 320
    mov dx, 15
    mov byte [fill_col], 33
    call fill_rect

    xor ax, ax
    mov bx, 15
    mov cx, 320
    mov dx, 1
    mov byte [fill_col], 18
    call fill_rect

    mov dh, 0
    mov dl, 1
    mov bl, 8
    mov si, hud_lbl_mario
    call print_at_color

    mov dl, 9
    mov si, hud_lbl_coins
    call print_at_color

    mov dl, 16
    mov si, hud_lbl_world
    call print_at_color

    mov dl, 23
    mov si, hud_lbl_time
    call print_at_color

    mov dl, 29
    mov si, hud_lbl_lives
    call print_at_color

    mov dh, 1
    mov dl, 1
    mov bl, 36
    call draw_score_6digit

    mov word [draw_x], 9 * 8
    mov word [draw_y], 8
    mov si, spr_hud_coin
    call blit_8x8_hud

    mov dh, 1
    mov dl, 11
    mov bl, 25
    xor ax, ax
    mov al, [coins]
    mov cx, 2
    call draw_uint_padded

    mov dh, 1
    mov dl, 17
    mov bl, 8
    mov si, hud_val_world
    call print_at_color

    mov ax, [game_seconds]
    cmp ax, 100
    jae .draw_time_normal
    test byte [global_frame], 08h
    jnz .skip_time_blink
    mov bl, 9
    jmp .draw_time_val
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

blit_8x8_hud:
    push ax
    push cx
    push dx
    push si
    push di
    push es

    mov ax, [buffer_seg]
    mov es, ax

    mov ax, [draw_y]
    mov di, 320
    mul di
    add ax, [draw_x]
    mov di, ax

    mov dx, 8
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

draw_uint_padded:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov [num_row], dh
    mov [num_col], dl
    mov [num_color], bl

    mov di, num_buf
    add di, cx
    mov byte [di], 0
    dec di

    mov bx, 10
.div_loop:
    xor dx, dx
    div bx
    add dl, '0'
    mov [di], dl
    dec di
    loop .div_loop

    mov dh, [num_row]
    mov dl, [num_col]
    mov bl, [num_color]
    mov si, num_buf
    call print_at_color

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_score_6digit:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov [num_row], dh
    mov [num_col], dl
    mov [num_color], bl

    mov ax, [score_lo]
    mov dx, [score_hi]
    mov di, num_buf + 6
    mov byte [di], 0
    dec di
    mov cx, 6
    mov bx, 10

.div32_loop:
    push cx
    mov cx, ax
    mov ax, dx
    xor dx, dx
    div bx
    xchg ax, cx
    div bx
    add dl, '0'
    mov [di], dl
    dec di
    mov dx, cx
    pop cx
    loop .div32_loop

    mov dh, [num_row]
    mov dl, [num_col]
    mov bl, [num_color]
    mov si, num_buf
    call print_at_color

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

