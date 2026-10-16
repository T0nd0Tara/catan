package client
import rl "vendor:raylib"
import "../common"

available_vertices_for_settelments := [dynamic]^common.Vertex{};
available_edges_for_roads := [dynamic]^common.Edge{};

is_connected_to_player_vertex :: proc(edge: ^common.Edge) -> bool {
  for vertex_idx in edge.vertices {
    vertex := &game.vertices[vertex_idx]
    if vertex.obj.type != .NONE && vertex.obj.playerId == current_player.id do return true
  }
  return false
}
is_connected_to_player_road :: proc(edge: ^common.Edge) -> bool {
  for vertex_idx in edge.vertices {
    vertex := &game.vertices[vertex_idx]
    for &neighbor_idx in vertex.edges {
      neighbor := &game.edges[neighbor_idx]
      if neighbor == edge do continue
      if neighbor.obj.type != .NONE && neighbor.obj.playerId == current_player.id do return true
    }
  }
  return false
}
calculate_available_placement_locations :: proc() {
  clear(&available_vertices_for_settelments);

  MAIN_VERTEX_LOOP: for &vertex in game.vertices {
    if vertex.obj.type != .NONE do continue;
    for neighbor_idx in vertex.vertices {
      if game.vertices[neighbor_idx].obj.type != .NONE do continue MAIN_VERTEX_LOOP;
    }
    
    append(&available_vertices_for_settelments, &vertex)
  }

  clear(&available_edges_for_roads);
  for &edge in game.edges {
    if edge.obj.type != .NONE do continue
    if is_connected_to_player_vertex(&edge) || is_connected_to_player_road(&edge) {
      append(&available_edges_for_roads, &edge)
    }
  }
}

draw_road_hints :: proc(w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
  thickness := radius / 8.0
  margin_percentage : f32 = 0.3

  mouse_pos := rl.GetMousePosition();

  for edge in available_edges_for_roads {
    // draw_road(edge, radius, rl.Fade(current_player.color, 0.8), screen_center)
    v0_pos : rl.Vector2 = pos_to_screen(game.vertices[edge.vertices[0]].pos, radius, screen_center)
    v1_pos : rl.Vector2 = pos_to_screen(game.vertices[edge.vertices[1]].pos, radius, screen_center)

    margin : rl.Vector2 = (v1_pos - v0_pos) * margin_percentage    
    start_pos := v0_pos + margin
    end_pos   := v1_pos - margin
    hover := rl.CheckCollisionPointLine(mouse_pos, start_pos, end_pos, i32(thickness))
    if (hover) {
      draw_road(edge, radius, rl.Fade(current_player.color, 0.8), screen_center)
      if (rl.IsMouseButtonPressed(.LEFT)) {
        bought_item = nil;
        edge.obj = { type = .ROAD, playerId = current_player.id };
        calculate_available_placement_locations();
      }
    } else {
      rl.DrawLineEx(start_pos, end_pos, thickness, rl.WHITE)
    }
    
  }
}

draw_city_hints :: proc(w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
}

draw_settelment_hints :: proc(
	w, h, radius, padding: f32,
	screen_center: ^rl.Vector2,
) {

  vertex_radius := radius / 8.0

  mouse_pos := rl.GetMousePosition();

	for vertex in available_vertices_for_settelments {
		pos := pos_to_screen(vertex.pos, radius, screen_center)
    selected := rl.CheckCollisionPointCircle(pos, mouse_pos, vertex_radius);
    color := selected ? rl.RED : rl.WHITE
		rl.DrawCircleV(pos, vertex_radius, color)
    if selected && rl.IsMouseButtonPressed(.LEFT) {
      bought_item = nil;
      vertex.obj = { type = .SETTELMENT, playerId = current_player.id };
      calculate_available_placement_locations();
    }
	} 
}
