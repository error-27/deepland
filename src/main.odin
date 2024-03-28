package deepland

import rl "vendor:raylib"
import "core:fmt"

main :: proc() {
    rl.InitWindow(800, 600, "deepland")
    rl.SetTargetFPS(60)

    defer rl.CloseWindow()

    start_loop()
}