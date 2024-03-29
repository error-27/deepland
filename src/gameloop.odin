package deepland

import rl "vendor:raylib"
import "entities"

GameState :: enum {
    MENU,
    GAME,
}

game_state: GameState // Should be changed to menu later on. this is just for testing

menu_update :: proc(delta: f32) {

}

game_update :: proc(delta: f32) {
    entities.plr_update(delta)
}

draw :: proc() {
    rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        entities.plr_draw()
    rl.EndDrawing()
}

start_loop :: proc() {
    game_state = GameState.GAME

    for !rl.WindowShouldClose() {
        delta := rl.GetFrameTime()
        switch game_state {
            case GameState.MENU: menu_update(delta)
            case GameState.GAME: game_update(delta)
        }
        draw()
    }
}