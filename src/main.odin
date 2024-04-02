package deepland

import rl "vendor:raylib"
import "core:fmt"

SCREEN_WIDTH :: 320
SCREEN_HEIGHT :: 192

UPSCALE :: 3

WINDOW_WIDTH :: SCREEN_WIDTH * UPSCALE
WINDOW_HEIGHT :: SCREEN_HEIGHT * UPSCALE

screen_target: rl.RenderTexture2D

main :: proc() {
    // Set up window
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "deepland")
    screen_target = rl.LoadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT)
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
    defer rl.UnloadRenderTexture(screen_target)
    defer rl.CloseAudioDevice()

    start_loop()
}