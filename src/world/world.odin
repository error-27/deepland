package world

import rl "vendor:raylib"
import "core:math"

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
    place_tile(3, 6, .TESTTILE)
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

            #partial switch c.tiles[x][y].type {
                case .TESTTILE:
                    rl.DrawRectangle(256 * c.x + i32(x) * 16, 256 * c.y + i32(y) * 16, 16, 16, rl.RED)
            }
        }
    }
}

clear_chunks :: proc() {
    clear(&chunks)
}

place_tile :: proc(x: i32, y: i32, tile: TileType) {
    chunk_x := i32(math.floor(f32(x) / 16))
    chunk_y := i32(math.floor(f32(y) / 16))

    c := &chunks[{chunk_x, chunk_y}]
    t := Tile{}
    t.type = tile

    tx := x % 16
    ty := y % 16

    if tx < 0 {
        tx = 16 + tx
    }
    if ty < 0 {
        ty = 16 + ty
    }

    if c.tiles[tx][ty].type != .NONE {
        return
    }

    c.tiles[tx][ty] = t
}

damage_tile :: proc(x: i32, y: i32) {
    chunk_x := i32(math.floor(f32(x) / 16))
    chunk_y := i32(math.floor(f32(y) / 16))

    c := &chunks[{chunk_x, chunk_y}]

    tx := x % 16
    ty := y % 16

    c.tiles[tx][ty].state += 1

    if c.tiles[tx][ty].state == 5 {
        c.tiles[tx][ty] = Tile{.NONE, 0}
    }
}