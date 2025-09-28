package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

TileType :: enum {
  DESERT,
  WOOD,
  STONE,
  CLAY,
  WHEAT,
  SHEEP,
}

TileSprites : [len(TileType)]rl.Texture;
Tile :: struct {
  type : TileType,

}
Game :: struct {
  tiles : [19]Tile,
}
gen_board :: proc(game: ^Game) {
  max_amount_of_tile : [TileType]u8 = ---; 
  amount_of_tile: [TileType]u8;

  max_amount_of_tile[TileType.DESERT] = 1;
  max_amount_of_tile[TileType.WOOD]   = 4;
  max_amount_of_tile[TileType.STONE]  = 3;
  max_amount_of_tile[TileType.CLAY]   = 3;
  max_amount_of_tile[TileType.WHEAT]  = 4;
  max_amount_of_tile[TileType.SHEEP]  = 4;

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
init_game :: proc(game: ^Game) {
  gen_board(game);

  TileSprites = {
    rl.LoadTexture("resources/hexes/vector/desert.png"),
    rl.LoadTexture("resources/hexes/vector/forest.png"),
    rl.LoadTexture("resources/hexes/vector/mountain.png"),
    rl.LoadTexture("resources/hexes/vector/hill.png"),
    rl.LoadTexture("resources/hexes/vector/field.png"),
    rl.LoadTexture("resources/hexes/vector/pasture.png"),
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

draw_board :: proc(game: ^Game) {
  screen_center := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)};
  radius : f32 = 80;

  h    := 2 * radius;
  w    := 2 * radius * math.cos_f32(math.PI / 6.0);
  side := 2 * radius * math.sin_f32(math.PI / 6.0);

  c : rl.Color = { 255, 255, 255, 120 };

  i : int = 0;
  for y in 0..<5 {
    is_offset := y % 2 == 1;
    row_length := 5 - math.abs(y - 2);

    even_offset :f32= 0.5 if is_offset else 0;

    for x in -(row_length - 1) / 2..=row_length / 2 {
      defer i += 1;


      tex := TileSprites[u8(game.tiles[i].type)];
      scale := w / f32(tex.width);

      poly_center := screen_center;
      poly_center[0] += (f32(x) - even_offset) * w;
      poly_center[0] -= w / 2.0;

      poly_center[1] += (f32(y) - 2) * (h + side) / 2;
      poly_center[1] -= h / 2.0;

      rl.DrawTextureEx(tex, poly_center, 0, scale, rl.WHITE);
      

    }
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
