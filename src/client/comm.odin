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

  recv :=  transmute(^nbio.Recv)op

  msg := common.decode_msg(recv_buff[:])
  #partial switch m in msg {
  case common.MsgFullGameState: {
    server_initialized = true
    game = m.game
  }
  }

}
on_dial :: proc (op: ^nbio.Operation) {
  fmt.assertf(op.dial.err == nil, "dial: %v", op.dial.err)
  fmt.println("dial succeeded")

  socket = op.dial.socket

  nbio.recv(socket, { recv_buff[:] }, recv_loop)
}
