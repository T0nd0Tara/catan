package main

import rl "vendor:raylib"


main :: proc() {
  rl.SetConfigFlags({rl.ConfigFlag.WINDOW_RESIZABLE, rl.ConfigFlag.MSAA_4X_HINT})
	rl.InitWindow(1280, 720, "Catan")
	defer rl.CloseWindow()
	game: Game = ---
	init_game(&game)
  defer delete_game(&game)

	rl.SetTargetFPS(120)

	for !rl.WindowShouldClose() {
		update_game(&game)
		draw_game(&game)
	}
}
