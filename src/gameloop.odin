package deepland

import rl "vendor:raylib"

GameState :: enum {
    MENU,
    GAME,
}

game_state: GameState // Should be changed to menu later on. this is just for testing

menu_update :: proc() {

}

game_update :: proc() {

}

draw :: proc() {
    rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.DrawRectangle(10, 10, 40, 40, rl.GRAY)
        if game_state == GameState.GAME {
            rl.DrawText("playing game", 50, 50, 15, rl.GREEN)
        }
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