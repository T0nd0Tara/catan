#+feature dynamic-literals
package client
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"
import "../common"
TileSprites: [common.TileType]rl.Texture
CardSprites: [common.ResourceType]rl.Texture

BannerSprites: [enum {
	END,
	MIDDLE,
}]rl.Texture

VertexOption :: enum {
	SETTELMENT = auto_cast common.BuyingItem.SETTELMENT,
	CITY       = auto_cast common.BuyingItem.CITY,
}
VertexSprites: #sparse[VertexOption]rl.Texture

StoreSprites: [common.BuyingItem]^rl.Texture

MainFont: rl.Font

init_assets :: proc() {

	for type in common.TileType {
		type_name := fmt.aprintf("%v", type)
		TileSprites[type] = rl.LoadTexture(
			rl.TextFormat("resources/hexes/%s.png", strings.to_lower(type_name)),
		)
	}

	for type in common.ResourceType {
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

	// for &player, i in game.players {
	// 	player.cards = {{.WOOD}, {.STONE}, {.WHEAT}, {.CLAY}, {.SHEEP}}
	//    player.color = rl.ColorFromHSV(auto_cast ((i * 70) % 360), 0.8, 1);
	// }

	StoreSprites[.SETTELMENT] = &VertexSprites[.SETTELMENT]
	StoreSprites[.CITY] = &VertexSprites[.CITY]
}

delete_assets :: proc() {
	for tex in TileSprites do rl.UnloadTexture(tex)
	for tex in CardSprites do rl.UnloadTexture(tex)
	for tex in BannerSprites do rl.UnloadTexture(tex)
	for tex in VertexSprites do rl.UnloadTexture(tex)

	rl.UnloadFont(MainFont)
}


update_game :: proc() {
	if rl.IsKeyPressed(.SPACE) {
		roll_dice(&game)
	}
  if rl.IsMouseButtonPressed(.RIGHT) {
   bought_item = nil 
  }
}

draw_game :: proc() {

	draw_board()
	draw_dice()
	draw_store()
	draw_cards()

  draw_oponents()
}
