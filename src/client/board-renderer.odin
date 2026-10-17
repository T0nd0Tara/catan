package client
import rl "vendor:raylib"
import "../common/"

// A structure to keep track of everything that needs rendering on the board, so it can be manipulated mid-frame

board_renderer : struct {
  vertices: [12][dynamic; 6]^common.Vertex,
  edges: [11][dynamic; 10]^common.Edge,
};

@(private="file")
draw_vertices :: proc(vertices: ^[dynamic; $N]^common.Vertex, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
  for &vertex in vertices {
    if vertex == nil || vertex.obj.type == .NONE do continue;
    tex := VertexSprites[auto_cast vertex.obj.type]
    scale := radius / f32(max(tex.width, tex.height)) / 1.5
    pos := pos_to_screen(vertex.pos, radius, screen_center)

    pos[0] -= scale * f32(tex.width) / 2
    pos[1] -= scale * f32(tex.height) / 2


    player, _ := common.find_player_by_id(&game.players, vertex.obj.playerId)
    if (player != nil) do rl.DrawTextureEx(tex, pos, 0, scale, player.color);
  }
}

@(private="file")
draw_edges :: proc(edges: ^[dynamic; $N]^common.Edge, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
  for &edge in edges {
    if edge == nil || edge.obj.type == .NONE do continue

    player, _ := common.find_player_by_id(&game.players, edge.obj.playerId)
    if player == nil do continue
    if edge.obj.type == .ROAD {
      draw_road(edge, radius, player.color, screen_center)
      continue
    }
  }
}
sync_board_renderer :: proc() {
  for &row in board_renderer.vertices do clear(&row)
  for &row in board_renderer.edges do clear(&row)
  for &vertex in game.vertices {
    if vertex.obj.type == .NONE do continue;
    append(&board_renderer.vertices[vertex.row], &vertex)
  }
  for &edge in game.edges {
    if edge.obj.type == .NONE do continue;
    append(&board_renderer.edges[edge.row], &edge)
  }
}

draw_board_pieces :: proc(w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
  draw_vertices(&board_renderer.vertices[0], w, h, radius, padding, screen_center)
  for i in 0..<11 {
    draw_edges(&board_renderer.edges[i], w, h, radius, padding, screen_center)
    draw_vertices(&board_renderer.vertices[i + 1], w, h, radius, padding, screen_center)
  }
}

