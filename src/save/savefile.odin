package save

import rl "vendor:raylib"
import "../world"

SaveFile :: struct {
    chunks: ^[dynamic]world.Chunk
}

load_save :: proc() -> SaveFile {
    return SaveFile{} // placeholder. write the procedure correctly later
}

save_game :: proc(file: string, data: SaveFile) -> bool {
    return false
}