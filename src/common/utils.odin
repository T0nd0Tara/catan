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
current_player :: proc (game: ^Game) -> ^Player {
  return &game.players[0];
}
