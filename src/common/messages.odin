package common
import "core:encoding/cbor"

MsgAddPlayer :: struct {
  player: Player
};
MsgCurrentPlayer :: struct {
  player_idx: int
};
MsgFullGameState :: struct {
  game: Game
};

Msg :: union {
  MsgAddPlayer,
  MsgCurrentPlayer,
  MsgFullGameState,
};


encode_msg :: proc (msg: Msg) -> ([]byte, cbor.Marshal_Error) {
  return cbor.marshal(msg)
}
decode_msg :: proc (payload: []u8) -> (msg: Msg, err: cbor.Unmarshal_Error) {
  err = cbor.unmarshal(payload, &msg)
  return 
}
