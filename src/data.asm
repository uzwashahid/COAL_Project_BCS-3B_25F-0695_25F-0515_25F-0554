; =========================================================================
; data.asm - constants, shared data tables and runtime variables
; Included from main.asm. No code and no ORG in this file.
; =========================================================================
; TEAM OWNERSHIP (Project Guide): Shared constants/data supporting the assigned modules;
; Uzwa - Module 3 (level map/tile data); other runtime data is shared by the engine modules.

; -------------------------------------------------------------------------
; SYSTEM & DISPLAY CONSTANTS
; -------------------------------------------------------------------------
SCREEN_W        equ 320
SCREEN_H        equ 200
HUD_H           equ 16
PLAY_BOTTOM_Y   equ 192

MAP_COLS        equ 60
MAP_ROWS        equ 12
TILE_SIZE       equ 16
WORLD_W         equ MAP_COLS * TILE_SIZE      ; 960 pixels
MAX_CAMERA_X    equ WORLD_W - SCREEN_W        ; 640 pixels
MARIO_START_X   equ 32
MARIO_START_Y   equ 144
FLAGPOLE_COL    equ 55
FLAGPOLE_X      equ FLAGPOLE_COL * TILE_SIZE  ; 880 pixels

PIT_DEATH_Y     equ 184
MAX_ENEMIES     equ 8
ENEMY_STRUCT_SZ equ 16
MAX_PARTICLES   equ 8
PARTICLE_SZ     equ 8

; PIT Channel 0 divisor for 24.00 Hz (1193182 / 49716 = 24.00 Hz)
PIT_DIVISOR     equ 49716
FPS_HZ          equ 24

; -------------------------------------------------------------------------
; TILE ID CONSTANTS
; -------------------------------------------------------------------------
T_EMPTY         equ 0
T_GROUND_TOP    equ 1
T_GROUND_DEEP   equ 2
T_BRICK         equ 3
T_QBLOCK_COIN   equ 4
T_QBLOCK_MUSH   equ 5
T_USED          equ 6
T_PIPE_TL       equ 7
T_PIPE_TR       equ 8
T_PIPE_BL       equ 9
T_PIPE_BR       equ 10
T_STONE         equ 11
T_POLE_TOP      equ 12
T_POLE          equ 13
T_COIN          equ 14

; -------------------------------------------------------------------------
; GAME STATES
; -------------------------------------------------------------------------
ST_TITLE        equ 0
ST_PLAYING      equ 1
ST_PAUSED       equ 2
ST_DYING        equ 3
ST_LIFELOST     equ 4
ST_FLAGSLIDE    equ 5
ST_WIN          equ 6
ST_GAMEOVER     equ 7

; -------------------------------------------------------------------------
; ENEMY TYPES & STATES
; -------------------------------------------------------------------------
EN_NONE         equ 0
EN_GOOMBA       equ 1
EN_KOOPA        equ 2

ES_DEAD         equ 0
ES_WALK         equ 1
ES_FLAT         equ 2
ES_SHELL_IDLE   equ 3
ES_SHELL_MOVE   equ 4

; -------------------------------------------------------------------------
; 8.8 FIXED-POINT PHYSICS CONSTANTS (TUNED FOR 24 FPS)
; -------------------------------------------------------------------------
ACCEL_WALK      equ 0028h       ; 0.156 px/frame^2
ACCEL_RUN       equ 003Ch       ; 0.234 px/frame^2
ACCEL_AIR       equ 001Eh       ; 0.117 px/frame^2
FRICTION_GND    equ 0024h       ; 0.141 px/frame^2
SKID_DECEL      equ 0048h       ; 0.281 px/frame^2
DRAG_AIR        equ 0006h       ; 0.023 px/frame^2

MAX_VX_WALK     equ 01C0h       ; 1.75 px/frame
MAX_VX_RUN      equ 02C0h       ; 2.75 px/frame

JUMP_VEL_WALK   equ -0480h      ; -4.50 px/frame
JUMP_VEL_RUN    equ -04C0h      ; -4.75 px/frame
JUMP_HOLD_MAX   equ 10          ; frames of variable jump boost
GRAV_HOLD       equ 0024h       ; reduced gravity while holding jump
GRAV_NORMAL     equ 0054h       ; normal gravity
MAX_VY_FALL     equ 0580h       ; +5.50 px/frame terminal fall

GOOMBA_SPEED    equ 0080h       ; 0.50 px/frame
KOOPA_SPEED     equ 00A0h       ; 0.625 px/frame
SHELL_SPEED     equ 0300h       ; 3.00 px/frame
MUSH_SPEED      equ 0100h       ; 1.00 px/frame

; -------------------------------------------------------------------------
; PALETTE SIZE
; -------------------------------------------------------------------------
PAL_TOTAL_COLORS equ 37

; =========================================================================
; STRINGS & LOOKUP TABLES
; =========================================================================
str_alloc_err       db 'DOS memory allocation failed.$'

