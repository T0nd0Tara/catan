package client
import rl "vendor:raylib"
import "../common"


CardAnimationState :: struct {
	hovered: f32,
}

cards_animation := [dynamic]CardAnimationState{}

viewing_animation: f32 = 0
viewing_animation_duaration :: 0.2

update_card_animation_array :: proc(cards: ^[dynamic]common.Card) {
	if len(cards) == len(cards_animation) do return

	temp_cards_animation := make([dynamic]CardAnimationState, len(cards), cap(cards))

	for i in 0 ..< min(len(temp_cards_animation), len(cards_animation)) {
		temp_cards_animation[i] = cards_animation[i]
	}

	for i in len(cards_animation) ..< len(temp_cards_animation) {
		temp_cards_animation[i] = {0}
	}

	delete(cards_animation)
	cards_animation = temp_cards_animation
}
draw_cards :: proc(game: ^common.Game) {
	screen_center := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
	base_scale: f32 : 0.3
	hovered_scale: f32 : 0.4
	hovered_animation_duaration: f32 : 0.3 // in seconds

	dt := rl.GetFrameTime()


	cards := game.players[0].cards

	update_card_animation_array(&cards)

	hovered_card: int = -1

	for card, i in cards {
		t := cards_animation[i].hovered + dt / hovered_animation_duaration
		//                       time, from, scale, t_max
		scale := rl.EaseQuadOut(t, base_scale, hovered_scale - base_scale, 1)

		tex := CardSprites[card.type]

		card_hidden_scale :: rl.Vector2{0.5, 0.3}
		// TODO: For some reason the cards are not centered when they're hidden and centered when shown
		pos := rl.Vector2 {
			f32(tex.width) * base_scale * (f32(i) - f32(len(cards)) / 2) * card_hidden_scale[0],
			f32(tex.height) * base_scale * card_hidden_scale[1],
		}

		viewing_t := rl.EaseQuadOut(viewing_animation, 0, 1, viewing_animation_duaration)
		pos[0] = rl.Lerp(pos[0], pos[0] / card_hidden_scale[0], viewing_t)
		pos[1] = rl.Lerp(pos[1], pos[1] / card_hidden_scale[1], viewing_t)

		pos[0] += screen_center[0]
		pos[1] = f32(rl.GetScreenHeight()) - pos[1]

		pos[0] -= (auto_cast tex.width * (scale - base_scale)) / 2
		pos[1] -= (auto_cast tex.height * (scale - base_scale))
		rect: rl.Rectangle = {
			x      = pos[0],
			y      = pos[1],
			width  = f32(tex.width) * scale,
			height = f32(tex.height) * scale,
		}

		if hovered_card == -1 && rl.CheckCollisionPointRec(rl.GetMousePosition(), rect) {
			hovered_card = i
		}

		rl.DrawTextureEx(tex, pos, 0, scale, rl.WHITE)
	}

	if hovered_card != -1 {
		cards_animation[hovered_card].hovered += 2 * dt / hovered_animation_duaration
		viewing_animation += dt
	} else {
		viewing_animation -= dt
	}

	viewing_animation = clamp(viewing_animation, 0, viewing_animation_duaration)

	for i in 0 ..< len(cards_animation) {
		cards_animation[i].hovered -= dt / hovered_animation_duaration

		cards_animation[i].hovered = clamp(cards_animation[i].hovered, 0, 1)

	}
}
