package main
import rl "vendor:raylib"


draw_cards :: proc(game: ^Game) {
	screen_center := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
  scale : f32 = 0.3


  for tex, i in CardSprites {
    pos := rl.Vector2{ screen_center[0] - (f32(tex.width) * scale * f32(int(i) - int(len(CardSprites)) / 2)), 100}
    rl.DrawTextureEx(tex, pos, 0, scale, rl.WHITE);
  }
}
