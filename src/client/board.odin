package client
import "../common"
import "core:math"
import "core:fmt"
import rl "vendor:raylib"

draw_board :: proc() {
	screen_center := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
	padding: f32 : 0.05
	radius: f32 = (1 - padding) * f32(min(rl.GetScreenWidth(), rl.GetScreenHeight())) / 10

	gap: f32 : 0.05
	h := 2 * radius
	w := 2 * radius * math.cos_f32(math.PI / 6.0)


	draw_tiles(w, h, radius, gap, &screen_center)
	draw_pieces(w, h, radius, gap, &screen_center)
	draw_bought_hints(w, h, radius, gap, &screen_center)
}

draw_bought_hints :: proc(w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
	if bought_item == nil do return

  draw_store_item(bought_item, rl.GetMousePosition(), 1, rl.Fade(current_player.color, 0.5))

	switch bought_item {
	case .CARD:
		return

	case .ROAD:
		draw_road_hints(w, h, radius, padding, screen_center)
	case .CITY:
		draw_city_hints(w, h, radius, padding, screen_center)
	case .SETTELMENT:
		draw_settelment_hints(w, h, radius, padding, screen_center)
	}
}

get_edge_side :: proc(edge: ^common.Edge) -> EdgeSide {
  v0 := &game.vertices[edge.vertices[0]]
  v1 := &game.vertices[edge.vertices[1]]
  diff := v1.pos - v0.pos
  if math.abs(diff.x) < 1e-5 do return .FRONT
  if math.sign(diff.y) != math.sign(diff.x) do return .LEFT
  return .RIGHT
}
draw_road :: proc(edge: ^common.Edge, radius: f32, tint: rl.Color, screen_center: ^rl.Vector2) {
  side := get_edge_side(edge)
  tex := PathSprites[side]
  scale : f32 = radius / f32(max(tex.width, tex.height)) / 1.2
  p0 := pos_to_screen(game.vertices[edge.vertices[0]].pos, radius, screen_center)
  p1 := pos_to_screen(game.vertices[edge.vertices[1]].pos, radius, screen_center)

  position : rl.Vector2 = { math.min(p0.x, p1.x), math.min(p0.y, p1.y) }

  rl.DrawTextureEx(tex, position, 0, scale, tint)
}
draw_pieces :: proc(w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
	// for edge, index in game.edges {
	//    if edge.obj.type == .NONE do continue;
	//
	//
	//  }
	for &vertex, index in game.vertices {
		if vertex.obj.type == .NONE do continue
		tex := VertexSprites[auto_cast vertex.obj.type]
		scale := radius / f32(max(tex.width, tex.height)) / 1.5
		pos := pos_to_screen(vertex.pos, radius, screen_center)

		pos[0] -= scale * f32(tex.width) / 2
		pos[1] -= scale * f32(tex.height) / 2


    player, _ := common.find_player_by_id(&game.players, vertex.obj.playerId)
    if (player != nil) do rl.DrawTextureEx(tex, pos, 0, scale, player.color);
	}

  for &edge, index in game.edges {
    if edge.obj.type == .NONE do continue

    player, _ := common.find_player_by_id(&game.players, edge.obj.playerId)
    if player == nil do continue
    if edge.obj.type == .ROAD {
      draw_road(&edge, radius, player.color, screen_center)
      continue
    }
  }

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

draw_tiles :: proc(w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
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
