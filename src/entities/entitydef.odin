package entities

import rl "vendor:raylib"
import "core:fmt"

init_procs := [Species]proc() -> ^Entity{
    .TestObj = testobj_init,
    .Frog = frog_init
}

update_procs := [Species]proc(me: ^Entity, delta: f32){
    .TestObj = testobj_update,
    .Frog = frog_update
}

draw_procs := [Species]proc(me: ^Entity){
    .TestObj = testobj_draw,
    .Frog = frog_draw
}

die_procs := [Species]proc(me: ^Entity) -> bool{
    .TestObj = testobj_die,
    .Frog = testobj_die
}

// --------------------
// ENTITY BEHAVIOR DEFS
// --------------------

testobj_init :: proc() ->^Entity {
    return new(Entity)
}

testobj_update :: proc(me: ^Entity, delta: f32) {
    moveX(&me.x, &me.rx, 3, delta)
}

testobj_draw :: proc(me: ^Entity) {
    rl.DrawText("CREATURE", me.x, me.y, 10, rl.PURPLE)
}

testobj_die :: proc(me: ^Entity) -> bool {
    return false
}

frog_init :: proc() -> ^Entity {
    // frog := Frog{}
    // frog.froginess = 10
    return new(Frog)
}

frog_update :: proc(me: ^Entity, delta: f32) {
    moveY(&me.y, &me.ry, 4, delta)
    moveX(&me.x, &me.rx, 2.5, delta)
}

frog_draw :: proc(me: ^Entity) {
    frog := cast(^Frog)me
    rl.DrawCircle(frog.x, frog.y, 4, rl.GREEN)
    // rl.DrawCircle(frog.x + frog.froginess, frog.y - frog.froginess, 2, rl.RED)
}