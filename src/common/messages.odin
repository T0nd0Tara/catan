package common
import "core:reflect"
import "core:fmt"
import "core:strings"
import "core:encoding/cbor"
import "base:runtime"

MsgAddPlayer :: struct {
  player: Player
};
MsgFullGameState :: struct {
  game: Game
};

Msg :: union {
  MsgAddPlayer,
  MsgFullGameState,
};


encode_msg :: proc (msg: Msg) -> ([]byte, cbor.Marshal_Error) {
  return cbor.marshal(msg)
}
decode_msg :: proc (payload: []u8) -> (msg: Msg, err: cbor.Unmarshal_Error) {
  err = cbor.unmarshal(payload, &msg)
  return 
}
