package save

import rl "vendor:raylib"

SaveFile :: struct {
    test: i32
}

load_save :: proc() -> SaveFile {
    return SaveFile{4} // placeholder. write the procedure correctly later
}