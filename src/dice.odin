package main
import "core:c"
import rl "vendor:raylib"

draw_dice :: proc(game: ^Game) {
	screen_width := rl.GetScreenWidth()
	screen_height := rl.GetScreenHeight()

	size: f32 = f32(screen_width) / 20.0
	margin: c.int = screen_width / 12
	rect: rl.Rectangle = {
		x      = f32(screen_width - margin),
		y      = f32(rl.GetScreenHeight() - margin),
		width  = size,
		height = size,
	}
	rl.DrawRectangleRoundedLinesEx(rect, 0.1, 3, 5, rl.RED)
	rect.x -= rect.width + f32(margin) / 3.0
	rl.DrawRectangleRoundedLinesEx(rect, 0.1, 3, 5, rl.YELLOW)
}
