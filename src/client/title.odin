package client
import rl "vendor:raylib"
import "core:strings"



TitleAnimationState :: struct {
  text: string,
  duaration: f32,
  t: f32, // 0 - 1
  attack: f32, // 0 - 1
  release: f32, // 0 - 1
}
get_title_animation_state :: proc(text: string, duaration: f32 = 2) -> TitleAnimationState {
  return {
    text = text,
    duaration = duaration,
    t = 0,
    attack = 0.2,
    release = 0.1,
  }
}

current_title_animation: TitleAnimationState

draw_title :: proc() {
  if (current_title_animation.t >= 1) do return;
  if (len(current_title_animation.text) == 0) do return;

  y_movement_size : i32 = rl.GetScreenHeight() / 15

	dt := rl.GetFrameTime()
  current_title_animation.t += dt / current_title_animation.duaration

  opacity : f32 = 1

  if (current_title_animation.t < current_title_animation.attack) do opacity = rl.EaseQuadOut(current_title_animation.t, 0, 1, current_title_animation.attack)
  else if (current_title_animation.t > 1 - current_title_animation.release) do opacity = 1 - rl.EaseQuadIn(current_title_animation.t - (1 - current_title_animation.release), 0, 1, current_title_animation.release)

  y_movement : i32 = i32(f32(y_movement_size) * rl.EaseQuadOut(current_title_animation.t, 0, 1, 1)) - y_movement_size / 2
  x := (rl.GetScreenWidth() - TitleSprite.width) / 2
  y := (rl.GetScreenHeight() - TitleSprite.height) / 2 + y_movement

  tint := rl.Fade(rl.WHITE, opacity)
  shadow_tint := rl.Fade(rl.BLACK, opacity)

  shadow_diff : i32 : 5

  rl.DrawTexture(TitleSprite, x + shadow_diff, y + shadow_diff, shadow_tint)
  rl.DrawTexture(TitleSprite, x, y, tint)

  font := &MainFont
  default_text_size : f32 = f32(TitleSprite.height / 2)
  max_text_width := f32(TitleSprite.width) * 0.55
  text_spacing :: 0
  text_y_buffer := rl.GetScreenHeight() / 30
  text := strings.clone_to_cstring(current_title_animation.text, context.temp_allocator)

  text_measure := rl.MeasureTextEx(font^, text, default_text_size, text_spacing)
  text_size_multiplier := text_measure.x > max_text_width ? max_text_width / text_measure.x : 1
  text_size := text_size_multiplier * default_text_size

  text_pos := rl.Vector2{
    f32(x) - text_size_multiplier * text_measure[0] / 2 + f32(TitleSprite.width / 2),
    f32(y) - text_size_multiplier * text_measure[1] / 2 + f32(TitleSprite.height / 2) - f32(text_y_buffer)
  }
  rl.DrawTextEx(font^, text, text_pos + f32(shadow_diff), text_size, text_spacing, shadow_tint)
  rl.DrawTextEx(font^, text, text_pos, text_size, text_spacing, tint)

}
