package deepland

import rl "vendor:raylib"
import "entities"

GameState :: enum {
    MENU,
    GAME,
}

game_state: GameState // Should be changed to menu later on. this is just for testing

menu_update :: proc() {

}

game_update :: proc() {
    entities.plr_update()
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
        switch game_state {
            case GameState.MENU: menu_update()
            case GameState.GAME: game_update()
        }
        draw()
    }
}