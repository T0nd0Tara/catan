package main
import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

gen_board :: proc(game: ^Game) {
	max_amount_of_tile: [TileType]u8 = {
		TileType.DESERT = 1,
		TileType.STONE  = 3,
		TileType.CLAY   = 3,
		TileType.WOOD   = 4,
		TileType.WHEAT  = 4,
		TileType.SHEEP  = 4,
	}
	amount_of_tile: [TileType]u8


	desert_index := rand.choice([]int{4, 5, 8, 9, 10, 13, 14})
	gen_non_desert := proc() -> TileType {
		t := rand.int31_max(len(TileType) - 1)
		return TileType(t + 1)
	}

	for tile_index in 0 ..< len(game.tiles) {
		tile: TileType = gen_non_desert() if tile_index != desert_index else .DESERT
		for amount_of_tile[tile] >= max_amount_of_tile[tile] {
			tile = gen_non_desert()
		}

		game.tiles[tile_index].type = tile
		amount_of_tile[tile] += 1
	}

	init_board_numbers(game)
}
draw_board :: proc(game: ^Game) {
	screen_center := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
	radius: f32 = f32(min(rl.GetScreenWidth(), rl.GetScreenHeight())) / 10
	padding: f32 : 0.05
	h := 2 * radius
	w := 2 * radius * math.cos_f32(math.PI / 6.0)


	draw_tiles(game, w, h, radius, padding, &screen_center)
	draw_pieces(game, w, h, radius, padding, &screen_center)
	draw_bought_hints(game, w, h, radius, padding, &screen_center)
}

