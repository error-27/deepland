package world

import rl "vendor:raylib"
import "core:fmt"
import "core:math"
import "../world"

PLR_SIZE :: 16
PLR_SPEED :: 100

MAX_STACK_SIZE :: 100

Player :: struct {
    x: i32, // Position
    y: i32,
    rx: f32, // Subpixel Position (remainder)
    ry: f32,
    dir: Direction,
    cx: i32, // Chunk Position
    cy: i32,
    depth: i32,

    // Actual real data should go here
    health: u8,
    inventory: [20]ItemStack,
    inv_select: u8,
    dir_lock: bool
}

ItemStack :: struct {
    type: ItemType,
    amount: u8
}

plr: Player

plr_init :: proc() {
    plr = Player{}
    plr.inventory[0] = {.WOOD, 14}
    plr.inventory[1] = {.STONE, 14}
    plr.health = 10
    plr.inv_select = 0
    plr.depth = 0
}

plr_update :: proc(delta: f32) {
    // MOUSE PLACE CONTROlS (DISABLED FOR THE TIME BEING)

    // if rl.IsMouseButtonDown(rl.MouseButton.LEFT) && plr.inventory[plr.inv_select].amount > 0 {
    //     mpos := world.get_mouse_pos()
        
    //     // Make sure the position isn't intersecting an entity or the player
    //     if 
    //         !rl.CheckCollisionRecs(plr_get_rectangle(), {f32(mpos[0]) * 16, f32(mpos[1]) * 16, 16, 16}) &&
    //         !is_entity_colliding(rl.Rectangle{f32(mpos[0]) * 16, f32(mpos[1]) * 16, 16, 16})
    //     {
    //         result := world.place_tile(mpos[0], mpos[1], plr.depth, .TESTTILE)
    //         if result {
    //             plr.inventory[plr.inv_select].amount -= 1
    //             if plr.inventory[plr.inv_select].amount == 0 {
    //                 plr.inventory[plr.inv_select].type = .NONE
    //             }
    //         }
    //     }
    // }
    // if rl.IsMouseButtonDown(rl.MouseButton.RIGHT) {
    //     mpos := world.get_mouse_pos()
    //     world.damage_tile(mpos[0], mpos[1], plr.depth)
    // }

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

    left := rl.IsKeyDown(rl.KeyboardKey.A)
    right := rl.IsKeyDown(rl.KeyboardKey.D)
    up := rl.IsKeyDown(rl.KeyboardKey.W)
    down := rl.IsKeyDown(rl.KeyboardKey.S)

    h_dir := cast(i32)right - cast(i32)left
    v_dir := cast(i32)down - cast(i32)up

    plr_move_x(&plr, cast(f32)h_dir * cast(f32)PLR_SPEED, delta)
    plr_move_y(&plr, cast(f32)v_dir * cast(f32)PLR_SPEED, delta)

    plr.cx = i32(math.floor(f32(plr.x) / 256))
    plr.cy = i32(math.floor(f32(plr.y) / 256))

    // Skip direction setting if locked
    if !plr.dir_lock {
        if h_dir == 0 {
            if v_dir == -1 {
                plr.dir = .Up
            } else if v_dir == 1 {
                plr.dir = .Down
            }
        } else if v_dir == 0 {
            if h_dir == -1 {
                plr.dir = .Left
            } else if h_dir == 1 {
                plr.dir = .Right
            }
        }

        // Diagonal movement sets direction to most recent key pressed
        if rl.IsKeyPressed(rl.KeyboardKey.A) {
            plr.dir = .Left
        }
        if rl.IsKeyPressed(rl.KeyboardKey.D) {
            plr.dir = .Right
        }
        if rl.IsKeyPressed(rl.KeyboardKey.W) {
            plr.dir = .Up
        }
        if rl.IsKeyPressed(rl.KeyboardKey.S) {
            plr.dir = .Down
        }
    }

    // Lock player direction
    if rl.IsKeyPressed(rl.KeyboardKey.Q) {
        plr.dir_lock = !plr.dir_lock
    }

    // Keyboard-based block placing
    if rl.IsKeyPressed(rl.KeyboardKey.H) && plr.inventory[plr.inv_select].amount > 0 {
        tpos := plr_get_focused_tile()
        if 
            !rl.CheckCollisionRecs(plr_get_rectangle(), {f32(tpos[0]) * 16, f32(tpos[1]) * 16, 16, 16}) &&
            !is_entity_colliding(rl.Rectangle{f32(tpos[0]) * 16, f32(tpos[1]) * 16, 16, 16})
        {
            result := world.place_tile(tpos[0], tpos[1], plr.depth, item_tiles[plr.inventory[plr.inv_select].type])
            if result {
                plr.inventory[plr.inv_select].amount -= 1
                if plr.inventory[plr.inv_select].amount == 0 {
                    plr.inventory[plr.inv_select].type = .NONE
                }
            }
        }
    }
    if rl.IsKeyDown(rl.KeyboardKey.N) {
        tpos := plr_get_focused_tile()
        damage_tile(tpos[0], tpos[1], plr.depth)
    }

    // Debug controls. To be removed later
    if rl.IsKeyPressed(rl.KeyboardKey.U) {
        plr.depth += 1
    }
    if rl.IsKeyPressed(rl.KeyboardKey.J) {
        plr.depth -= 1
    }
}