hud_lbl_mario       db 'MARIO',0
hud_lbl_coins       db 'COINS',0
hud_lbl_world       db 'WORLD',0
hud_lbl_time        db 'TIME',0
hud_lbl_lives       db 'LIVES',0
hud_val_world       db '1-1',0
hud_val_x           db 'x',0

str_title_main      db 'SUPER MARIO BROS 8086',0
str_title_sub       db 'VGA MODE 13h EDITION',0
str_menu_start      db 'START GAME',0
str_menu_ctrl       db 'CONTROLS',0
str_menu_exit       db 'EXIT TO DOS',0
str_cursor_arrow    db '>',0

str_ctrl_hdr        db 'GAME CONTROLS',0
str_ctrl_1          db 'LEFT / RIGHT : MOVE MARIO',0
str_ctrl_2          db 'LEFT SHIFT   : RUN FASTER',0
str_ctrl_3          db 'SPACE        : JUMP (HOLD HIGH)',0
str_ctrl_4          db 'P            : PAUSE GAME',0
str_ctrl_5          db 'ESC          : BACK / EXIT',0
str_ctrl_back       db 'PRESS ENTER TO RETURN',0

str_paused_hdr      db 'GAME PAUSED',0
str_pause_res       db 'RESUME GAME',0
str_pause_rst       db 'RESTART LEVEL',0
str_pause_quit      db 'TITLE MENU',0

str_world_11        db 'WORLD 1-1',0
str_win_hdr         db 'COURSE CLEAR!',0
str_win_flag        db 'FLAG BONUS  :',0
str_win_time        db 'TIME BONUS  :',0
str_final_score     db 'FINAL SCORE :',0
str_press_enter     db 'PRESS ENTER FOR MENU',0

str_gameover_hdr    db 'GAME OVER',0
str_retry_prompt    db 'PRESS ENTER TO RETRY',0
str_esc_menu        db 'ESC FOR MAIN MENU',0

stomp_table         dw 100,200,400,500,800,1000,2000,4000,5000,8000

cloud_positions     dw 48,26,176,36,336,24,512,34,688,26,848,32
hill_positions      dw 16,224,480,736
bush_positions      dw 112,336,448,624,720

; =========================================================================
; RUNTIME VARIABLES & UNINITIALIZED BUFFERS
; =========================================================================
buffer_seg          dw 0
font_seg            dw 0
font_off            dw 0

old_int08_off       dw 0
old_int08_seg       dw 0
old_int09_off       dw 0
old_int09_seg       dw 0
timer_installed     db 0
kb_installed        db 0
pit_ticks           dw 0
pit_acc             dw 0
global_frame        dw 0
quit_flag           db 0

key_left            db 0
key_right           db 0
key_space           db 0
key_shift           db 0
key_up              db 0
key_down            db 0
key_p               db 0
key_enter           db 0
key_esc             db 0

edge_space          db 0
edge_up             db 0
edge_down           db 0
edge_p              db 0
edge_enter          db 0
edge_esc            db 0

game_state          db ST_TITLE
menu_cursor         db 0
pause_cursor        db 0
controls_view       db 0
state_timer         db 0
death_timer         db 0
flag_phase          db 0
flag_y              dw 52
flag_bonus          dw 0
time_bonus          dw 0

player_x            dw MARIO_START_X
player_x_frac       db 0
player_y            dw MARIO_START_Y
player_y_frac       db 0
player_vx           dw 0
player_vy           dw 0
grounded            db 0
was_grounded        db 0
facing_dir          db 1
power_state         db 0
jump_hold_cnt       db 0
invuln_timer        db 0
stomp_combo         db 0
mario_anim          db 0
anim_tick           db 0
land_timer          db 0

score_lo            dw 0
score_hi            dw 0
coins               db 0
lives               db 3
camera_x            dw 0
game_seconds        dw 300
sec_tick_cnt        db 0

mush_active         db 0
mush_rise           db 0
mush_x              dw 0
mush_x_frac         db 0
mush_y              dw 0
mush_y_frac         db 0
mush_vx             dw 0
mush_vy             dw 0

popup_coin_timer    db 0
popup_coin_x        dw 0
popup_coin_y        dw 0

hit_row             dw 0
hit_col             dw 0

draw_x              dw 0
draw_y              dw 0
flip_x              db 0
spr_h               dw 16
spr_ptr             dw 0
spr_row_idx         dw 0
fill_col            db 0
vis_col_start       dw 0
vis_col_end         dw 0
cur_row             dw 0
cur_col             dw 0

text_x              dw 0
text_y              dw 0
text_color          db 8
text_rows           db 0
num_row             db 0
num_col             db 0
num_color           db 8
num_buf             times 8 db 0

work_level_map      times (MAP_COLS * MAP_ROWS) db 0
enemies             times (MAX_ENEMIES * ENEMY_STRUCT_SZ) db 0
particles           times (MAX_PARTICLES * PARTICLE_SZ) db 0
