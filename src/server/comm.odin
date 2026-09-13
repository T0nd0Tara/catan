package server
import "core:nbio"
import "core:fmt"
import "core:slice"
import "core:encoding/json"
import "core:container/xar"
import "../common"

send_to_all :: proc (msg: common.Msg) {
  str_msg, err := common.encode_msg(msg)
  it := xar.freelist_iterator(&s.connections)
  for connection, index in xar.freelist_iterate_by_ptr(&it) {
    nbio.send_poly(connection.sock, {str_msg}, connection, on_sent)
  }
}
send_to_all_except :: proc (connection_ids: []int, msg: common.Msg) {
  str_msg, err := common.encode_msg(msg)
  it := xar.freelist_iterator(&s.connections)
  for connection, index in xar.freelist_iterate_by_ptr(&it) {
    _, found := slice.linear_search(connection_ids, connection.id)
    if (!found) do nbio.send_poly(connection.sock, {str_msg}, connection, on_sent)
  }
}

send :: proc (connection: ^Connection, msg: common.Msg) {
  str_msg, err := common.encode_msg(msg)
  if err != nil {
    fmt.println("Error trying to encode message", err)
    return;
  }
	nbio.send_poly(connection.sock, {str_msg}, connection, on_sent)
}

on_sent :: proc(op: ^nbio.Operation, connection: ^Connection) {
  fmt.println("sent message")
  if op.send.err != nil {
    on_disconnect(op, connection)
    return
  }
}

on_disconnect :: proc(op: ^nbio.Operation, connection: ^Connection) {
  fmt.printfln("disconnecting id: %d, index: %d", connection.id, connection.index)
  nbio.close(connection.sock)
  xar.freelist_release(&s.connections, connection.index)
}
on_recv :: proc(op: ^nbio.Operation, connection: ^Connection) {
	if op.recv.err != nil || op.recv.received == 0 {
    on_disconnect(op, connection)
		return
	}

	nbio.recv_poly(connection.sock, {connection.buf[:]}, connection, on_recv)
}

