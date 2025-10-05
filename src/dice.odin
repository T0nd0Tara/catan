package main
import "core:c"
import "core:math/rand"
import rl "vendor:raylib"

roll_dice :: proc(game: ^Game) {
	random_range :: proc(from: u32, to: u32) -> u32 {
		return (rand.uint32() % (to - from)) + from
	}
	game.dice = {u8(random_range(1, 7)), u8(random_range(1, 7))}
}

draw_die :: proc(rect: rl.Rectangle, bg, fg: rl.Color, number: u8) {
	rl.DrawRectangleRounded(rect, 0.3, 4, bg)
	padding := rl.Vector2{rect.width / 5, rect.height / 5}

	circles: [dynamic]rl.Vector2 = make([dynamic]rl.Vector2, 0, 6)
	defer delete(circles)

	// MM
	if number % 2 == 1 do append(&circles, rl.Vector2{rect.width / 2, rect.height / 2})

	if number != 1 {
		// TL
		append(&circles, padding)
		// BR
		append(&circles, rl.Vector2{rect.width - padding[0], rect.height - padding[1]})
	}

	if number > 3 {
		// TR
		append(&circles, rl.Vector2{rect.width - padding[0], padding[1]})
		// BL
		append(&circles, rl.Vector2{padding[0], rect.height - padding[1]})
	}

	// SIDES
	if number == 6 {
		append(&circles, rl.Vector2{padding[0], rect.height / 2})
		append(&circles, rl.Vector2{rect.width - padding[0], rect.height / 2})
	}

	radius: f32 = min(rect.width, rect.height) / 10
	for dot in circles {
		rl.DrawCircleV(rl.Vector2{dot[0] + rect.x, dot[1] + rect.y}, radius, fg)
	}
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
	draw_die(rect, rl.RED, rl.YELLOW, game.dice[0])

	rect.x -= rect.width + f32(margin) / 3.0
	draw_die(rect, rl.YELLOW, rl.RED, game.dice[1])
}
