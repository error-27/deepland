package deepland

import rl "vendor:raylib"
import "core:fmt"
import "globals"

SCREEN_WIDTH :: 320
SCREEN_HEIGHT :: 192

WINDOW_WIDTH :: SCREEN_WIDTH * globals.UPSCALE
WINDOW_HEIGHT :: SCREEN_HEIGHT * globals.UPSCALE

screen_target: rl.RenderTexture2D

main :: proc() {
    // Set up window
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "deepland")
    rl.SetExitKey(rl.KeyboardKey.KEY_NULL)
    screen_target = rl.LoadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT)
    rl.SetTargetFPS(60)

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