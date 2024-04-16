package world

import rl "vendor:raylib"

NOISE_SCALE :: 2
THRESHOLD :: 128

TileType :: enum {
    NONE,
    TESTTILE
}

Tile :: struct {
    type: TileType,
    state: u8
}

Floor :: enum {
    DIRT,
    GRASS
}

Chunk :: struct {
    tiles: [16][16]Tile,
    floors: [16][16]Floor,
    x: i32,
    y: i32,
}

chunks: map[[2]i32]Chunk

init_chunks :: proc() {
    generate_chunk(0, 0)
    generate_chunk(1, 0)
    generate_chunk(1, 1)
}

generate_chunk :: proc(x: i32, y: i32) {
    noise := rl.GenImagePerlinNoise(16, 16, x * 16, y * 16, NOISE_SCALE)
    c := Chunk{}
    for nx in 0..<16 {
        for ny in 0..<16 {
            v := rl.GetImageColor(noise, i32(nx), i32(ny))[0]
            if v > THRESHOLD {
                c.floors[nx][ny] = .DIRT
            } else {
                c.floors[nx][ny] = .GRASS
            }
        }
    }

    c.x = x
    c.y = y
    chunks[{x, y}] = c
}

draw_chunk :: proc(coord: [2]i32) {
    c := chunks[coord]
    for x in 0..<16 {
        for y in 0..<16 {
            switch c.floors[x][y] {
                case .DIRT:
                    rl.DrawRectangle(256 * c.x + i32(x) * 16, 256 * c.y + i32(y) * 16, 16, 16, rl.BROWN)
                case .GRASS:
                    rl.DrawRectangle(256 * c.x + i32(x) * 16, 256 * c.y + i32(y) * 16, 16, 16, rl.GREEN)
            }
        }
    }
}