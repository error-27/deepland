package entities

import rl "vendor:raylib"
import "core:math"
import "core:fmt"

// Contains all entity species, should be updated with each addition
Species :: enum {
    TestObj,
    Frog
}

// Stores an entity without needing its type
EPtr :: struct {
    species: Species,
    ptr: rawptr
}

entities: [dynamic]EPtr // The current array of entities

// Procedures for managing and updating entities
create :: proc(x: i32, y: i32, species: Species) -> int {
    e: EPtr
    e.ptr = init_procs[species](x, y)
    e.species = species
    append(&entities, e)
    return len(&entities) // might not be useful. well, better safe than sorry???
}

clear_entities :: proc() {
    for e in entities {
        free(e.ptr)
    }
    clear(&entities)
}

update :: proc(delta: f32) {
    i := 0
    for i < len(entities) {
        e := entities[i]
        update_procs[e.species](e.ptr, delta) // Run the correct update procedure
        
        // If the entity dies, free its resources and remove it
        if die_procs[e.species](e.ptr) {
            free(e.ptr)
            ordered_remove(&entities, i)
            i -= 1 // Step back so we don't skip the next entity
        }
        i += 1
    }
}

draw :: proc() {
    for i in 0..<len(entities) {
        e := entities[i]
        draw_procs[e.species](e.ptr)
    }
}

// Utility procedures for moving entities
// TODO: Move these somewhere better?
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