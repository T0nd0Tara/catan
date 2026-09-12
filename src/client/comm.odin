package client
import "core:net"
import "core:nbio"
import "core:fmt"
import "../common"

recv_buff : [1024 * 1024]byte
send_buff : [1024 * 1024]byte

socket : net.TCP_Socket


on_send :: proc (op: ^nbio.Operation) { }

recv_loop :: proc (op: ^nbio.Operation) {
  defer nbio.recv(socket, { recv_buff[:] }, recv_loop)

  fmt.println("recv")
  fmt.assertf(op.type == .Recv, "op type not recv")


  recv := transmute(^nbio.Recv)op
  msg, err := common.decode_msg(recv_buff[:])
  fmt.println(msg)
  if (err != nil) {
    fmt.println("err", err)
    return
  }

  #partial switch m in msg {
  case common.MsgFullGameState: {
    server_initialized = true
    game = m.game
    calculate_available_vertices_for_settelments()
    // fmt.println("recieved msg:", string(recv_buff[:]))
  }
  case common.MsgCurrentPlayer: {
    assert(server_initialized, "Got current player before initialization")
    current_player = common.find_player_by_id(&game.players, m.player_idx)
    fmt.println("current player", current_player)
  }
  }

}
on_dial :: proc (op: ^nbio.Operation) {
  fmt.assertf(op.dial.err == nil, "dial: %v", op.dial.err)
  fmt.println("dial succeeded")

  socket = op.dial.socket

  nbio.recv(socket, { recv_buff[:] }, recv_loop)
}
