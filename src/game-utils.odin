package main
import rl "vendor:raylib"
TileSprites: [TileType]rl.Texture

init_game :: proc(game: ^Game) {
	init_board(game)
	gen_board(game)

	TileSprites = {
		.DESERT = rl.LoadTexture("resources/hexes/vector/desert.png"),
		.WOOD   = rl.LoadTexture("resources/hexes/vector/forest.png"),
		.STONE  = rl.LoadTexture("resources/hexes/vector/mountain.png"),
		.CLAY   = rl.LoadTexture("resources/hexes/vector/hill.png"),
		.WHEAT  = rl.LoadTexture("resources/hexes/vector/field.png"),
		.SHEEP  = rl.LoadTexture("resources/hexes/vector/pasture.png"),
	}

}


update_game :: proc(game: ^Game) {
	if rl.IsKeyPressed(.R) {
		gen_board(game)
	}
}

draw_game :: proc(game: ^Game) {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)

	draw_board(game)
}
