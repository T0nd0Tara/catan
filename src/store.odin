package main
import rl "vendor:raylib"

BuyingItem :: enum {
	ROAD,
	SETTELMENT,
	CITY,
	CARD,
}

costs: [BuyingItem][5]ResourceType = {
	.ROAD       = {.WOOD, .CLAY, nil, nil, nil},
	.SETTELMENT = {.WOOD, .CLAY, .SHEEP, .WHEAT, nil},
	.CITY       = {.STONE, .STONE, .STONE, .WHEAT, .WHEAT},
	.CARD       = {.STONE, .SHEEP, .WHEAT, nil, nil},
}

store_drawer_animation: f32 = 0
store_drawer_animation_duaration: f32 = 0.4

draw_store :: proc(game: ^Game) {
	dt := rl.GetFrameTime()
	end_sprite := &BannerSprites[.END]
	mid_sprite := &BannerSprites[.MIDDLE]

	scale := 2 * f32(end_sprite.height) / f32(rl.GetScreenHeight())
	pos := rl.Vector2 {
		f32(rl.GetScreenWidth()) - f32(end_sprite.width) * scale,
		f32(rl.GetScreenHeight()) * 0.3,
	}

	animation_x := rl.EaseQuadOut(
		store_drawer_animation,
		0,
		len(BuyingItem) * f32(end_sprite.height) * scale,
		store_drawer_animation_duaration,
	)

	pos[0] -= animation_x

	rl.DrawTextureEx(end_sprite^, pos, 0, scale, rl.WHITE)


	for x: f32 = pos[0] + f32(end_sprite.width) * scale;
	    x < f32(rl.GetScreenWidth());
	    x += f32(mid_sprite.width) * scale {
		rl.DrawTextureEx(mid_sprite^, {x, pos[1]}, 0, scale, rl.WHITE)

	}

	hover_rect: rl.Rectangle = {
		x      = pos[0],
		y      = pos[1],
		width  = f32(rl.GetScreenWidth()) - pos[0],
		height = f32(end_sprite.height),
	}

	collide := int(rl.CheckCollisionPointRec(rl.GetMousePosition(), hover_rect))

	store_drawer_animation += f32(collide * 2 - 1) * dt

	store_drawer_animation = clamp(store_drawer_animation, 0, store_drawer_animation_duaration)

}
