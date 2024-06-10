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
    edata.type = .WOOD

    e := Entity{}
    e.x = x
    e.y = y
    e.species = .Item
    e.data = rawptr(edata)
    e.hitbox_size = 5
    return e
}

@(private="file")
item_update :: proc(me: ^Entity, delta: f32) {
    data := cast(^ItemData)me.data
    if rl.CheckCollisionRecs({f32(me.x), f32(me.y), f32(me.hitbox_size), f32(me.hitbox_size)}, plr_get_rectangle()) {
        data.collected = plr_collect_item(data.type)
    }
}

@(private="file")
item_draw :: proc(me: ^Entity) {
    data := cast(^ItemData)me.data
    switch data.type {
        case .NONE:
            rl.DrawCircle(me.x, me.y, 3, rl.MAGENTA)
        case .WOOD:
            rl.DrawRectangle(me.x, me.y, 6, 6, rl.BROWN)
        case .STONE:
            rl.DrawRectangle(me.x, me.y, 6, 6, rl.GRAY)
    }
}

@(private="file")
item_die :: proc(me: ^Entity) -> bool {
    data := cast(^ItemData)me.data
    return data.collected
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
    e.hitbox_size = 16
    return e
}

@(private="file")
testobj_update :: proc(me: ^Entity, delta: f32) {
    move_x(me, 3, delta)
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
    move_y(me, 4, delta)
    move_x(me, 2.5, delta)
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
    collected: bool
}

EntityData :: struct {

}

Direction :: enum {
    Up,
    Right,
    Down,
    Left
}

DirVecs := [Direction][2]i32 {
    .Up = {0, -1},
    .Down = {0, 1},
    .Left = {-1, 0},
    .Right = {1, 0}
}

ItemType :: enum {
    NONE,
    WOOD,
    STONE
}

FrogData :: struct {
    froginess: i32,
    using entity: EntityData
}
