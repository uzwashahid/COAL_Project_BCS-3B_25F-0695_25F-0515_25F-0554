install_keyboard:
    push ds
    push es
    mov ax, 3509h
    int 21h
    mov [old_int09_off], bx
    mov [old_int09_seg], es

    cli
    push cs
    pop ds
    mov dx, key_irq
    mov ax, 2509h
    int 21h
    mov byte [kb_installed], 1
    sti
    pop es
    pop ds
    ret

restore_keyboard:
    cmp byte [kb_installed], 0
    je .done
    push ds
    cli
    mov ax, [old_int09_seg]
    mov ds, ax
    mov dx, [old_int09_off]
    mov ax, 2509h
    int 21h
    sti
    pop ds
    mov byte [kb_installed], 0
.done:
    ret

key_irq:
    push ax
    in al, 60h
    cmp al, 0E0h
    jne .k_not_e0
    jmp .eoi
.k_not_e0:

    mov ah, al
    and al, 7Fh

    cmp al, 4Bh                 
    jne .chk_right
    test ah, 80h
    jnz .left_rel
    mov byte [cs:key_left], 1
    jmp .eoi
.left_rel:
    mov byte [cs:key_left], 0
    jmp .eoi

.chk_right:
    cmp al, 4Dh                
    jne .chk_space
    test ah, 80h
    jnz .right_rel
    mov byte [cs:key_right], 1
    jmp .eoi
.right_rel:
    mov byte [cs:key_right], 0
    jmp .eoi

.chk_space:
    cmp al, 39h                
    jne .chk_shift
    test ah, 80h
    jnz .space_rel
    cmp byte [cs:key_space], 1
    jne .k_space_new
    jmp .eoi
.k_space_new:
    mov byte [cs:key_space], 1
    mov byte [cs:edge_space], 1
    jmp .eoi
.space_rel:
    mov byte [cs:key_space], 0
    jmp .eoi

.chk_shift:
    cmp al, 2Ah                 
    jne .chk_up
    test ah, 80h
    jnz .shift_rel
    mov byte [cs:key_shift], 1
    jmp .eoi
.shift_rel:
    mov byte [cs:key_shift], 0
    jmp .eoi

.chk_up:
    cmp al, 48h                
    jne .chk_down
    test ah, 80h
    jnz .up_rel
    cmp byte [cs:key_up], 1
    jne .k_up_new
    jmp .eoi
.k_up_new:
    mov byte [cs:key_up], 1
    mov byte [cs:edge_up], 1
    jmp .eoi
.up_rel:
    mov byte [cs:key_up], 0
    jmp .eoi

.chk_down:
    cmp al, 50h                
    jne .chk_p
    test ah, 80h
    jnz .down_rel
    cmp byte [cs:key_down], 1
    jne .k_down_new
    jmp .eoi
.k_down_new:
    mov byte [cs:key_down], 1
    mov byte [cs:edge_down], 1
    jmp .eoi
.down_rel:
    mov byte [cs:key_down], 0
    jmp .eoi

.chk_p:
    cmp al, 19h               
    jne .chk_enter
    test ah, 80h
    jnz .p_rel
    cmp byte [cs:key_p], 1
    je .eoi
    mov byte [cs:key_p], 1
    mov byte [cs:edge_p], 1
    jmp .eoi
.p_rel:
    mov byte [cs:key_p], 0
    jmp .eoi

.chk_enter:
    cmp al, 1Ch                
    jne .chk_esc
    test ah, 80h
    jnz .enter_rel
    cmp byte [cs:key_enter], 1
    je .eoi
    mov byte [cs:key_enter], 1
    mov byte [cs:edge_enter], 1
    jmp .eoi
.enter_rel:
    mov byte [cs:key_enter], 0
    jmp .eoi

.chk_esc:
    cmp al, 01h                
    jne .eoi
    test ah, 80h
    jnz .esc_rel
    cmp byte [cs:key_esc], 1
    je .eoi
    mov byte [cs:key_esc], 1
    mov byte [cs:edge_esc], 1
    jmp .eoi
.esc_rel:
    mov byte [cs:key_esc], 0

.eoi:
    mov al, 20h
    out 20h, al
    pop ax
    iret

clear_edge_keys:
    mov byte [edge_space], 0
    mov byte [edge_up], 0
    mov byte [edge_down], 0
    mov byte [edge_p], 0
    mov byte [edge_enter], 0
    mov byte [edge_esc], 0
    ret
