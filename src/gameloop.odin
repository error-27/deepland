package deepland

import rl "vendor:raylib"

update :: proc() {

}

draw :: proc() {
    rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.DrawRectangle(10, 10, 40, 40, rl.GRAY)
    rl.EndDrawing()
}

loop :: proc() {
    for !rl.WindowShouldClose() {
        update()
        draw()
    }
}