package server

import "core:container/xar"
import "core:fmt"
import "core:nbio"
import "core:encoding/json"

Msg :: struct {
  msg: string,
  id: int,
  index: int
}
Server :: struct {
	socket:      nbio.TCP_Socket,
	// Xar is used in favor of `[dynamic]Connection` so pointers are stable.
	connections: xar.Freelist_Array(Connection, 4),
}

id_counter := 0

Connection :: struct {
	server: ^Server,
	sock:   nbio.TCP_Socket,
	buf:    [1024 * 1024]byte,
  index: int,
  id: int,
}

main :: proc() {
	err := nbio.acquire_thread_event_loop()
	fmt.assertf(err == nil, "Could not initialize nbio: %v", err)
	defer nbio.release_thread_event_loop()

	server: Server

	socket, listen_err := nbio.listen_tcp({nbio.IP4_Any, 8080})
	fmt.assertf(listen_err == nil, "Error listening on localhost:8080: %v", listen_err)
	server.socket = socket

	nbio.accept_poly(socket, &server, on_accept)

	rerr := nbio.run()
	fmt.assertf(rerr == nil, "Server stopped with error: %v", rerr)
}

on_accept :: proc(op: ^nbio.Operation, server: ^Server) {
	fmt.assertf(op.accept.err == nil, "Error accepting a connection: %v", op.accept.err)

	nbio.accept_poly(server.socket, server, on_accept)

	connection, index, alloc_err := xar.freelist_push_with_index(&server.connections, Connection{
		server = server,
		sock   = op.accept.client,
    id = id_counter
	})
  connection.index = index
  id_counter += 1

  fmt.printfln("connecting id: %d, index: %d", connection.id, connection.index)
  
  assert(alloc_err == nil)

	nbio.recv_poly(op.accept.client, {connection.buf[:]}, connection, on_recv)
}

on_disconnect :: proc(op: ^nbio.Operation, connection: ^Connection) {
  fmt.printfln("disconnecting id: %d, index: %d", connection.id, connection.index)
  nbio.close(connection.sock)
  xar.freelist_release(&connection.server.connections, connection.index)
}
on_recv :: proc(op: ^nbio.Operation, connection: ^Connection) {
	if op.recv.err != nil || op.recv.received == 0 {
    on_disconnect(op, connection)
		return
	}

  msg : Msg = {
    msg = fmt.aprintf("hey yo, you sent '%s'", connection.buf[:op.recv.received]),
    id = connection.id,
    index = connection.index
  }
  str_msg, err := json.marshal(msg, {})


	nbio.send_poly(connection.sock, {str_msg}, connection, on_sent)
}

on_sent :: proc(op: ^nbio.Operation, connection: ^Connection) {
  if op.send.err != nil {
    on_disconnect(op, connection)
    return
  }
	nbio.recv_poly(connection.sock, {connection.buf[:]}, connection, on_recv)
}
