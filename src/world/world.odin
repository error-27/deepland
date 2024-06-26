package world

import rl "vendor:raylib"
import "core:math"
import "core:fmt"
import "../globals"

NOISE_SCALE :: 2
THRESHOLD :: 128

TileType :: enum {
    NONE,
    WOOD,
    STONE
}

Tile :: struct {
    type: TileType,
    damage: u8,
    state: u8
}

Floor :: enum {
    DIRT,
    GRASS,
    STAIR_DOWN,
    STAIR_UP
}

Chunk :: struct {
    tiles: [16][16]Tile,
    floors: [16][16]Floor,
    x: i32,
    y: i32,
}

chunks: map[[3]i32]Chunk

// Air should never break, right?? Well if it does something else is seriously wrong
block_drops := #partial [TileType]ItemStack {
    .WOOD = ItemStack{.WOOD, 1},
    .STONE = ItemStack{.STONE, 1}
}

item_tiles := #partial [ItemType]TileType {
    .WOOD = .WOOD,
    .STONE = .STONE
}

floor_textures := [Floor][2]i32 {
    .GRASS = {0, 0},
    .DIRT = {1, 0},
    .STAIR_DOWN = {0, 1},
    .STAIR_UP = {1, 1}
}

tile_textures := #partial [TileType][2]i32 {
    .WOOD = {0, 0},
    .STONE = {1, 0}
}

ground_tex: rl.Texture2D
tile_tex: rl.Texture2D

init_world :: proc() {
    ground_tex = rl.LoadTexture("assets/ground_tiles.png")
    tile_tex = rl.LoadTexture("assets/tiles.png")
}

deinit_world :: proc() {
    rl.UnloadTexture(ground_tex)
    rl.UnloadTexture(tile_tex)
    clear_entities()
    clear_chunks()
}

generate_chunk :: proc(x: i32, y: i32, depth: i32) {
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

    if x + y % 3 == 0 {
        c.floors[8][8] = .STAIR_UP
    }

    chunks[{x, y, depth}] = c
}

draw_chunk :: proc(coord: [3]i32) {
    c := chunks[coord]
    for x in 0..<16 {
        for y in 0..<16 {
            draw_floor(c.x, c.y, i32(x), i32(y), c.floors[x][y])

            draw_tile(c.x, c.y, i32(x), i32(y), c.tiles[x][y].type)
        }
    }
    rl.DrawLine(coord[0] * 256, coord[1] * 256, (coord[0] + 1) * 256, coord[1] * 256, rl.RAYWHITE)
    rl.DrawLine(coord[0] * 256, coord[1] * 256, coord[0] * 256, (coord[1] + 1) * 256, rl.RAYWHITE)
}

draw_floor :: proc(cx: i32, cy: i32, tx: i32, ty: i32, type: Floor) {
    tcoord := floor_textures[type] * 16
    trec := rl.Rectangle{f32(tcoord[0]), f32(tcoord[1]), 16, 16}
    rl.DrawTextureRec(ground_tex, trec, {f32(256 * cx + 16 * tx), f32(256 * cy + 16 * ty)}, rl.WHITE)
}

draw_tile :: proc(cx: i32, cy: i32, tx: i32, ty: i32, type: TileType) {
    if type == .NONE {
        return
    }
    tcoord := tile_textures[type] * 16
    trec := rl.Rectangle{f32(tcoord[0]), f32(tcoord[1]), 16, 16}
    rl.DrawTextureRec(tile_tex, trec, {f32(256 * cx + 16 * tx), f32(256 * cy + 16 * ty)}, rl.WHITE)
}

clear_chunks :: proc() {
    clear(&chunks)
}

// Returns false when a place fails, returns true when it succeeds
place_tile :: proc(x: i32, y: i32, depth: i32, tile: TileType) -> bool {
    chunk_x := i32(math.floor(f32(x) / 16))
    chunk_y := i32(math.floor(f32(y) / 16))

    c := &chunks[{chunk_x, chunk_y, depth}]
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
        return false
    }

    c.tiles[tx][ty] = t
    return true
}

damage_tile :: proc(x: i32, y: i32, depth: i32) {
    chunk_x := i32(math.floor(f32(x) / 16))
    chunk_y := i32(math.floor(f32(y) / 16))

    c := &chunks[{chunk_x, chunk_y, depth}]

    tx := x % 16
    ty := y % 16

    if tx < 0 {
        tx = 16 + tx
    }
    if ty < 0 {
        ty = 16 + ty
    }

    c.tiles[tx][ty].damage += 1

    if c.tiles[tx][ty].damage == 30 {
        drops := block_drops[c.tiles[tx][ty].type]
        for i in 0..<drops.amount {
            create_item(x * 16, y * 16, plr.depth, drops.type)
        }
        c.tiles[tx][ty] = Tile{.NONE, 0, 0}
    }
}

is_tile_colliding :: proc(rect: rl.Rectangle, depth: i32) -> bool {
    // Because I don't like the idea of copying entire chunks in memory every frame I'm going to go by index here
    to_check: [4][3]i32
    chk_flags: [4]bool

    base_chunk_x := i32(math.floor(rect.x / 256))
    base_chunk_y := i32(math.floor(rect.y / 256))
    chk_flags[0] = true

    // Chunk at coordinate
    to_check[0] = {base_chunk_x, base_chunk_y, depth}

    // if it extends horizontally into a neighboring chunk, add that chunk
    if i32(math.floor((rect.x + rect.width) / 256)) != base_chunk_x {
        to_check[1] = {i32(math.floor((rect.x + rect.width) / 256)), base_chunk_y, depth}
        chk_flags[1] = true
    }

    // if it extends vertically into a neighboring chunk, add that chunk
    if i32(math.floor((rect.y + rect.height) / 256)) != base_chunk_y {
        to_check[2] = {base_chunk_x, i32(math.floor((rect.y + rect.height) / 256)), depth}
        chk_flags[2] = true
    }

    // if it extends both ways, it's at a corner and we need a 4th chunk
    if chk_flags[1] && chk_flags[2] {
        to_check[3] = {to_check[1][0], to_check[2][1], depth}
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