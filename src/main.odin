package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"
import "core:strconv"
import rl "vendor:raylib"

TileType :: enum {
  DESERT,
  WOOD,
  STONE,
  CLAY,
  WHEAT,
  SHEEP,
}

TILE_ROWS :: 5;

TileSprites : [TileType]rl.Texture;
Tile :: struct {
  type : TileType,
  pos: rl.Vector2,
  vertices_indices: [6]u8,
}

Vertex :: struct {
  pos: rl.Vector2,
}

Game :: struct {
  tiles : [19]Tile,
  vertices: [54]Vertex,
}
init_board :: proc(game: ^Game) {
  cos30 := math.cos_f32(math.PI / 6.0);
  sin30 := math.sin_f32(math.PI / 6.0);

  h : f32 = 1.0;
  w : f32 = h * cos30;
  r := h / 2.0;
  side := h * sin30;
  {

    first_tile_of_row := 0;
    first_vertex_index := 0;
    for row in 0..<TILE_ROWS {
      row_length := get_row_length(row);
      base : [6]u8 = ---;
      defer first_tile_of_row += row_length;
      defer first_vertex_index = int(base[3]) + int(row >= TILE_ROWS / 2);

      tapering : int = int(row > TILE_ROWS / 2);
      base = [6]u8{
        auto_cast first_vertex_index, 
        auto_cast (first_vertex_index + row_length + tapering), 
        auto_cast (first_vertex_index + row_length + 1 + tapering),
        auto_cast (first_vertex_index + 2 * row_length + 1 + tapering),
        auto_cast (first_vertex_index + 2 * row_length + 2 + tapering),
        auto_cast (first_vertex_index + 3 * row_length + 2 + tapering),
      };

      for i in 0..<row_length {
        tile := &game.tiles[first_tile_of_row + i];
        tile.vertices_indices = base;
        for &vertex in tile.vertices_indices do vertex += auto_cast i;
      }
    }
  }

  {
    i : int = 0;
    for y in 0..<TILE_ROWS {
      is_offset := y % 2 == 1;
      row_length := get_row_length(y);

      even_offset :f32= 0.5 if is_offset else 0;

      for x in -(row_length - 1) / 2..=row_length / 2 {
        defer i += 1;

        pos : rl.Vector2 = {(f32(x) - even_offset) * w, (f32(y) - 2) * (h + side) / 2}
        game.tiles[i].pos = pos;
        
        // vertices order:
        //    0
        //  /  \
        // 1    2
        // |    |
        // 3    4
        //  \  /
        //   5
        vertices := game.tiles[i].vertices_indices;
        
        game.vertices[vertices[0]].pos = { pos[0], pos[1] - r};
        game.vertices[vertices[5]].pos = { pos[0], pos[1] + r};

        game.vertices[vertices[1]].pos = { pos[0] - r * cos30, pos[1] - r * sin30};
        game.vertices[vertices[2]].pos = { pos[0] + r * cos30, pos[1] - r * sin30};
        game.vertices[vertices[3]].pos = { pos[0] - r * cos30, pos[1] + r * sin30};
        game.vertices[vertices[4]].pos = { pos[0] + r * cos30, pos[1] + r * sin30};
      }
    }
  }
}
gen_board :: proc(game: ^Game) {
  max_amount_of_tile : [TileType]u8 = {
    TileType.DESERT = 1,
    TileType.STONE  = 3,
    TileType.CLAY   = 3,
    TileType.WOOD   = 4,
    TileType.WHEAT  = 4,
    TileType.SHEEP  = 4,
  };
  amount_of_tile: [TileType]u8;


  desert_index := rand.choice([]int{4,5,8,9,10,13,14});
  gen_non_desert := proc() -> TileType {
    t := rand.int31_max(len(TileType) - 1);
    return TileType(t + 1);
  }

  for tile_index in 0..<len(game.tiles) {
    tile : TileType = gen_non_desert() if tile_index != desert_index else .DESERT;
    for amount_of_tile[tile] >= max_amount_of_tile[tile] {
      tile = gen_non_desert();
    }

    game.tiles[tile_index].type = tile;
    amount_of_tile[tile] += 1;
  }
}
get_row_of_tile :: proc(tile_index: int) -> int {
  past_tiles := -1;
  for row_ind in 0..<TILE_ROWS {
    past_tiles += get_row_length(row_ind);
    if  tile_index <= past_tiles do return row_ind;
  }
  assert(false, "tile_index too big");
  return TILE_ROWS;
}
get_row_length :: proc(row_index: int) -> int {
  return TILE_ROWS - math.abs(row_index - TILE_ROWS / 2);
}
tile_has_right :: proc(tile_index: int) -> bool {
  past_tiles := -1;
  for row_ind in 0..<TILE_ROWS {
    past_tiles += get_row_length(row_ind);
    if  tile_index == past_tiles do return false;
  }
  return true;
}

init_game :: proc(game: ^Game) {
  init_board(game);
  gen_board(game);

  TileSprites = {
    .DESERT = rl.LoadTexture("resources/hexes/vector/desert.png"),
    .WOOD = rl.LoadTexture("resources/hexes/vector/forest.png"),
    .STONE = rl.LoadTexture("resources/hexes/vector/mountain.png"),
    .CLAY = rl.LoadTexture("resources/hexes/vector/hill.png"),
    .WHEAT = rl.LoadTexture("resources/hexes/vector/field.png"),
    .SHEEP = rl.LoadTexture("resources/hexes/vector/pasture.png"),
  };

}


update_game :: proc(game: ^Game) {
  if rl.IsKeyPressed(.R) {
    gen_board(game);
  }
}

draw_game :: proc(game: ^Game) {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK);

  draw_board(game);
}

get_hex_pos :: proc(
  x, y: int,
  w, h, side : f32,
  x_offset: f32,
  screen_center: rl.Vector2
  ) -> rl.Vector2 {
    poly_center := screen_center;
    return poly_center;
}
draw_board :: proc(game: ^Game) {
  screen_center := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)};
  radius : f32 = 80;
  h    := 2 * radius;
  w    := 2 * radius * math.cos_f32(math.PI / 6.0);

  pos_to_screen := proc(pos: rl.Vector2, radius: f32, screen_center: ^rl.Vector2) -> rl.Vector2{
    return rl.Vector2{pos[0] * 2 * radius + screen_center[0], pos[1] * 2 * radius + screen_center[1]};
  }

  for tile in game.tiles {
      tex := TileSprites[tile.type];
      scale := w / f32(tex.width);
      pos := pos_to_screen(tile.pos, radius, &screen_center);
      pos[0] -= w / 2.0;
      pos[1] -= h / 2.0;

      rl.DrawTextureEx(tex, pos, 0, scale, rl.WHITE);
  }

  // vertices
  for vertex, index in game.vertices {
    pos := pos_to_screen(vertex.pos, radius, &screen_center);
    rl.DrawCircle(auto_cast pos[0], auto_cast pos[1], 10, rl.WHITE);
    rl.DrawText(rl.TextFormat("%i", index), auto_cast pos[0], auto_cast pos[1], 5, rl.RED);
    
  }
}
main :: proc() {
	rl.InitWindow(1280, 720, "Catan")
  defer rl.CloseWindow();
  game : Game = ---;
  init_game(&game);

	rl.SetTargetFPS(60)      

  for !rl.WindowShouldClose() {
    update_game(&game);
    draw_game(&game);
  }
}
