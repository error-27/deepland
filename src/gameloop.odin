package deepland

import rl "vendor:raylib"
import "entities"
import "world"

GameState :: enum {
    MENU,
    GAME,
}

game_state: GameState // Should be changed to menu later on. this is just for testing

camera: rl.Camera2D

rtex_rect: rl.Rectangle = {0, 0, SCREEN_WIDTH, -SCREEN_HEIGHT}
window_rect: rl.Rectangle = {0, 0, WINDOW_WIDTH, WINDOW_HEIGHT}

menu_update :: proc(delta: f32) {

}

game_update :: proc(delta: f32) {
    entities.plr_update(delta)
    entities.update(delta)
    camera.target = {cast(f32)entities.plr.x - SCREEN_WIDTH/2 + 8, cast(f32)entities.plr.y - SCREEN_HEIGHT/2 + 8}
}

draw :: proc() {
    // Draw to a small texture to be scaled up
    rl.BeginTextureMode(screen_target)
        rl.ClearBackground(rl.BLACK)

        switch game_state {
            case .GAME:
                game_draw()
            case .MENU:
                menu_draw()
        }        
    rl.EndTextureMode()

    rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        // Draw upscaled texture
        rl.DrawTexturePro(screen_target.texture, rtex_rect, window_rect, {0,0}, 0, rl.WHITE)
    rl.EndDrawing()
}

menu_draw :: proc() {
    rl.DrawText("THIS IS A MENU", 10, 10, 20, rl.RED)
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

start_loop :: proc() {
    game_state = GameState.MENU
    camera = rl.Camera2D{0,0,0,0} // initialize a default camera
    camera.zoom = 1.0

    world.init_chunks()

    for !rl.WindowShouldClose() {
        delta := rl.GetFrameTime()
        switch game_state {
            case GameState.MENU: 
                menu_update(delta)
            case GameState.GAME: 
                game_update(delta)
        }
        draw()
    }

    entities.clear_entities()
}