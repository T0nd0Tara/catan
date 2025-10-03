package main
import rl "vendor:raylib"

TILE_ROWS :: 5

ResourceType :: enum {
	WOOD  = auto_cast TileType.WOOD,
	STONE = auto_cast TileType.STONE,
	CLAY  = auto_cast TileType.CLAY,
	WHEAT = auto_cast TileType.WHEAT,
	SHEEP = auto_cast TileType.SHEEP,
}

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
	number:   u8, // 7 if type == .DESERT
}

Vertex :: struct {
	pos: rl.Vector2,
}

Edge :: struct {
	vertices: [2]^Vertex,
}

Card :: struct {
  type: ResourceType,
}
Player :: struct {
	cards: [dynamic]Card,
}

Game :: struct {
	tiles:    [19]Tile,
	vertices: [54]Vertex,
	edges:    [72]Edge,
	dice:     [2]u8,
	players:  [1]Player,
}
