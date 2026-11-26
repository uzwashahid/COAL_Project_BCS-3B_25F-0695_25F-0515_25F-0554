; Usman - Module 10: Collision checks
; Extracted procedures (dependent on project shared definitions/data).

; =========================================================================
; COLLISION AND HIT-RESPONSE PROCEDURES
; Extracted unchanged from main.asm and player.asm.
; =========================================================================
; TEAM OWNERSHIP (Project Guide): Usman - Module 10 (collision checks); Hajra - Module 12 (block/item hit interactions).

%ifndef COLLISION_ASM
%define COLLISION_ASM
get_tile_at_pixel:
    cmp ax, 0
    jl .empty
    cmp ax, WORLD_W
    jge .empty
    cmp dx, 0
    jl .empty
    cmp dx, MAP_ROWS * TILE_SIZE
    jge .empty

    push bx
    push cx
    mov cl, 4
    mov bx, ax
    shr bx, cl
    mov ax, dx
    shr ax, cl
    mov cl, MAP_COLS
    mul cl
    add bx, ax
    mov al, [work_level_map + bx]
    pop cx
    pop bx
    ret
.empty:
    xor al, al
    ret

is_tile_solid:
    cmp al, T_EMPTY
    je .not_solid
    cmp al, T_COIN
    je .not_solid
    cmp al, T_POLE
    je .not_solid
    cmp al, T_POLE_TOP
    je .not_solid
    stc
    ret
.not_solid:
    clc
    ret
get_mario_height:
    mov bx, 16
    cmp byte [power_state], 1
    jne .done
    mov bx, 32
.done:
    ret
resolve_player_x_collision:
    cmp word [player_vx], 0
    jne .start
    ret
.start:
    call get_mario_height
    mov si, [player_y]
    add si, 2
    mov di, [player_y]
    add di, bx
    sub di, 3
    mov bp, [player_y]
    shr bx, 1
    add bp, bx

    cmp word [player_vx], 0
    jl .check_left

    mov cx, [player_x]
    add cx, 13

    mov ax, cx
    mov dx, si
    call get_tile_at_pixel
    call is_tile_solid
    jc .hit_right

    mov ax, cx
    mov dx, bp
    call get_tile_at_pixel
    call is_tile_solid
    jc .hit_right

    mov ax, cx
    mov dx, di
    call get_tile_at_pixel
    call is_tile_solid
    jnc .done

.hit_right:
    and cx, 0FFF0h
    sub cx, 14
    mov [player_x], cx
    mov byte [player_x_frac], 0
    mov word [player_vx], 0
    ret

.check_left:
    mov cx, [player_x]
    add cx, 2

    mov ax, cx
    mov dx, si
    call get_tile_at_pixel
    call is_tile_solid
    jc .hit_left

    mov ax, cx
    mov dx, bp
    call get_tile_at_pixel
    call is_tile_solid
    jc .hit_left

    mov ax, cx
    mov dx, di
    call get_tile_at_pixel
    call is_tile_solid
    jnc .done

.hit_left:
    and cx, 0FFF0h
    add cx, 14
    mov [player_x], cx
    mov byte [player_x_frac], 0
    mov word [player_vx], 0
.done:
    ret

resolve_player_y_collision:
    mov bl, [grounded]
    mov [was_grounded], bl
    mov byte [grounded], 0

    call get_mario_height
    mov si, [player_x]
    add si, 3
    mov di, [player_x]
    add di, 12

    cmp word [player_vy], 0
    jl .check_ceiling

    mov cx, [player_y]
    add cx, bx

    mov ax, si
    mov dx, cx
    call get_tile_at_pixel
    call is_tile_solid
    jc .landed

    mov ax, di
    mov dx, cx
    call get_tile_at_pixel
    call is_tile_solid
    jnc .done

.landed:
    and cx, 0FFF0h
    sub cx, bx
    mov [player_y], cx
    mov byte [player_y_frac], 0
    mov word [player_vy], 0
    mov byte [grounded], 1
    mov byte [stomp_combo], 0
    cmp byte [was_grounded], 0
    jne .done
    mov byte [land_timer], 3
.done:
    ret

.check_ceiling:
    mov cx, [player_y]
    mov bp, [player_x]
    add bp, 8

    mov ax, bp
    mov dx, cx
    call get_tile_at_pixel
    call is_tile_solid
    jc .bonk_center

    mov ax, si
    mov dx, cx
    call get_tile_at_pixel
    call is_tile_solid
    jc .bonk_left

    mov ax, di
    mov dx, cx
    call get_tile_at_pixel
    call is_tile_solid
    jnc .done
    mov bp, di
    jmp .bonk_center

.bonk_left:
    mov bp, si

.bonk_center:
    mov ax, cx
    and ax, 0FFF0h
    add ax, 16
    mov [player_y], ax
    mov byte [player_y_frac], 0
    mov word [player_vy], 0
    mov byte [jump_hold_cnt], 0

    mov cl, 4
    shr bp, cl
    shr ax, cl
    dec ax
    call trigger_block_hit
    ret

