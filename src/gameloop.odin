package deepland

import rl "vendor:raylib"
import "entities"

GameState :: enum {
    MENU,
    GAME,
}

game_state: GameState // Should be changed to menu later on. this is just for testing

camera: rl.Camera2D
window_camera: rl.Camera2D

rtex_rect: rl.Rectangle = {0, 0, SCREEN_WIDTH, -SCREEN_HEIGHT}
window_rect: rl.Rectangle = {0, 0, WINDOW_WIDTH, WINDOW_HEIGHT}

menu_update :: proc(delta: f32) {

}

game_update :: proc(delta: f32) {
    entities.plr_update(delta)
}

draw :: proc() {
    rl.BeginTextureMode(screen_target)
        rl.ClearBackground(rl.RAYWHITE)

        rl.BeginMode2D(camera)
            entities.plr_draw()
        rl.EndMode2D()
    rl.EndTextureMode()

    rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        rl.BeginMode2D(window_camera)
            rl.DrawTexturePro(screen_target.texture, rtex_rect, window_rect, {0,0}, 0, rl.WHITE)
        rl.EndMode2D()
    rl.EndDrawing()
}

start_loop :: proc() {
    game_state = GameState.GAME
    camera = rl.Camera2D{0,0,0,0} // initialize a default camera
    camera.zoom = 1.0

    window_camera = rl.Camera2D{0,0,0,0}
    window_camera.zoom = 1.0

    for !rl.WindowShouldClose() {
        delta := rl.GetFrameTime()
        switch game_state {
            case GameState.MENU: menu_update(delta)
            case GameState.GAME: game_update(delta)
        }
        draw()
    }
}