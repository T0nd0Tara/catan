package main
import rl "vendor:raylib"
import "core:fmt"

BuyingItem :: enum {
	SETTELMENT,
	CITY,
	ROAD,
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

buying_item_hover_animation : [BuyingItem]f32
buying_item_hover_animation_duaration: f32 = 0.2

draw_store :: proc(game: ^Game) {
	dt := rl.GetFrameTime()
	end_sprite := &BannerSprites[.END]
	mid_sprite := &BannerSprites[.MIDDLE]

	scale := 2 * f32(end_sprite.height) / f32(rl.GetScreenHeight())
	pos := rl.Vector2 {
		f32(rl.GetScreenWidth()) - f32(end_sprite.width) * scale,
		f32(rl.GetScreenHeight()) * 0.3,
	}

	item_size := f32(end_sprite.height) / 2 * scale
	item_margin : f32 = item_size / 5
	animation_x := rl.EaseQuadOut(
		store_drawer_animation,
		0,
		len(BuyingItem) * (item_size + item_margin) + item_margin,
		store_drawer_animation_duaration,
	)
	defer {
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

	pos[0] -= animation_x

	rl.DrawTextureEx(end_sprite^, pos, 0, scale, rl.WHITE)


	end_sprite_end_x := pos[0] + f32(end_sprite.width) * scale
	for x: f32 = end_sprite_end_x;
	    x < f32(rl.GetScreenWidth());
	    x += f32(mid_sprite.width) * scale {
		rl.DrawTextureEx(mid_sprite^, {x, pos[1]}, 0, scale, rl.WHITE)
	}

	for item, index in BuyingItem {
		x: f32 = end_sprite_end_x + item_margin + (item_size + item_margin) * f32(index)

		if x > f32(rl.GetScreenWidth()) do break
    if StoreSprites[item] == nil do continue

    item_animation := rl.EaseQuadOut(
      buying_item_hover_animation[item],
      1,
      0.3,
      buying_item_hover_animation_duaration,
    )
    item_pos : rl.Vector2 = {x - item_size * (item_animation - 1) / 2, pos[1] + item_margin - item_size * (item_animation - 1) / 2}
    current_item_size := item_size * item_animation
    tex := StoreSprites[item]
    defer {
      hover_rect: rl.Rectangle = {
        x      = item_pos[0],
        y      = item_pos[1],
        width  = current_item_size,
        height = current_item_size * f32(tex.height) / f32(tex.width),
      }

      collide := int(rl.CheckCollisionPointRec(rl.GetMousePosition(), hover_rect))

      buying_item_hover_animation[item] += f32(collide * 2 - 1) * dt

      buying_item_hover_animation[item] = clamp(buying_item_hover_animation[item], 0, buying_item_hover_animation_duaration)
    }

		rl.DrawTextureEx(tex^, item_pos, 0, current_item_size / f32(tex.width), rl.WHITE)
	}
}
