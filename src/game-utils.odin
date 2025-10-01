#+feature dynamic-literals
package main
import rl "vendor:raylib"

TileSprites: [TileType]rl.Texture
CardSprites: [ResourceType]rl.Texture

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

	CardSprites = {
		.WOOD  = rl.LoadTexture("resources/resources/vector/lumber.png"),
		.STONE = rl.LoadTexture("resources/resources/vector/ore.png"),
		.CLAY  = rl.LoadTexture("resources/resources/vector/brick.png"),
		.WHEAT = rl.LoadTexture("resources/resources/vector/grain.png"),
		.SHEEP = rl.LoadTexture("resources/resources/vector/wool.png"),
	}

  for &player in game.players {
    player.cards = { .WOOD, .WOOD, .WHEAT };
  }
}

delete_game :: proc(game: ^Game) {
  for tex in TileSprites do rl.UnloadTexture(tex);
  for tex in CardSprites do rl.UnloadTexture(tex);

  for &player in game.players {
    delete(player.cards)
  }
}


update_game :: proc(game: ^Game) {
	if rl.IsKeyPressed(.R) {
		gen_board(game)
	}
	if rl.IsKeyPressed(.SPACE) {
		roll_dice(game)
	}
}

draw_game :: proc(game: ^Game) {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)

	draw_board(game)
	draw_dice(game)
	draw_cards(game)
}
