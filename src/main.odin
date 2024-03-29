package deepland

import rl "vendor:raylib"
import "core:fmt"

main :: proc() {
    // Set up window
    rl.InitWindow(800, 600, "deepland")
    rl.SetTargetFPS(60)
    rl.HideCursor()

    // Set up audio
    rl.InitAudioDevice()

    // Wait until audio is ready
    for !rl.IsAudioDeviceReady() {
        rl.BeginDrawing()
            rl.ClearBackground(rl.BLACK)
            rl.DrawText("INITIALIZING AUDIO DEVICE...", 10, 10, 20, rl.WHITE)
        rl.EndDrawing()
    }

    // Correctly shut down when game ends
    defer rl.CloseWindow()
    defer rl.CloseAudioDevice()

    start_loop()
}