package entities

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

PLR_SIZE :: 16
PLR_SPEED :: 200

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

    plr.rx += cast(f32)h_dir * cast(f32)PLR_SPEED * delta
    movex := math.round_f32(plr.rx)
    if movex != 0 {
        plr.rx -= movex
        sign := math.sign(movex)
        //TODO: Write pixel-by-pixel collision
        plr.x += cast(i32)movex
    }

    plr.ry += cast(f32)v_dir * cast(f32)PLR_SPEED * delta
    movey := math.round_f32(plr.ry)
    if movey != 0 {
        plr.ry -= movey
        sign := math.sign(movey)
        //TODO: Write pixel-by-pixel collision
        plr.y += cast(i32)movey
    }
}

plr_draw :: proc() {
    rl.DrawRectangle(plr.x, plr.y, PLR_SIZE, PLR_SIZE, rl.ORANGE)
}