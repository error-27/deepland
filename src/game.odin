package deepland

import rl "vendor:raylib"
import "core:math"
import "core:strconv"
import "core:strings"
import "world"
import "globals"
import "ui"

@(private="file")
paused := false

game_init :: proc() {
    world.plr_init()

    using globals
    camera = rl.Camera2D{0,0,0,0} // initialize a default camera
    camera.zoom = 1

    camera.target = {cast(f32)world.plr.x - SCREEN_WIDTH/2 + 8, cast(f32)world.plr.y - SCREEN_HEIGHT/2 + 8}

    world.init_chunks()
    world.create_entity(10, 10, 0, .TestObj)
}

game_update :: proc(delta: f32) {
    if !paused {
        world.plr_update(delta)
        world.entities_update(delta)
        globals.camera.target = {cast(f32)world.plr.x - SCREEN_WIDTH/2 + 8, cast(f32)world.plr.y - SCREEN_HEIGHT/2 + 8}
    }

    if rl.IsKeyPressed(rl.KeyboardKey.ESCAPE) {
        paused = !paused
    }

    if rl.IsKeyDown(rl.KeyboardKey.LEFT_ALT) && rl.IsKeyPressed(rl.KeyboardKey.ESCAPE) {
        switch_state(.MENU)
        paused = false
    }

    // Generate new chunks where needed
    // This is done in a 3x3 shape around the player
    for cx in -1..=1 {
        for cy in -1..=1 {
            if !({world.plr.cx + i32(cx), world.plr.cy + i32(cy), world.plr.depth} in world.chunks) {
                world.generate_chunk(world.plr.cx + i32(cx), world.plr.cy + i32(cy), world.plr.depth)
            }
        }
    }
}

game_draw :: proc() {
    // Render Camera
    rl.BeginMode2D(globals.camera)
        for cx in -1..=1 {
            for cy in -1..=1 {
                world.draw_chunk({world.plr.cx + i32(cx), world.plr.cy + i32(cy), world.plr.depth})
            }
        }
        world.entities_draw()
        world.plr_draw()

        // Draw mouse build preview
        mpos := world.get_mouse_pos()

        rl.DrawRectangleLines(mpos[0] * 16, mpos[1] * 16, 16, 16, rl.WHITE)

    rl.EndMode2D()

    draw_hud()
}

game_end :: proc() {
    world.clear_entities()
    world.clear_chunks()
}

@(private="file")
draw_hud :: proc() {
    draw_inventory_slot(world.plr.inv_select, 24, SCREEN_HEIGHT - 20)
    if world.plr.inv_select != 0 {
        draw_inventory_slot(world.plr.inv_select - 1, 4, SCREEN_HEIGHT - 20)
    }
    if world.plr.inv_select < len(world.plr.inventory) - 1 {
        draw_inventory_slot(world.plr.inv_select + 1, 44, SCREEN_HEIGHT - 20)
    }

    buf: [3]byte
    selection_str := strconv.itoa(buf[:], int(world.plr.inv_select))
    rl.DrawText(strings.clone_to_cstring(selection_str), 10, 40, 20, rl.BLUE)

    ui.draw_numbers(u32(world.plr.depth), 10, 10)
}

@(private="file")
draw_inventory_slot :: proc(index: u8, x: i32, y: i32) {
    rl.DrawRectangle(x, y, 16, 16, rl.GRAY)
}