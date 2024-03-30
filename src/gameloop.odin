package deepland

import rl "vendor:raylib"
import "entities"

GameState :: enum {
    MENU,
    GAME,
}

game_state: GameState // Should be changed to menu later on. this is just for testing

camera: rl.Camera2D

menu_update :: proc(delta: f32) {

}

game_update :: proc(delta: f32) {
    entities.plr_update(delta)
}

draw :: proc() {
    rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.BeginMode2D(camera)
            entities.plr_draw()
        rl.EndMode2D()
    rl.EndDrawing()
}

start_loop :: proc() {
    game_state = GameState.GAME
    camera = rl.Camera2D{0,0,0,0} // initialize a default camera
    camera.zoom = 1.0

    for !rl.WindowShouldClose() {
        delta := rl.GetFrameTime()
        switch game_state {
            case GameState.MENU: menu_update(delta)
            case GameState.GAME: game_update(delta)
        }
        draw()
    }
}