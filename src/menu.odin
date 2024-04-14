package deepland

import rl "vendor:raylib"

menu_update :: proc(delta: f32) {

}

menu_draw :: proc() {
    rl.DrawText("THIS IS A MENU", 10, 10, 20, rl.RED)
}