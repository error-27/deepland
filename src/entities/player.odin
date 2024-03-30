package entities

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

PLR_SIZE :: 32
PLR_SPEED :: 5

Player :: struct {
    x: i32,
    y: i32,
    rx: f32,
    ry: f32,
    dir: u8
}

plr := Player{20, 20, 0, 0, 0}

plr_update :: proc(delta: f32) {
    left := rl.IsKeyDown(rl.KeyboardKey.LEFT)
    right := rl.IsKeyDown(rl.KeyboardKey.RIGHT)
    up := rl.IsKeyDown(rl.KeyboardKey.UP)
    down := rl.IsKeyDown(rl.KeyboardKey.DOWN)

    h_dir := cast(i32)right - cast(i32)left
    v_dir := cast(i32)down - cast(i32)up

    h_motion := cast(f32)h_dir * cast(f32)PLR_SPEED * delta
    v_motion := cast(f32)v_dir * cast(f32)PLR_SPEED * delta

    // Get whole number movements
    vx := math.floor_f32(h_motion)
    vy := math.floor_f32(v_motion)

    // Get remainders
    rx := h_motion - vx
    ry := v_motion - vy

    plr.rx += rx
    plr.ry += ry

    if plr.rx >= 1 {
        vx += 1
        plr.rx -= 1
    }else if plr.rx < 0 {
        vx -= 1
        plr.rx += 1
    }

    if plr.ry >= 1 {
        vy += 1
        plr.ry -= 1
    }else if plr.ry < 0 {
        vx -= 1
        plr.rx += 1
    }

    plr.x += cast(i32)rx
    plr.y += cast(i32)ry
}

plr_draw :: proc() {
    rl.DrawRectangle(plr.x, plr.y, PLR_SIZE, PLR_SIZE, rl.ORANGE)
}