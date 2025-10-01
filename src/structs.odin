package main
import rl "vendor:raylib"

TILE_ROWS :: 5

ResourceType :: enum {
	WOOD,
	STONE,
	CLAY,
	WHEAT,
	SHEEP,
}

TileType :: enum {
	WOOD = auto_cast ResourceType.WOOD,
	STONE = auto_cast ResourceType.STONE,
	CLAY = auto_cast ResourceType.CLAY,
	WHEAT = auto_cast ResourceType.WHEAT,
	SHEEP = auto_cast ResourceType.SHEEP,
	DESERT,
}


Tile :: struct {
	type:     TileType,
	pos:      rl.Vector2,
	vertices: [6]^Vertex,
	number:   u8, // 7 if type == .DESERT
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
	dice:     [2]u8,
}
