package entities

import rl "vendor:raylib"
import "core:math"

Entity :: struct {
    x: i32,
    y: i32,
    rx: f32,
    ry: f32,
}

Frog :: struct {
    froginess: i32,
    using entity: Entity
}

Species :: enum {
    TestObj,
    Frog
}

Direction :: enum {
    Up,
    Right,
    Down,
    Left
}

EPtr :: struct {
    species: Species,
    ptr: rawptr
}

entities: [dynamic]EPtr

create :: proc(x: i32, y: i32, species: Species) -> int {
    e: EPtr
    e.ptr = init_procs[species](x, y)
    e.species = species
    append(&entities, e)
    return len(&entities)
}

clear_entities :: proc() {
    clear(&entities)
}

moveX :: proc(x: ^i32, rx: ^f32, speed: f32, delta: f32) {
    rx^ += speed * delta
    movex := math.round_f32(rx^)
    if movex != 0 {
        rx^ -= movex
        sign := math.sign(movex)
        //TODO: Write pixel-by-pixel collision
        x^ += cast(i32)movex
    }
}

moveY :: proc(y: ^i32, ry: ^f32, speed: f32, delta: f32) {
    ry^ += speed * delta
    movey := math.round_f32(ry^)
    if movey != 0 {
        ry^ -= movey
        sign := math.sign(movey)
        //TODO: Write pixel-by-pixel collision
        y^ += cast(i32)movey
    }
}

update :: proc(delta: f32) {
    for i in 0..<len(entities) {
        e := entities[i]
        update_procs[e.species](e.ptr, delta)
        // testobj_update(e, delta)
    }
}

draw :: proc() {
    for i in 0..<len(entities) {
        e := entities[i]
        draw_procs[e.species](e.ptr)
    }
}