#+feature dynamic-literals
package main
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"
TileSprites: [TileType]rl.Texture
CardSprites: [ResourceType]rl.Texture

BannerSprites: [enum {
	END,
	MIDDLE,
}]rl.Texture

VertexOption :: enum {
	SETTELMENT = auto_cast BuyingItem.SETTELMENT,
	CITY       = auto_cast BuyingItem.CITY,
}
VertexSprites: #sparse[VertexOption]rl.Texture

StoreSprites: [BuyingItem]^rl.Texture

MainFont: rl.Font

init_game :: proc(game: ^Game) {
	init_board(game)
	gen_board(game)

	for type in TileType {
		type_name := fmt.aprintf("%v", type)
		TileSprites[type] = rl.LoadTexture(
			rl.TextFormat("resources/hexes/%s.png", strings.to_lower(type_name)),
		)
	}

	for type in ResourceType {
		type_name := fmt.aprintf("%v", type)
		CardSprites[type] = rl.LoadTexture(
			rl.TextFormat("resources/resources/%s.png", strings.to_lower(type_name)),
		)
	}

	for _, type in BannerSprites {
		type_name := fmt.aprintf("%v", type)
		BannerSprites[type] = rl.LoadTexture(
			rl.TextFormat("resources/banner/banner-%s.png", strings.to_lower(type_name)),
		)
	}

	for type in VertexOption {
		type_name := fmt.aprintf("%v", type)
		VertexSprites[type] = rl.LoadTexture(
			rl.TextFormat("resources/pieces/%s.png", strings.to_lower(type_name)),
		)
	}

	MainFont = rl.LoadFontEx("resources/fonts/Beaver Punch.otf", 256, nil, 0)

	for &player in game.players {
		player.cards = {{.WOOD}, {.STONE}, {.WHEAT}, {.CLAY}, {.SHEEP}}
	}

	StoreSprites[.SETTELMENT] = &VertexSprites[.SETTELMENT]
	StoreSprites[.CITY] = &VertexSprites[.CITY]
}

delete_game :: proc(game: ^Game) {
	for tex in TileSprites do rl.UnloadTexture(tex)
	for tex in CardSprites do rl.UnloadTexture(tex)
	for tex in BannerSprites do rl.UnloadTexture(tex)
	for tex in VertexSprites do rl.UnloadTexture(tex)

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
	draw_store(game)
	draw_cards(game)

	dt := rl.GetFrameTime()
	fps := 1.0 / dt
	rl.DrawText(rl.TextFormat("dt: %f", dt), 0, 0, 20, rl.WHITE)
	rl.DrawText(rl.TextFormat("fps: %f", fps), 0, 30, 20, rl.WHITE)
}
