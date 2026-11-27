
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


