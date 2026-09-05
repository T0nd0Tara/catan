package common
import "core:reflect"
import "core:encoding/json"
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


IOMsg :: struct {
  type: i64,
  data: Msg
}

encode_msg :: proc (msg: Msg) -> ([]byte, json.Marshal_Error) {
  return json.marshal(IOMsg{
    type = reflect.get_union_variant_raw_tag(msg),
    data = msg
  })
}
decode_msg :: proc (payload: []u8) -> (msg: Msg) {
  iomsg : IOMsg
  err := json.unmarshal(payload, &iomsg)
  reflect.set_union_variant_raw_tag(iomsg.data, iomsg.type)
  msg = iomsg.data
  return 
}
