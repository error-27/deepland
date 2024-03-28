package deepland

import rl "vendor:raylib"

GameState :: enum {
    MENU,
    GAME,
    LOADING,
}

game_state: GameState // Should be changed to menu later on. this is just for testing

update :: proc() {

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
        update()
        draw()
    }
}