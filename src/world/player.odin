package world

import rl "vendor:raylib"
import "core:fmt"
import "core:math"
import "../world"

PLR_SIZE :: 16
PLR_SPEED :: 100

Player :: struct {
    x: i32, // Position
    y: i32,
    rx: f32, // Subpixel Position (remainder)
    ry: f32,
    dir: Direction,
    cx: i32, // Chunk Position
    cy: i32,

    // Actual real data should go here
    health: u8,
    inventory: [20]ItemStack,
    inv_select: u8
}

ItemStack :: struct {
    type: ItemType,
    amount: u8
}

plr: Player

plr_init :: proc() {
    plr = Player{}
    plr.inventory[0] = {.BLOCK, 14}
    plr.health = 10
    plr.inv_select = 0
}

plr_update :: proc(delta: f32) {
    if rl.IsMouseButtonDown(rl.MouseButton.LEFT) && plr.inventory[plr.inv_select].amount > 0 {
        mpos := world.get_mouse_pos()
        if !rl.CheckCollisionRecs(plr_get_rectangle(), {f32(mpos[0]) * 16, f32(mpos[1]) * 16, 16, 16}) {
            result := world.place_tile(mpos[0], mpos[1], .TESTTILE)
            if result {
                plr.inventory[plr.inv_select].amount -= 1
            }
        }
    }
    if rl.IsMouseButtonDown(rl.MouseButton.RIGHT) {
        mpos := world.get_mouse_pos()
        world.damage_tile(mpos[0], mpos[1])
    }

    mouse_move := rl.GetMouseWheelMove()

    if mouse_move > 0 {
        plr.inv_select += 1

        if plr.inv_select >= len(plr.inventory) {
            plr.inv_select = 0
        }
    }else if mouse_move < 0 {
        if plr.inv_select == 0 {
            plr.inv_select = len(plr.inventory) - 1
        } else {
            plr.inv_select -= 1
        }
    }

    left := rl.IsKeyDown(rl.KeyboardKey.LEFT) || rl.IsKeyDown(rl.KeyboardKey.A)
    right := rl.IsKeyDown(rl.KeyboardKey.RIGHT) || rl.IsKeyDown(rl.KeyboardKey.D)
    up := rl.IsKeyDown(rl.KeyboardKey.UP) || rl.IsKeyDown(rl.KeyboardKey.W)
    down := rl.IsKeyDown(rl.KeyboardKey.DOWN) || rl.IsKeyDown(rl.KeyboardKey.S)

    h_dir := cast(i32)right - cast(i32)left
    v_dir := cast(i32)down - cast(i32)up

    move_x({&plr.x, &plr.y}, &plr.rx, cast(f32)h_dir * cast(f32)PLR_SPEED, delta)
    move_y({&plr.x, &plr.y}, &plr.ry, cast(f32)v_dir * cast(f32)PLR_SPEED, delta)

    plr.cx = i32(math.floor(f32(plr.x) / 256))
    plr.cy = i32(math.floor(f32(plr.y) / 256))
}

plr_draw :: proc() {
    rl.DrawRectangle(plr.x, plr.y, PLR_SIZE, PLR_SIZE, rl.ORANGE)
}

plr_get_rectangle :: proc() -> rl.Rectangle {
    return {f32(plr.x) + plr.rx, f32(plr.y) + plr.ry, 16, 16}
}