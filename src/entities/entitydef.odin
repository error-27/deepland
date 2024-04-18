package entities

import rl "vendor:raylib"
import "core:fmt"

// Lists of entity procedures
init_procs := [Species]proc(x: i32, y: i32) -> Entity {
    .TestObj = testobj_init,
    .Frog = frog_init
}

update_procs := [Species]proc(me: ^Entity, delta: f32) {
    .TestObj = testobj_update,
    .Frog = frog_update
}

draw_procs := [Species]proc(me: ^Entity) {
    .TestObj = testobj_draw,
    .Frog = frog_draw
}

die_procs := [Species]proc(me: ^Entity) -> bool {
    .TestObj = testobj_die,
    .Frog = frog_die
}

// ====================
// ENTITY BEHAVIOR DEFS
// ====================

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
    moveX(&me.x, &me.rx, 3, delta)
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
    moveY(&me.y, &me.ry, 4, delta)
    moveX(&me.x, &me.rx, 2.5, delta)
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

EntityData :: struct {

}

Direction :: enum {
    Up,
    Right,
    Down,
    Left
}

FrogData :: struct {
    froginess: i32,
    using entity: EntityData
}
