package main
import rl "vendor:raylib"

draw_road_hints :: proc(game: ^Game, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
}

draw_city_hints :: proc(game: ^Game, w, h, radius, padding: f32, screen_center: ^rl.Vector2) {
}

draw_settelment_hints :: proc(
	game: ^Game,
	w, h, radius, padding: f32,
	screen_center: ^rl.Vector2,
) {

	for vertex, index in game.vertices {
		pos := pos_to_screen(vertex.pos, radius, screen_center)
		rl.DrawCircle(auto_cast pos[0], auto_cast pos[1], 10, rl.WHITE)
		rl.DrawText(rl.TextFormat("%i", index), auto_cast pos[0], auto_cast pos[1], 5, rl.RED)

	}
}
