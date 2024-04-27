package world

import rl "vendor:raylib"
import "core:math"
import "core:fmt"
import "../globals"

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
                    rl.DrawRectangle(256 * c.x + i32(x) * 16, 256 * c.y + i32(y) * 16, 16, 16, {255 - (c.tiles[x][y].state) * 20, 0, 0, 255})
            }
        }
    }
    rl.DrawLine(coord[0] * 256, coord[1] * 256, (coord[0] + 1) * 256, coord[1] * 256, rl.RAYWHITE)
    rl.DrawLine(coord[0] * 256, coord[1] * 256, coord[0] * 256, (coord[1] + 1) * 256, rl.RAYWHITE)
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

get_collisions :: proc(rect: rl.Rectangle) -> bool {
    // Because I don't like the idea of copying entire chunks in memory every frame I'm going to go by index here
    to_check: [4][2]i32
    chk_flags: [4]bool

    base_chunk_x := i32(math.floor(rect.x / 256))
    base_chunk_y := i32(math.floor(rect.y / 256))
    chk_flags[0] = true

    // Chunk at coordinate
    to_check[0] = {base_chunk_x, base_chunk_y}

    // if it extends horizontally into a neighboring chunk, add that chunk
    if i32(math.floor((rect.x + rect.width) / 256)) != base_chunk_x {
        to_check[1] = {i32(math.floor((rect.x + rect.width) / 256)), base_chunk_y}
        chk_flags[1] = true
    }

    // if it extends vertically into a neighboring chunk, add that chunk
    if i32(math.floor((rect.y + rect.height) / 256)) != base_chunk_y {
        to_check[2] = {base_chunk_x, i32(math.floor((rect.y + rect.height) / 256))}
        chk_flags[2] = true
    }

    // if it extends both ways, it's at a corner and we need a 4th chunk
    if chk_flags[1] && chk_flags[2] {
        to_check[3] = {to_check[1][0], to_check[2][1]}
        chk_flags[3] = true
    }

    for v, i in to_check {
        if !chk_flags[i] {
            continue
        }

        for x in 0..<16 {
            for y in 0..<16 {
                t := chunks[v].tiles[x][y]
                if t.type == .NONE {
                    continue
                }

                real_x := v[0] * 256 + i32(x) * 16 // Chunk x * 256 pixels + tile x * 16 pixels
                real_y := v[1] * 256 + i32(y) * 16

                res := rl.CheckCollisionRecs(rect, {f32(real_x), f32(real_y), 16, 16})

                if !res {
                    continue
                }
                
                return true
            }
        }
    }

    return false
}

// Gets tile coords of the mouse (each tile is 16 pixels, so multiply by 16 to get real coords)
get_mouse_pos :: proc() -> [2]i32 {
    mpos := rl.GetScreenToWorld2D(rl.GetMousePosition() / globals.UPSCALE, globals.camera)
    mx := math.floor(mpos[0] / 16)
    my := math.floor(mpos[1] / 16)
    return {i32(mx), i32(my)}
}