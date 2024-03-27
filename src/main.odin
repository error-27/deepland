package deepland

import rl "vendor:raylib"
import "core:fmt"

main :: proc() {
    rl.InitWindow(400, 300, "deepland")
    rl.SetTargetFPS(60)

    defer rl.CloseWindow()

    loop()
}