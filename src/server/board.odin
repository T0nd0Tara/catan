package server
import "../common"
import "core:math/rand"
import "core:math"
import rl "vendor:raylib"


gen_board :: proc() {
	max_amount_of_tile: [common.TileType]u8 = {
		common.TileType.DESERT = 1,
		common.TileType.STONE  = 3,
		common.TileType.CLAY   = 3,
		common.TileType.WOOD   = 4,
		common.TileType.WHEAT  = 4,
		common.TileType.SHEEP  = 4,
	}
	amount_of_tile: [common.TileType]u8


	desert_index := rand.choice([]int{4, 5, 8, 9, 10, 13, 14})
	gen_non_desert := proc() -> common.TileType {
		t := rand.int31_max(len(common.TileType) - 1)
		return common.TileType(t + 1)
	}

	for tile_index in 0 ..< len(game.tiles) {
		tile: common.TileType = gen_non_desert() if tile_index != desert_index else .DESERT
		for amount_of_tile[tile] >= max_amount_of_tile[tile] {
			tile = gen_non_desert()
		}

		game.tiles[tile_index].type = tile
		amount_of_tile[tile] += 1
	}

	init_board_numbers()
}

init_board :: proc() {
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
		for row in 0 ..< common.TILE_ROWS {
			row_length := get_row_length(row)
			base: [6]int = ---
			will_taper := row >= common.TILE_ROWS / 2
			last_row := row == common.TILE_ROWS - 1
			defer first_tile_of_row += row_length
			defer first_vertex_index = int(base[3]) + int(will_taper)

			tapering: int = int(row > common.TILE_ROWS / 2)
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
		for y in 0 ..< common.TILE_ROWS {
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
    assert(common.append_ptr(&edge.vertices[0].vertices, edge.vertices[1]))
    assert(common.append_ptr(&edge.vertices[1].vertices, edge.vertices[0]))
  }

	{
		for &vertex in game.vertices {
			vertex.obj.type = .NONE
		}
	}
}
init_board_numbers :: proc() {
	fill_spiral :: proc(row, col: int, board_numbers_index: int = 0) {

		board_numbers := [?]u8{5, 2, 6, 3, 8, 10, 9, 12, 11, 4, 8, 10, 9, 4, 5, 6, 3, 11}
		board_numbers_index := board_numbers_index

		spiral_indexes := [dynamic]int{}
		defer delete(spiral_indexes)

		for col_it in col ..< get_row_length(row) - col {
			append(&spiral_indexes, get_tile_index(row, col_it))
		}

		last_row_of_spiral := common.TILE_ROWS - row - 1

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

		if (row < common.TILE_ROWS / 2) do fill_spiral(row + 1, col + 1, board_numbers_index)
	}


	fill_spiral(0, 0)
}

get_row_of_tile :: proc(tile_index: int) -> int {
	past_tiles := -1
	for row_ind in 0 ..< common.TILE_ROWS {
		past_tiles += get_row_length(row_ind)
		if tile_index <= past_tiles do return row_ind
	}
	assert(false, "tile_index too big")
	return common.TILE_ROWS
}
get_row_length :: proc(row_index: int) -> int {
	return common.TILE_ROWS - math.abs(row_index - common.TILE_ROWS / 2)
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
	for row_ind in 0 ..< common.TILE_ROWS {
		past_tiles += get_row_length(row_ind)
		if tile_index == past_tiles do return false
	}
	return true
}
