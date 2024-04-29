package world

import rl "vendor:raylib"
import "core:fmt"

// Lists of entity procedures
init_procs := [Species]proc(x: i32, y: i32) -> Entity {
    .Item = item_init,
    .TestObj = testobj_init,
    .Frog = frog_init
}

update_procs := [Species]proc(me: ^Entity, delta: f32) {
    .Item = item_update,
    .TestObj = testobj_update,
    .Frog = frog_update
}

draw_procs := [Species]proc(me: ^Entity) {
    .Item = item_draw,
    .TestObj = testobj_draw,
    .Frog = frog_draw
}

die_procs := [Species]proc(me: ^Entity) -> bool {
    .Item = item_die,
    .TestObj = testobj_die,
    .Frog = frog_die
}

// ====================
// ENTITY BEHAVIOR DEFS
// ====================

// ----------------- ITEM -----------------
@(private="file")
item_init :: proc(x: i32, y: i32) -> Entity {
    edata := new(ItemData)
    edata.type = .BLOCK

    e := Entity{}
    e.x = x
    e.y = y
    e.species = .Item
    e.data = rawptr(edata)
    return e
}

@(private="file")
item_update :: proc(me: ^Entity, delta: f32) {
    data := cast(^ItemData)me.data
    data.age += 1
}

@(private="file")
item_draw :: proc(me: ^Entity) {
    rl.DrawCircle(me.x, me.y, 3, rl.RED)
}

@(private="file")
item_die :: proc(me: ^Entity) -> bool {
    return false
}

// ----------------- TESTOBJ -----------------
@(private="file")
testobj_init :: proc(x: i32, y: i32) -> Entity {
    edata := rawptr(new(EntityData))
    e := Entity{}
    e.x = x
    e.y = y
    e.species = .TestObj
    e.data = edata
    return e
}

@(private="file")
testobj_update :: proc(me: ^Entity, delta: f32) {
    moveX({&me.x, &me.y}, &me.rx, 3, delta)
}

@(private="file")
testobj_draw :: proc(me: ^Entity) {
    rl.DrawText("CREATURE", me.x, me.y, 10, rl.PURPLE)
}

@(private="file")
testobj_die :: proc(me: ^Entity) -> bool {
    return false
}

// ----------------- FROG -----------------
@(private="file")
frog_init :: proc(x: i32, y: i32) -> Entity {
    edata := new(FrogData)
    e := Entity{}
    e.x = x
    e.y = y
    e.species = .Frog
    edata.froginess = 5
    e.data = rawptr(edata)
    return e
}

@(private="file")
frog_update :: proc(me: ^Entity, delta: f32) {
    moveY({&me.x, &me.y}, &me.ry, 4, delta)
    moveX({&me.x, &me.y}, &me.rx, 2.5, delta)
}

@(private="file")
frog_draw :: proc(me: ^Entity) {
    frog := cast(^FrogData)me.data
    rl.DrawCircle(me.x, me.y, 4, rl.GREEN)
    rl.DrawCircle(me.x + frog.froginess, me.y - frog.froginess, 2, rl.RED)
}

@(private="file")
frog_die :: proc(me: ^Entity) -> bool {
    return false
}

// ====================
// TYPE DEFS
// ====================

ItemData :: struct {
    type: ItemType,
    age: u32
}

EntityData :: struct {

}

Direction :: enum {
    Up,
    Right,
    Down,
    Left
}

ItemType :: enum {
    NONE,
    BLOCK,
}

FrogData :: struct {
    froginess: i32,
    using entity: EntityData
}
