package entities

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

PLR_SIZE :: 16
PLR_SPEED :: 100

Player :: struct {
    x: i32,
    y: i32,
    rx: f32,
    ry: f32,
    dir: Direction
}

plr := Player{}

plr_update :: proc(delta: f32) {
    left := rl.IsKeyDown(rl.KeyboardKey.LEFT)
    right := rl.IsKeyDown(rl.KeyboardKey.RIGHT)
    up := rl.IsKeyDown(rl.KeyboardKey.UP)
    down := rl.IsKeyDown(rl.KeyboardKey.DOWN)

    h_dir := cast(i32)right - cast(i32)left
    v_dir := cast(i32)down - cast(i32)up

    moveX(&plr.x, &plr.rx, cast(f32)h_dir * cast(f32)PLR_SPEED, delta)
    moveY(&plr.y, &plr.ry, cast(f32)v_dir * cast(f32)PLR_SPEED, delta)
}

plr_draw :: proc() {
    rl.DrawRectangle(plr.x, plr.y, PLR_SIZE, PLR_SIZE, rl.ORANGE)
}