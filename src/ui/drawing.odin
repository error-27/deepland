package ui

import rl "vendor:raylib"
import "core:math"

number_texture: rl.Texture2D

load_textures :: proc() {
    number_texture = rl.LoadTexture("assets/numbers.png")
}

draw_numbers :: proc(val: u32, x: f32, y: f32) {
    num_length := u32(math.floor_f32(math.log10(f32(val)) + 1))

    for i in 0..<num_length {
        rl.DrawTextureRec(number_texture, {8 * f32(get_digit(val, u32(i), num_length)), 0, 8, 8}, {x + (8 * f32(i)), y}, rl.WHITE)
    }
}

get_digit :: proc(input: u32, index: u32, length: u32) -> u32 {
    number := input
    number = number / u32(math.pow(10, f32((length - 1) - index)))
    return number % 10
}