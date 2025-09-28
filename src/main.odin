package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Game :: struct {
}

init_game :: proc(game: ^Game) {

}


update_game :: proc(game: ^Game) {

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
  hex_scale : f32 = 0.9;

  w    := 2 * radius;
  h    := 2 * radius * math.cos_f32(math.PI / 6.0);
  side := 2 * radius * math.sin_f32(math.PI / 6.0);

  for x in -1 ..= 1 {
    col_height := 2 if x == 0 else 1;

    for y in -col_height ..= col_height {
      poly_center := screen_center;
      poly_center[0] += f32(x) * (w + side);
      poly_center[1] += f32(y) * h;
      rl.DrawPoly(poly_center, 6, radius * hex_scale, 0, rl.WHITE);
    }
  }

  for y in -1 ..= 2 {
    for x in 0..=1 {
      poly_center := screen_center;
      poly_center[0] += (f32(x) - 0.5) * (w + side);
      poly_center[1] += (f32(y) - 0.5) * h;
      rl.DrawPoly(poly_center, 6, radius * hex_scale, 0, rl.WHITE);
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
