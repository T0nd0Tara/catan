#+feature dynamic-literals
package main
import rl "vendor:raylib"
import "core:strings"
import "core:fmt"

TileSprites: [TileType]rl.Texture
CardSprites: [ResourceType]rl.Texture

MainFont : rl.Font

init_game :: proc(game: ^Game) {
	init_board(game)
	gen_board(game)

  for type in TileType {
    type_name := fmt.aprintf("%v", type)
    TileSprites[type] = rl.LoadTexture(rl.TextFormat("resources/hexes/%s.png", 
        strings.to_lower(type_name)))
  }

  for type in ResourceType {
    type_name := fmt.aprintf("%v", type)
    CardSprites[type] = rl.LoadTexture(rl.TextFormat("resources/resources/%s.png", 
        strings.to_lower(type_name)))
  }

  MainFont = rl.LoadFontEx("resources/fonts/Beaver Punch.otf", 256, nil, 0)

  for &player in game.players {
    player.cards = { { .WOOD }, { .STONE }, { .WHEAT}, { .CLAY}, { .SHEEP} };
  }
}

delete_game :: proc(game: ^Game) {
  for tex in TileSprites do rl.UnloadTexture(tex);
  for tex in CardSprites do rl.UnloadTexture(tex);

  rl.UnloadFont(MainFont)

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

  dt := rl.GetFrameTime()
  fps := 1.0 / dt
  rl.DrawText(rl.TextFormat("dt: %f", dt), 0, 0, 20, rl.WHITE);
  rl.DrawText(rl.TextFormat("fps: %f", fps), 0, 30, 20, rl.WHITE);
}
