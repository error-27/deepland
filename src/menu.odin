package deepland

import rl "vendor:raylib"

@(private="file")
selected: int

menu_init :: proc() {
    selected = 0
}

menu_update :: proc(delta: f32) {
    if rl.IsKeyPressed(rl.KeyboardKey.Z) {
        switch_state(.GAME)
    }
}

menu_draw :: proc() {
    rl.DrawText("THIS IS A MENU", 10, 10, 20, rl.RED)
    rl.DrawText("PRESS Z TO PLAY", 10, 40, 10, rl.RED)
}

menu_end :: proc() {

}