plr_draw :: proc() {
    rl.DrawRectangle(plr.x, plr.y, PLR_SIZE, PLR_SIZE, rl.ORANGE)
    tpos := plr_get_focused_tile()
    rl.DrawRectangleLines(tpos[0] * 16, tpos[1] * 16, 16, 16, rl.WHITE)
}

plr_get_rectangle :: proc() -> rl.Rectangle {
    return {f32(plr.x), f32(plr.y), 16, 16}
}

// Returns true if an item is successfully collected, false if not
plr_collect_item :: proc(type: ItemType) -> bool {
    // Find available same-item stacks
    for i in 0..<len(plr.inventory) {
        if plr.inventory[i].type == type && plr.inventory[i].amount < MAX_STACK_SIZE {
            plr.inventory[i].amount += 1
            return true
        }
    }
    
    // Loop again to find first empty slot
    for i in 0..<len(plr.inventory) {
        if plr.inventory[i].type == .NONE {
            plr.inventory[i].type = type
            plr.inventory[i].amount += 1
            return true
        }
    }
    return false
}

// For now these are copied directly from entity movement. may have differences later
@(private="file")
plr_move_x :: proc(me: ^Player, speed: f32, delta: f32) {
    me.rx += speed * delta
    movex := math.round_f32(me.rx)
    if movex != 0 {
        me.rx -= movex
        sign := math.sign(movex)
        for movex != 0 {
            rect := rl.Rectangle{f32(me.x) + sign, f32(me.y), 16, 16}
            if !is_tile_colliding(rect, me.depth) {
                me.x += i32(sign)
                movex -= sign
            } else {
                break
            }
        }
    }
}

@(private="file")
plr_move_y :: proc(me: ^Player, speed: f32, delta: f32) {
    me.ry += speed * delta
    movey := math.round_f32(me.ry)
    if movey != 0 {
        me.ry -= movey
        sign := math.sign(movey)
        for movey != 0 {
            rect := rl.Rectangle{f32(me.x), f32(me.y) + sign, 16, 16}
            if !is_tile_colliding(rect, me.depth) {
                me.y += i32(sign)
                movey -= sign
            } else {
                break
            }
        }
    }
}

@(private="file")
plr_get_focused_tile :: proc() -> [2]i32 {
    tpos := [2]i32{0, 0}

    switch plr.dir {
        case .Left:
            tpos = get_tile_pos(plr.x, plr.y + 8)
        case .Right:
            tpos = get_tile_pos(plr.x + 15, plr.y + 8)
        case .Down:
            tpos = get_tile_pos(plr.x + 8, plr.y + 15)
        case .Up:
            tpos = get_tile_pos(plr.x + 8, plr.y)
    }

    tpos += DirVecs[plr.dir]

    return tpos
}

get_tile_pos :: proc(x: i32, y: i32) -> [2]i32 {
    return {i32(math.floor(f32(x) / 16)), i32(math.floor(f32(y) / 16))}
}