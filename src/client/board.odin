package client
import "../common"
import "core:math"
import "core:fmt"
import rl "vendor:raylib"

draw_board :: proc(game: ^common.Game) {
	screen_center := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
	radius: f32 = f32(min(rl.GetScreenWidth(), rl.GetScreenHeight())) / 10
	padding: f32 : 0.05
	h := 2 * radius
	w := 2 * radius * math.cos_f32(math.PI / 6.0)


	draw_tiles(game, w, h, radius, padding, &screen_center)
	draw_pieces(game, w, h, radius, padding, &screen_center)
	draw_bought_hints(game, w, h, radius, padding, &screen_center)
}

draw_bought_hints :: proc(game: ^common.Game, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
	if bought_item == nil do return
	if current_player == nil do return

  draw_store_item(bought_item, rl.GetMousePosition(), 1, rl.Fade(current_player.color, 0.5))

	switch bought_item {
	case .CARD:
		return

	case .ROAD:
		draw_road_hints(game, w, h, radius, padding, screen_center)
	case .CITY:
		draw_city_hints(game, w, h, radius, padding, screen_center)
	case .SETTELMENT:
		draw_settelment_hints(game, w, h, radius, padding, screen_center)
	}
}

draw_pieces :: proc(game: ^common.Game, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
	// for edge, index in game.edges {
	//    if edge.obj.type == .NONE do continue;
	//
	//
	//  }
	for vertex, index in game.vertices {
		if vertex.obj.type == .NONE do continue

    fmt.println(index, vertex)
		tex := VertexSprites[auto_cast vertex.obj.type]
		scale := radius / f32(max(tex.width, tex.height)) / 1.5
		pos := pos_to_screen(vertex.pos, radius, screen_center)

		pos[0] -= scale * f32(tex.width) / 2
		pos[1] -= scale * f32(tex.height) / 2


    player := common.find_player_by_id(&game.players, vertex.obj.playerId)
    if (player != nil) do rl.DrawTextureEx(tex, pos, 0, scale, player.color);
	}

	// for edge, index in game.edges {
	// 	p0 := pos_to_screen(edge.vertices[0].pos, radius, &screen_center)
	// 	p1 := pos_to_screen(edge.vertices[1].pos, radius, &screen_center)
	// 	rl.DrawLineEx(p0, p1, 5, rl.RED)
	// 	rl.DrawText(rl.TextFormat("%i", index),
	//      auto_cast rl.Lerp(p0[0], p1[0], 0.5),
	//      auto_cast rl.Lerp(p0[1], p1[1], 0.5),
	//      5, rl.BLACK)
	// }
	//
	// for vertex, index in game.vertices {
	// 	pos := pos_to_screen(vertex.pos, radius, &screen_center)
	// 	rl.DrawCircle(auto_cast pos[0], auto_cast pos[1], 10, rl.WHITE)
	// 	rl.DrawText(rl.TextFormat("%i", index), auto_cast pos[0], auto_cast pos[1], 5, rl.RED)
	//
	// }
}
pos_to_screen := proc(pos: rl.Vector2, radius: f32, screen_center: ^rl.Vector2) -> rl.Vector2 {
	return rl.Vector2 {
		pos[0] * 2 * radius + screen_center[0],
		pos[1] * 2 * radius + screen_center[1],
	}
}

draw_tiles :: proc(game: ^common.Game, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
	screen_center := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
	for tile in game.tiles {
		tex := TileSprites[tile.type]
		scale := (1.0 - padding) * w / f32(tex.width)
		pos := pos_to_screen(tile.pos, radius, &screen_center)
		tex_pos := rl.Vector2{pos[0] - w / 2.0, pos[1] - h / 2.0}

		rl.DrawTextureEx(tex, tex_pos, 0, scale, rl.WHITE)

		if tile.type == .DESERT do continue

		rl.DrawCircleV(pos, radius / 3.5, rl.WHITE)
		text_spacing :: 0
		text_size := radius / 3
		text := rl.TextFormat("%d", tile.number)
		font := &MainFont

		chance := 6 - math.abs(i8(tile.number) - 7)
		color := rl.RED if chance == 5 else rl.BLACK

		text_measure := rl.MeasureTextEx(font^, text, text_size, text_spacing)
		text_pos := rl.Vector2{pos[0] - text_measure[0] / 2, pos[1] - text_measure[1] / 2}
		rl.DrawTextEx(font^, text, text_pos, text_size, text_spacing, color)
		dot_size := text_size / 10

		for dot_ind in 0 ..< chance {
			dot_pos := rl.Vector2 {
				pos[0] + 2 * dot_size * (f32(chance - 1) / 2.0 - f32(dot_ind)),
				text_pos[1] + text_measure[1],
			}
			rl.DrawCircleV(dot_pos, dot_size, color)
		}


		if tile.number == game.dice[0] + game.dice[1] {
			rl.DrawCircleLinesV(pos, 50, rl.BLACK)
		}
	}
}
