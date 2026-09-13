package client
import "../common"
import rl "vendor:raylib"

draw_host_ui :: proc() {
  if (connection_id != game.host_player_id) do return

  padding :: 10
  radius :: 10

  pos: rl.Vector2 = {
    padding + radius,
    f32(rl.GetScreenHeight()) - padding - radius
  }
  font_size :: 2 * radius
  text_padding :: radius / 5
  host_text : cstring : "H"

  text_measure := rl.MeasureTextEx(MainFont, host_text, font_size, 0)

  rl.DrawCircleV(pos, radius, rl.YELLOW)
  rl.DrawTextEx(MainFont, "H", pos - text_measure / 2 + rl.Vector2{ 0, text_padding }, font_size, 0, rl.BLACK)
}
