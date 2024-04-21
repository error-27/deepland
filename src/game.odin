package deepland

import rl "vendor:raylib"
import "core:math"
import "entities"
import "world"

camera: rl.Camera2D

@(private="file")
paused := false

game_init :: proc() {
    entities.plr_init()

    camera = rl.Camera2D{0,0,0,0} // initialize a default camera
    camera.zoom = 1

    camera.target = {cast(f32)entities.plr.x - SCREEN_WIDTH/2 + 8, cast(f32)entities.plr.y - SCREEN_HEIGHT/2 + 8}

    world.init_chunks()
    entities.create(10, 10, .TestObj)
}

game_update :: proc(delta: f32) {
    if !paused {
        entities.plr_update(delta)
        entities.update(delta)
        camera.target = {cast(f32)entities.plr.x - SCREEN_WIDTH/2 + 8, cast(f32)entities.plr.y - SCREEN_HEIGHT/2 + 8}
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
            if !({entities.plr.cx + i32(cx), entities.plr.cy + i32(cy)} in world.chunks) {
                world.generate_chunk(entities.plr.cx + i32(cx), entities.plr.cy + i32(cy))
            }
        }
    }
}

game_draw :: proc() {
    // Render Camera
    rl.BeginMode2D(camera)
        for cx in -1..=1 {
            for cy in -1..=1 {
                world.draw_chunk({entities.plr.cx + i32(cx), entities.plr.cy + i32(cy)})
            }
        }
        entities.plr_draw()
        entities.draw()

        // Draw mouse build preview
        mpos := get_mouse_pos()

        rl.DrawRectangleLines(mpos[0], mpos[1], 16, 16, rl.WHITE)

    rl.EndMode2D()
}

game_end :: proc() {
    entities.clear_entities()
    world.clear_chunks()
}

get_mouse_pos :: proc() -> [2]i32 {
    mpos := rl.GetScreenToWorld2D(rl.GetMousePosition() / UPSCALE, camera)
    mx := math.floor(mpos[0] / 16) * 16
    my := math.floor(mpos[1] / 16) * 16
    return {i32(mx), i32(my)}
}