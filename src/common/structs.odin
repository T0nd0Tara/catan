package common
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

VertexObject :: struct {
	type:        enum {
		NONE,
		SETTELMENT = auto_cast BuyingItem.SETTELMENT,
		CITY = auto_cast BuyingItem.CITY,
	},
	playerId: int,
}

EdgeObject :: struct {
	type:        enum {
		NONE,
		ROAD = auto_cast BuyingItem.ROAD,
	},
	playerId: int,
}

Tile :: struct {
	type:     TileType,
	pos:      rl.Vector2,
	vertices: [6]int,
	number:   u8, // 7 if type == .DESERT
}

Vertex :: struct {
	pos: rl.Vector2,
	obj: VertexObject,
  vertices: [dynamic; 3]int, // between 2 - 3
}

Edge :: struct {
	vertices: [2]int,
	obj:      EdgeObject,
}

Card :: struct {
	type: ResourceType,
}
Player :: struct {
  id: int,
	cards: [dynamic]Card,
  color: rl.Color,
}

Game :: struct {
	tiles:    [19]Tile,
	vertices: [54]Vertex,
	edges:    [72]Edge,
	dice:     [2]u8,
	players:  [dynamic]Player,
	started:  bool,
}
