package client
import rl "vendor:raylib"
import "core:math"
import "core:fmt"
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
draw_cards :: proc() {
	screen_center := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
	base_scale: f32 : 0.3
	hovered_scale: f32 : 0.4
	hovered_animation_duaration: f32 : 0.3 // in seconds

	dt := rl.GetFrameTime()


	cards := current_player.cards

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
draw_oponent_cards:: proc(anchor: rl.Vector2, angle: f32, cards_len: int) {
  fan_view_angle : f32 : math.PI / 3
  card_scale : f32 : 0.1
  inner_fold_radius :: 15
  distance :: 80
  cards_anchor : rl.Vector2 = {
    anchor.x - distance * math.cos(angle),
    anchor.y - distance * math.sin(angle),
  }

  source : rl.Rectangle = {
    0,0, f32(BackCardSprite.width), f32(BackCardSprite.height)
  }
  dest : rl.Rectangle = {
    cards_anchor.x,
    cards_anchor.y,
    card_scale * f32(BackCardSprite.width), card_scale * f32(BackCardSprite.height)
  }

  for i in 0..<cards_len {
    t := f32(i + 1) / f32(cards_len + 1)
    start := math.PI + angle + fan_view_angle
    end   := math.PI + angle - fan_view_angle

    card_angle : f32 = t * (end - start) + start

    origin : rl.Vector2 = { 
      dest.width / 2,
      dest.height + inner_fold_radius
    }

    rl.DrawTexturePro(BackCardSprite, source, dest, origin, (card_angle - math.PI / 2) * math.DEG_PER_RAD, rl.WHITE)
  }
}

draw_oponent:: proc(angle: f32, player: ^common.Player) {
  radius_x : f32 = f32(rl.GetScreenWidth() / 2)  * 0.9;
  radius_y : f32 = f32(rl.GetScreenHeight() / 2) * 0.9;

  anchor : rl.Vector2 = {
    radius_x * math.cos(angle) + f32(rl.GetScreenWidth()) / 2,
    radius_y * math.sin(angle) + f32(rl.GetScreenHeight()) / 2,
  }
  draw_oponent_cards(anchor, angle, len(player.cards))

  if (player.id == game.current_player_turn) {
    rl.DrawCircleV(anchor, 15, rl.YELLOW)
  }
  rl.DrawCircleV(anchor, 10, player.color)
}
draw_oponents :: proc() {
  // oponents are spaced evenly between -oponents_view_angle to oponents_view_angle
  oponents_view_angle : f32 : math.PI / 2
  oponents_count := len(game.players) - 1


  oponent_counter: f32 = 0

  for &player in game.players {
    if (&player == current_player) do continue;
    defer oponent_counter += 1

    // the `+ 1` is there because we imagine a player in the start so the players will be orderd uniformly
    t : f32 = (oponent_counter + 1) / f32(oponents_count + 1)
    start := 1.5 * math.PI - oponents_view_angle
    end   := 1.5 * math.PI + oponents_view_angle
    angle : f32 =  t * (end - start) + start

    draw_oponent(angle, &player);
  }
}
