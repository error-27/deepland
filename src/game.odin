package deepland

import rl "vendor:raylib"
import "entities"
import "world"

camera: rl.Camera2D

game_init :: proc() {
    entities.plr_init()

    camera = rl.Camera2D{0,0,0,0} // initialize a default camera
    camera.zoom = 1.0

    camera.target = {cast(f32)entities.plr.x - SCREEN_WIDTH/2 + 8, cast(f32)entities.plr.y - SCREEN_HEIGHT/2 + 8}

    world.init_chunks()
}

game_update :: proc(delta: f32) {
    entities.plr_update(delta)
    entities.update(delta)
    camera.target = {cast(f32)entities.plr.x - SCREEN_WIDTH/2 + 8, cast(f32)entities.plr.y - SCREEN_HEIGHT/2 + 8}

    if rl.IsKeyPressed(rl.KeyboardKey.ESCAPE) {
        switch_state(.MENU)
    }
}

game_draw :: proc() {
    // Render Camera
    rl.BeginMode2D(camera)
        for c in world.chunks {
            world.draw_chunk(c)
        }
        entities.plr_draw()
        entities.draw()
    rl.EndMode2D()
}

game_end :: proc() {
    entities.clear_entities()
}