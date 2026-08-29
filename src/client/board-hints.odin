package client
import rl "vendor:raylib"
import "../common"

available_vertices_for_settelments := [dynamic]^common.Vertex{};
calculate_available_vertices_for_settelments :: proc(game: ^common.Game) {
  clear(&available_vertices_for_settelments);
  MAIN_LOOP: for &vertex in game.vertices {
    if vertex.obj.type != .NONE do continue;
    for neighbor in vertex.vertices {
      if neighbor == nil do continue;
      if neighbor.obj.type != .NONE do continue MAIN_LOOP;
    }
    
    append(&available_vertices_for_settelments, &vertex)
  }

}

draw_road_hints :: proc(game: ^common.Game, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
}

draw_city_hints :: proc(game: ^common.Game, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
}

draw_settelment_hints :: proc(
	game: ^common.Game,
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
      vertex.obj = { type = .SETTELMENT, player = common.current_player(game) };
      calculate_available_vertices_for_settelments(game);
    }
	} 
}
