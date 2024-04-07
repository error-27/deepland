package entities

import rl "vendor:raylib"
import "core:math"

Entity :: struct {
    x: i32,
    y: i32,
    rx: f32,
    ry: f32,
    species: Species,
    update: proc(me: ^Entity, delta: f32),
    draw: proc(me: ^Entity)
}

Species :: enum {
    TestObj
}

Direction :: enum {
    Up,
    Right,
    Down,
    Left
}

entities: [dynamic]Entity

create :: proc(x: i32, y: i32, species: Species) -> int {
    e := Entity{x, y, 0, 0, species, nil, nil}
    e.update = testobj_update
    e.draw = testobj_draw
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
        e := &entities[i]
        // }
        e.update(e, delta)
    }
}

draw :: proc() {
    for i in 0..<len(entities) {
        e := &entities[i]
        e.draw(e)
    }
}

testobj_update :: proc(me: ^Entity, delta: f32) {
    moveX(&me.x, &me.rx, 3, delta)
}

testobj_draw :: proc(me: ^Entity) {
    rl.DrawText("THIS IS A LITTLE GUY", me^.x, me^.y, 10, rl.PURPLE)
}