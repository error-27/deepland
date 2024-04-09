package entities

import rl "vendor:raylib"
import "core:fmt"

init_procs := [Species]proc(x: i32, y: i32) -> rawptr{
    .TestObj = testobj_init,
    .Frog = frog_init
}

update_procs := [Species]proc(me: rawptr, delta: f32){
    .TestObj = testobj_update,
    .Frog = frog_update
}

draw_procs := [Species]proc(me: rawptr){
    .TestObj = testobj_draw,
    .Frog = frog_draw
}

die_procs := [Species]proc(me: rawptr) -> bool{
    .TestObj = testobj_die,
    .Frog = testobj_die
}

// --------------------
// ENTITY BEHAVIOR DEFS
// --------------------

testobj_init :: proc(x: i32, y: i32) -> rawptr {
    e := new(Entity)
    e.x = x
    e.y = y
    return rawptr(e)
}

testobj_update :: proc(me: rawptr, delta: f32) {
    e := cast(^Entity)me
    moveX(&e.x, &e.rx, 3, delta)
}

testobj_draw :: proc(me: rawptr) {
    e := cast(^Entity)me
    rl.DrawText("CREATURE", e.x, e.y, 10, rl.PURPLE)
}

testobj_die :: proc(me: rawptr) -> bool {
    return false
}

frog_init :: proc(x: i32, y: i32) -> rawptr {
    e := new(Frog)
    e.x = x
    e.y = y
    e.froginess = 5
    return rawptr(e)
}

frog_update :: proc(me: rawptr, delta: f32) {
    e := cast(^Frog)me
    moveY(&e.y, &e.ry, 4, delta)
    moveX(&e.x, &e.rx, 2.5, delta)
}

frog_draw :: proc(me: rawptr) {
    frog := cast(^Frog)me
    rl.DrawCircle(frog.x, frog.y, 4, rl.GREEN)
    rl.DrawCircle(frog.x + frog.froginess, frog.y - frog.froginess, 2, rl.RED)
}