draw_bought_hints :: proc(game: ^Game, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
	if bought_item == nil do return

  draw_store_item(bought_item, rl.GetMousePosition(), 1, rl.Color{ 255, 255, 255, 128})

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

draw_pieces :: proc(game: ^Game, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
	// for edge, index in game.edges {
	//    if edge.obj.type == .NONE do continue;
	//
	//
	//  }
	for vertex, index in game.vertices {
		if vertex.obj.type == .NONE do continue

		tex := VertexSprites[auto_cast vertex.obj.type]
		scale := radius / f32(max(tex.width, tex.height)) / 1.5
		pos := pos_to_screen(vertex.pos, radius, screen_center)

		pos[0] -= scale * f32(tex.width) / 2
		pos[1] -= scale * f32(tex.height) / 2

		rl.DrawTextureEx(tex, pos, 0, scale, rl.WHITE)
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

draw_tiles :: proc(game: ^Game, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
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

init_board :: proc(game: ^Game) {
	cos30 := math.cos_f32(math.PI / 6.0)
	sin30 := math.sin_f32(math.PI / 6.0)

	h: f32 = 1.0
	w: f32 = h * cos30
	r := h / 2.0
	side := h * sin30
	{
		edge_index := 0
		first_tile_of_row := 0
		first_vertex_index := 0
		for row in 0 ..< TILE_ROWS {
			row_length := get_row_length(row)
			base: [6]int = ---
			will_taper := row >= TILE_ROWS / 2
			last_row := row == TILE_ROWS - 1
			defer first_tile_of_row += row_length
			defer first_vertex_index = int(base[3]) + int(will_taper)

			tapering: int = int(row > TILE_ROWS / 2)
			base = [6]int {
				first_vertex_index,
				first_vertex_index + row_length + tapering,
				first_vertex_index + row_length + 1 + tapering,
				first_vertex_index + 2 * row_length + 1 + tapering,
				first_vertex_index + 2 * row_length + 2 + tapering,
				first_vertex_index + 3 * row_length + 2 + tapering,
			}

			// edges
			for i in 0 ..< row_length {
				game.edges[edge_index].vertices = {
					&game.vertices[base[0] + i],
					&game.vertices[base[1] + i],
				}
				edge_index += 1

				game.edges[edge_index].vertices = {
					&game.vertices[base[0] + i],
					&game.vertices[base[2] + i],
				}
				edge_index += 1

				if last_row {
					game.edges[edge_index].vertices = {
						&game.vertices[base[3] + i],
						&game.vertices[base[5] + i],
					}
					edge_index += 1

					game.edges[edge_index].vertices = {
						&game.vertices[base[4] + i],
						&game.vertices[base[5] + i],
					}
					edge_index += 1
				}
			}

			for i in 0 ..= row_length {
				game.edges[edge_index].vertices = {
					&game.vertices[base[1] + i],
					&game.vertices[base[3] + i],
				}
				edge_index += 1
			}

			if will_taper && !last_row {
				game.edges[edge_index].vertices = {
					&game.vertices[base[3]],
					&game.vertices[base[5]],
				}
				edge_index += 1

				game.edges[edge_index].vertices = {
					&game.vertices[base[4] + row_length - 1],
					&game.vertices[base[5] + row_length - 1],
				}
				edge_index += 1
			}


			// tiles
			for i in 0 ..< row_length {
				tile := &game.tiles[first_tile_of_row + i]
				for vertex_index, index in base {
					tile.vertices[index] = &game.vertices[vertex_index + i]
				}
			}
		}
	}

	for edge1, edge1_ind in game.edges {
		for edge2 in game.edges[edge1_ind + 1:] {
			same_edge :=
				(edge1.vertices[0] == edge2.vertices[0] &&
					edge1.vertices[1] == edge2.vertices[1]) ||
				(edge1.vertices[0] == edge2.vertices[1] && edge1.vertices[1] == edge2.vertices[0])
			assert(!same_edge)
		}
	}

	{
		i: int = 0
		for y in 0 ..< TILE_ROWS {
			is_offset := y % 2 == 1
			row_length := get_row_length(y)

			even_offset: f32 = 0.5 if is_offset else 0

			for x in -(row_length - 1) / 2 ..= row_length / 2 {
				defer i += 1

				pos: rl.Vector2 = {(f32(x) - even_offset) * w, (f32(y) - 2) * (h + side) / 2}
				game.tiles[i].pos = pos

				// vertices order:
				//    0
				//  /  \
				// 1    2
				// |    |
				// 3    4
				//  \  /
				//   5
				vertices := game.tiles[i].vertices

				vertices[0].pos = {pos[0], pos[1] - r}
				vertices[5].pos = {pos[0], pos[1] + r}

				vertices[1].pos = {pos[0] - r * cos30, pos[1] - r * sin30}
				vertices[2].pos = {pos[0] + r * cos30, pos[1] - r * sin30}
				vertices[3].pos = {pos[0] - r * cos30, pos[1] + r * sin30}
				vertices[4].pos = {pos[0] + r * cos30, pos[1] + r * sin30}
			}
		}
	}

  for &edge in game.edges {
    assert(append_ptr(&edge.vertices[0].vertices, edge.vertices[1]))
    assert(append_ptr(&edge.vertices[1].vertices, edge.vertices[0]))
  }

	{
		for &vertex in game.vertices {
			vertex.obj.type = .NONE
		}

		game.vertices[10].obj.type = .SETTELMENT
		game.vertices[20].obj.type = .CITY
	}
  calculate_available_vertices_for_settelments(game);
}
init_board_numbers :: proc(game: ^Game) {
	fill_spiral :: proc(game: ^Game, row, col: int, board_numbers_index: int = 0) {

		board_numbers := [?]u8{5, 2, 6, 3, 8, 10, 9, 12, 11, 4, 8, 10, 9, 4, 5, 6, 3, 11}
		board_numbers_index := board_numbers_index

		spiral_indexes := [dynamic]int{}
		defer delete(spiral_indexes)

		for col_it in col ..< get_row_length(row) - col {
			append(&spiral_indexes, get_tile_index(row, col_it))
		}

		last_row_of_spiral := TILE_ROWS - row - 1

		for row_it in row + 1 ..= last_row_of_spiral {
			append(&spiral_indexes, get_tile_index(row_it, get_row_length(row_it) - col - 1))
		}

		for col_it := get_row_length(last_row_of_spiral) - col - 2; col_it > col; col_it -= 1 {
			append(&spiral_indexes, get_tile_index(last_row_of_spiral, col_it))
		}

		for row_it := last_row_of_spiral; row_it > row; row_it -= 1 {
			append(&spiral_indexes, get_tile_index(row_it, col))
		}

		for i in spiral_indexes {
			tile := &game.tiles[i]
			if tile.type == .DESERT do tile.number = 7
			else {
				tile.number = board_numbers[board_numbers_index]
				board_numbers_index += 1
			}
		}

		if (row < TILE_ROWS / 2) do fill_spiral(game, row + 1, col + 1, board_numbers_index)
	}


	fill_spiral(game, 0, 0)
}

get_row_of_tile :: proc(tile_index: int) -> int {
	past_tiles := -1
	for row_ind in 0 ..< TILE_ROWS {
		past_tiles += get_row_length(row_ind)
		if tile_index <= past_tiles do return row_ind
	}
	assert(false, "tile_index too big")
	return TILE_ROWS
}
get_row_length :: proc(row_index: int) -> int {
	return TILE_ROWS - math.abs(row_index - TILE_ROWS / 2)
}

get_tile_index :: proc(row, tile_index_in_row: int) -> int {
	prev_tiles := 0
	for row_it in 0 ..< row {
		prev_tiles += get_row_length(row_it)
	}

	return prev_tiles + tile_index_in_row
}

tile_has_right :: proc(tile_index: int) -> bool {
	past_tiles := -1
	for row_ind in 0 ..< TILE_ROWS {
		past_tiles += get_row_length(row_ind)
		if tile_index == past_tiles do return false
	}
	return true
}
