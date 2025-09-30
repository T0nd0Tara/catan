package main
import rl "vendor:raylib"

TILE_ROWS :: 5

TileType :: enum {
	DESERT,
	WOOD,
	STONE,
	CLAY,
	WHEAT,
	SHEEP,
}

Tile :: struct {
	type:     TileType,
	pos:      rl.Vector2,
	vertices: [6]^Vertex,
	number:   i8, // 7 if type == .DESERT
}

Vertex :: struct {
	pos: rl.Vector2,
}

Edge :: struct {
	vertices: [2]^Vertex,
}

Game :: struct {
	tiles:    [19]Tile,
	vertices: [54]Vertex,
	edges:    [72]Edge,
}
