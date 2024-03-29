package entities

import rl "vendor:raylib"
import "core:fmt"

PLR_SIZE :: 32

Player :: struct {
    x: i32,
    y: i32,
    dir: u8
}

plr := Player{20, 20, 0}

plr_update :: proc(delta: f32) {
    left := rl.IsKeyDown(rl.KeyboardKey.LEFT)
    right := rl.IsKeyDown(rl.KeyboardKey.RIGHT)
    up := rl.IsKeyDown(rl.KeyboardKey.UP)
    down := rl.IsKeyDown(rl.KeyboardKey.DOWN)

    h_motion := cast(i32)right - cast(i32)left
    v_motion := cast(i32)down - cast(i32)up
    plr.x += h_motion * 4
    plr.y += v_motion * 4
}

plr_draw :: proc() {
    rl.DrawRectangle(plr.x, plr.y, PLR_SIZE, PLR_SIZE, rl.ORANGE)
}