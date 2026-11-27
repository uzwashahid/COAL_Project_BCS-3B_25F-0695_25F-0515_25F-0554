# 🍄 SUPER MARIO BROS — 8086 Assembly Edition

<p align="center">

**A classic Super Mario-inspired platformer built in 8086 Assembly Language.**

</p>

---

## 🎮 About the Project

**Super Mario Bros — 8086 Edition** is a retro-style platform game developed using 8086 Assembly Language. The project recreates the feel of classic Mario gameplay through low-level programming, including player movement, jumping, enemies, collisions, scrolling graphics, scoring, and game-state management.

The game combines multiple assembly modules into a unified game engine, demonstrating how graphics, keyboard input, timing, collision handling, enemy behavior, and game logic can work together at the hardware-oriented programming level.

---

## ✨ Features

- **Classic Platform Gameplay** — Move and jump through a Mario-inspired platform environment.
- **Player Movement & Physics** — Movement, jumping, gravity and landing mechanics.
- **Enemy AI** — Enemy movement, interactions and stomp mechanics.
- **Shell Mechanics** — Shell interactions and shell-based enemy collisions.
- **Collision Detection** — Collision handling between the player, terrain and game objects.
- **Coin Collection** — Collect coins and earn points.
- **Scoring System** — Score tracking, stomp combos and bonuses.
- **Level Timer** — Time-based gameplay and bonus calculations.
- **Game HUD** — Displays gameplay information.
- **Pause System** — Pause, resume, restart and return to the title menu.
- **Game States** — Title menu, gameplay, pause, life loss, game over and course completion.
- **Retro Graphics** — Custom sprite rendering and framebuffer operations.

---

## 🕹️ Controls

| Key | Action |
|---|---|
| ⬅️ Left Arrow | Move Mario left |
| ➡️ Right Arrow | Move Mario right |
| ⇧ Left Shift | Run faster |
| ␣ Space | Jump (hold for a higher jump) |
| P | Pause game |
| Enter | Confirm menu selection / continue |
| Esc | Back / exit depending on game state |

---

## 🏗️ Project Architecture

The project is organized into multiple assembly modules, each responsible for a specific part of the game engine.

| File | Responsibility |
|---|---|
| `main.asm` | Main game loop, initialization and game-state management |
| `graphics.asm` | Graphics rendering, sprites and framebuffer operations |
| `level.asm` | Level initialization, map, object and completion logic |
| `menu.asm` | Menu navigation and menu/game-state screens |
| `player.asm` | Player movement and physics |
| `enemies.asm` | Enemy AI, shell mechanics and stomp behavior |
| `collis.asm` | Collision detection and collision-related logic |
| `hud.asm` | Heads-up display rendering |
| `keyboard.asm` | Keyboard input handling |
| `timer.asm` | Timer and frame synchronization |
| `data.asm` | Constants, variables, game data and shared definitions |

---

## 🧰 Technologies Used

- **8086 Assembly Language**
- **NASM (Netwide Assembler)**
- **DOS COM Executable Format**
- **Low-Level Graphics & Memory Operations**
- **Keyboard Input Handling**
- **Timer-Based Game Loop**

---

## 🚀 Running the Game

The project is designed to produce a DOS `.COM` executable.

### Requirements

- NASM assembler
- DOS-compatible environment
- DOSBox or another compatible DOS emulator, if running on a modern operating system

### Build

The project includes a `build.BAT` script for assembling the game.

1. Install NASM in the expected location or modify the build script to match your NASM installation.
2. Open the project directory in a DOS-compatible environment.
3. Execute the build script.

```bat
build.BAT
```

The assembly process produces:

```text
MARIO.COM
```

### Run

Execute the generated `MARIO.COM` in a compatible DOS environment.

---

## 👥 Team Project

This game was developed collaboratively, with different team members responsible for individual modules of the game engine.

The modular structure allows different components, such as graphics, physics, collisions, enemy logic and menus, to be developed and integrated independently.

---

## 📚 Learning Objectives

This project demonstrates practical applications of:

- Modular programming in Assembly Language
- 8086 architecture and low-level programming
- BIOS and DOS-oriented programming concepts
- Game loops and state machines
- Sprite rendering and framebuffer manipulation
- Collision detection
- Player physics and enemy logic
- Keyboard input and timer handling
- Integration of multiple assembly modules

---

## 🏁 Course Clear!

A project inspired by the iconic platform-game experience, recreated using the fundamentals of low-level programming.

**Built with Assembly. Inspired by the classics. 🍄**
