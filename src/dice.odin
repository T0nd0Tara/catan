package main
import "core:c"
import "core:math/rand"
import rl "vendor:raylib"

roll_dice :: proc(game: ^Game) {
	random_range :: proc(from: u32, to: u32) -> u32 {
		return (rand.uint32() % (to - from)) + from
	}
	game.dice = {u8(random_range(1, 6)), u8(random_range(1, 6))}
}

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
	rl.DrawText(
		rl.TextFormat("%d", game.dice[0]),
		auto_cast rect.x,
		auto_cast rect.y,
		auto_cast rect.width,
		rl.YELLOW,
	)

	rect.x -= rect.width + f32(margin) / 3.0
	rl.DrawRectangleRoundedLinesEx(rect, 0.1, 3, 5, rl.YELLOW)
	rl.DrawText(
		rl.TextFormat("%d", game.dice[1]),
		auto_cast rect.x,
		auto_cast rect.y,
		auto_cast rect.width,
		rl.RED,
	)
}
