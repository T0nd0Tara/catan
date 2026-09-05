package server
import "../common"
import rl "vendor:raylib"


add_player :: proc(id: int) {
  player := common.Player {
    id = id,
    color = rl.ColorFromHSV(auto_cast ((id * 70) % 360), 0.8, 1),
  }
  append(&game.players, player)
  send_to_all(common.MsgAddPlayer {
    player
  })
}
