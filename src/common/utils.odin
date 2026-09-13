package common;
append_ptr :: proc(arr: ^[$N]^$T, elem: ^T) -> bool {
  for i in 0..<N {
    if (arr[i] == nil) {
      arr[i] = elem;
      return true;
    }
  }
  return false;
}

find_player_by_id :: proc(players: ^[dynamic]Player, id: int) -> (^Player, int) {
  for i in 0..<len(players) {
    if (players[i].id == id) do return &players[i], i
  }
  return nil, -1
}
