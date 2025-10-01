package main
import rl "vendor:raylib"


draw_cards :: proc(game: ^Game) {
	screen_center := rl.Vector2{f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
  scale : f32 = 0.3


  cards := game.players[0].cards
  for card, i in  cards{
    tex := CardSprites[card]
    pos := rl.Vector2{
      screen_center[0] + (f32(tex.width) * scale * (f32(i) - f32(len(cards)) / 2)),
      f32(rl.GetScreenHeight()) - f32(tex.height) * scale * 0.8
    }
    rl.DrawTextureEx(tex, pos, 0, scale, rl.WHITE);
  }
}
