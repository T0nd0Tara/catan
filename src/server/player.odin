package server
import "../common"
import rl "vendor:raylib"
import "core:container/xar"


add_player :: proc(id: int) -> int {
  player := common.Player {
    id = id,
    color = rl.ColorFromHSV(auto_cast ((id * 70) % 360), 0.8, 1),
  }
  append(&game.players, player) 
  return len(game.players) - 1
}

calc_host :: proc() -> int {
  new_host_id : int = -1
  it := xar.freelist_iterator(&s.connections)
  for connection, _ in xar.freelist_iterate_by_ptr(&it) {
    if new_host_id == -1 || new_host_id > connection.id do new_host_id = connection.id
  }

  return new_host_id
}
