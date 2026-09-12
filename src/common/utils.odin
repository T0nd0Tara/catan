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

find_player_by_id :: proc(players: ^[dynamic]Player, id: int) -> ^Player {
  for &p in players {
    if (p.id == id) do return &p
  }
  return nil
}
