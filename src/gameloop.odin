package deepland

import rl "vendor:raylib"
import "core:strconv"
import "core:strings"
import "ui"

GameState :: enum {
    MENU,
    GAME,
}

game_state: GameState // Should be changed to menu later on. this is just for testing

rtex_rect: rl.Rectangle = {0, 0, SCREEN_WIDTH, -SCREEN_HEIGHT}
window_rect: rl.Rectangle = {0, 0, WINDOW_WIDTH, WINDOW_HEIGHT}

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
        rl.DrawFPS(1, 1)
    rl.EndDrawing()
}

start_loop :: proc() {
    ui.load_textures()
    switch_state(.MENU)

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

    game_end()
    menu_end()
}

switch_state :: proc(new_state: GameState) {
    switch game_state {
        case .GAME:
            game_end()
        case .MENU:
            menu_end()
    }

    switch new_state {
        case .GAME:
            game_init()
        case .MENU:
            menu_init()
    }

    game_state = new_state
}