package main
import rl "vendor:raylib"


cards_animation :=  [dynamic]f32{};

draw_cards :: proc(game: ^Game) {
	screen_center := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
  base_scale : f32 = 0.3
  selected_scale : f32 = 0.6
  selected_animation_duaration : f32 = 1.0 // in seconds

  dt := rl.GetFrameTime()


  cards := game.players[0].cards
  
  if len(cards) != len(cards_animation) {
    temp_cards_animation := make([dynamic]f32, len(cards), cap(cards))

    for i in 0..<min(len(temp_cards_animation), len(cards_animation)) {
      temp_cards_animation[i] = cards_animation[i]
    }

    for i in len(cards_animation)..<len(temp_cards_animation) {
      temp_cards_animation[i] = 0
    }

    delete(cards_animation)
    cards_animation = temp_cards_animation
  }

  for card, i in cards {
    t := (cards_animation[i] + dt) / selected_animation_duaration
    //                        time, from, to, scale
    scale := rl.EaseCubicInOut(t, base_scale, selected_scale, 1.0)

    tex := CardSprites[card]
    pos := rl.Vector2{
      screen_center[0] + (f32(tex.width) * base_scale * (f32(i) - f32(len(cards)) / 2)),
      f32(rl.GetScreenHeight()) - f32(tex.height) * base_scale * 0.8
    }

    pos[0] -= (auto_cast tex.width  * (scale - base_scale)) / 2
    pos[1] -= (auto_cast tex.height * (scale - base_scale))
    rect : rl.Rectangle = {
      x = pos[0],
      y = pos[1],
      width = f32(tex.width) * scale,
      height = f32(tex.height) * scale,
    }
    selected := rl.CheckCollisionPointRec(rl.GetMousePosition(), rect)
    cards_animation[i] += f32(int(selected) * 2 - 1) * dt

    cards_animation[i] = clamp(cards_animation[i], 0, 1)


    rl.DrawTextureEx(tex, pos, 0, scale, rl.WHITE);
  }
}
