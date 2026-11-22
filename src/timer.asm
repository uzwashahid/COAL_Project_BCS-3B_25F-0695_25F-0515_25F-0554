; =========================================================================
; timer.asm - PIT timer (24 Hz) install/restore, timer IRQ, frame sync
; Included from main.asm. No code outside procedures, no ORG in this file.
; =========================================================================
; TEAM OWNERSHIP (Project Guide): Hajra - Module 8 (timer interrupt and frame timing).

install_timer:
    push ds
    push es
    mov ax, 3508h
    int 21h
    mov [old_int08_off], bx
    mov [old_int08_seg], es

    cli
    mov al, 36h
    out 43h, al
    mov ax, PIT_DIVISOR
    out 40h, al
    mov al, ah
    out 40h, al

    push cs
    pop ds
    mov dx, timer_irq
    mov ax, 2508h
    int 21h
    mov byte [timer_installed], 1
    sti
    pop es
    pop ds
    ret

restore_timer:
    cmp byte [timer_installed], 0
    je .done
    push ds
    cli
    mov al, 36h
    out 43h, al
    xor al, al
    out 40h, al
    out 40h, al

    mov ax, [old_int08_seg]
    mov ds, ax
    mov dx, [old_int08_off]
    mov ax, 2508h
    int 21h
    sti
    pop ds
    mov byte [timer_installed], 0
.done:
    ret

timer_irq:
    push ax
    inc word [cs:pit_ticks]
    add word [cs:pit_acc], PIT_DIVISOR
    jc .chain_bios
    mov al, 20h
    out 20h, al
    pop ax
    iret
.chain_bios:
    pop ax
    jmp far [cs:old_int08_off]

wait_frame_tick:
    mov ax, [pit_ticks]
.spin:
    hlt
    cmp ax, [pit_ticks]
    je .spin
    inc word [global_frame]
    ret
