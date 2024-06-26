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
    depth: i32,
    species: Species,
    data: rawptr,
    hitbox_size: u32
}

entities: [dynamic]Entity // The current array of entities

// Procedures for managing and updating entities
create_entity :: proc(x: i32, y: i32, depth: i32, species: Species) -> int {
    e := init_procs[species](x, y)
    e.cx = i32(math.floor(f32(x) / 256))
    e.cy = i32(math.floor(f32(y) / 256))
    e.depth = depth
    append(&entities, e)
    return len(&entities) - 1 // index of this entity. good for extensions to this procedure
}

create_item :: proc(x: i32, y: i32, depth: i32, type: ItemType) {
    i := create_entity(x, y, depth, .Item)
    data := cast(^ItemData)entities[i].data
    entities[i].x += i32(rl.GetRandomValue(0, 15))
    entities[i].y += i32(rl.GetRandomValue(0, 15))
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
        if e.cx < plr.cx -1 || e.cx > plr.cx + 1 || e.cy < plr.cy -1 || e.cy > plr.cy + 1 || e.depth != plr.depth {
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
        if entities[i].depth != plr.depth {
            continue
        }
        e := &entities[i]
        draw_procs[e.species](e)
    }
}

is_entity_colliding :: proc{is_entity_colliding_entity, is_entity_colliding_rect}

is_entity_colliding_entity :: proc(me: ^Entity) -> bool {
    rect := rl.Rectangle{f32(me.x), f32(me.y), f32(me.hitbox_size), f32(me.hitbox_size)}

    for i in 0..<len(entities) {
        if &entities[i] == me {
            continue // skip itself in the entity list
        }
        
        if rl.CheckCollisionRecs(rect, {f32(entities[i].x), f32(entities[i].y), f32(entities[i].hitbox_size), f32(entities[i].hitbox_size)}) {
            return true
        }
    }
    return false
}

is_entity_colliding_rect :: proc(rect: rl.Rectangle) -> bool {
    for e in entities {
        if rl.CheckCollisionRecs(rect, {f32(e.x), f32(e.y), f32(e.hitbox_size), f32(e.hitbox_size)}) {
            return true
        }
    }
    return false
}

// Utility procedures for moving entities
move_x :: proc(me: ^Entity, speed: f32, delta: f32) {
    me.rx += speed * delta
    movex := math.round_f32(me.rx)
    if movex != 0 {
        me.rx -= movex
        sign := math.sign(movex)
        for movex != 0 {
            rect := rl.Rectangle{f32(me.x) + sign, f32(me.y), f32(me.hitbox_size), f32(me.hitbox_size)}
            if !is_tile_colliding(rect, me.depth) {
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
            if !is_tile_colliding(rect, me.depth) {
                me.y += i32(sign)
                movey -= sign
            } else {
                break
            }
        }
    }
}