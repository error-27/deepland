package world

import rl "vendor:raylib"
import "core:math"
import "core:fmt"

// Contains all entity species, should be updated with each addition
Species :: enum {
    Item,
    TestObj,
    Frog
}

// Stores an entity without needing its type
Entity :: struct {
    x: i32,
    y: i32,
    rx: f32,
    ry: f32,
    cx: i32,
    cy: i32,
    species: Species,
    data: rawptr,
    hitbox_size: u32
}

entities: [dynamic]Entity // The current array of entities

// Procedures for managing and updating entities
create_entity :: proc(x: i32, y: i32, species: Species) -> int {
    e := init_procs[species](x, y)
    e.cx = i32(math.floor(f32(x) / 256))
    e.cy = i32(math.floor(f32(y) / 256))
    append(&entities, e)
    return len(&entities) // might not be useful. well, better safe than sorry???
}

create_item :: proc(x: i32, y: i32, type: ItemType) {
    i := create_entity(x, y, .Item)
    data := cast(^ItemData)entities[i-1].data
    entities[i-1].x += i32(rl.GetRandomValue(0, 15))
    entities[i-1].y += i32(rl.GetRandomValue(0, 15))
    data.type = type
}

clear_entities :: proc() {
    for e in entities {
        free(e.data)
    }
    clear(&entities)
}

entities_update :: proc(delta: f32) {
    i := 0
    for i < len(entities) {
        e := &entities[i]

        // Exclude entities that aren't in render distance
        if e.cx < plr.cx -1 || e.cx > plr.cx + 1 || e.cy < plr.cy -1 || e.cy > plr.cy + 1 {
            i += 1
            continue
        }

        update_procs[e.species](e, delta) // Run the correct update procedure

        // Update chunk coords
        e.cx = i32(math.floor(f32(e.x) / 256))
        e.cy = i32(math.floor(f32(e.y) / 256))
        
        // If the entity dies, free its resources and remove it
        if die_procs[e.species](e) {
            free(e.data)
            ordered_remove(&entities, i)
            i -= 1 // Step back so we don't skip the next entity
        }
        i += 1
    }
}

entities_draw :: proc() {
    for i in 0..<len(entities) {
        e := &entities[i]
        draw_procs[e.species](e)
    }
}

// Utility procedures for moving entities
// TODO: Move these somewhere better?
move_x :: proc(me: ^Entity, speed: f32, delta: f32) {
    me.rx += speed * delta
    movex := math.round_f32(me.rx)
    if movex != 0 {
        me.rx -= movex
        sign := math.sign(movex)
        for movex != 0 {
            rect := rl.Rectangle{f32(me.x) + sign, f32(me.y), f32(me.hitbox_size), f32(me.hitbox_size)}
            if !get_collisions(rect) {
                me.x += i32(sign)
                movex -= sign
            } else {
                break
            }
        }
    }
}

move_y :: proc(me: ^Entity, speed: f32, delta: f32) {
    me.ry += speed * delta
    movey := math.round_f32(me.ry)
    if movey != 0 {
        me.ry -= movey
        sign := math.sign(movey)
        for movey != 0 {
            rect := rl.Rectangle{f32(me.x), f32(me.y) + sign, f32(me.hitbox_size), f32(me.hitbox_size)}
            if !get_collisions(rect) {
                me.y += i32(sign)
                movey -= sign
            } else {
                break
            }
        }
    }
}