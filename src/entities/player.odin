package entities

import rl "vendor:raylib"
import "core:fmt"
import "core:math"

PLR_SIZE :: 16
PLR_SPEED :: 100

Player :: struct {
    x: i32, // Position
    y: i32,
    rx: f32, // Subpixel Position (remainder)
    ry: f32,
    dir: Direction,
    cx: i32, // Chunk Position
    cy: i32
}

plr: Player

plr_init :: proc() {
    plr = Player{}
}

plr_update :: proc(delta: f32) {
    left := rl.IsKeyDown(rl.KeyboardKey.LEFT) || rl.IsKeyDown(rl.KeyboardKey.A)
    right := rl.IsKeyDown(rl.KeyboardKey.RIGHT) || rl.IsKeyDown(rl.KeyboardKey.D)
    up := rl.IsKeyDown(rl.KeyboardKey.UP) || rl.IsKeyDown(rl.KeyboardKey.W)
    down := rl.IsKeyDown(rl.KeyboardKey.DOWN) || rl.IsKeyDown(rl.KeyboardKey.S)

    h_dir := cast(i32)right - cast(i32)left
    v_dir := cast(i32)down - cast(i32)up

    moveX({&plr.x, &plr.y}, &plr.rx, cast(f32)h_dir * cast(f32)PLR_SPEED, delta)
    moveY({&plr.x, &plr.y}, &plr.ry, cast(f32)v_dir * cast(f32)PLR_SPEED, delta)

    plr.cx = i32(math.floor(f32(plr.x) / 256))
    plr.cy = i32(math.floor(f32(plr.y) / 256))
}

plr_draw :: proc() {
    rl.DrawRectangle(plr.x, plr.y, PLR_SIZE, PLR_SIZE, rl.ORANGE)
}

plr_get_rectangle :: proc() -> rl.Rectangle {
    return {f32(plr.x) + plr.rx, f32(plr.y) + plr.ry, 16, 16}
}