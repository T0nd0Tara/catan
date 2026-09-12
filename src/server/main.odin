package server

import "../common"
import "core:container/xar"
import "core:fmt"
import "core:nbio"

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
Connection :: struct {
	sock:   nbio.TCP_Socket,
	buf:    [1024 * 1024]byte,
  index: int,
  id: int,
}

id_counter := 0

game : common.Game
s: Server

main :: proc() {
	err := nbio.acquire_thread_event_loop()
	fmt.assertf(err == nil, "Could not initialize nbio: %v", err)
	defer nbio.release_thread_event_loop()

	init_board()
	reset_game()


	socket, listen_err := nbio.listen_tcp({nbio.IP4_Any, 8080})
	fmt.assertf(listen_err == nil, "Error listening on localhost:8080: %v", listen_err)
	s.socket = socket

	nbio.accept_poly(socket, &s, on_accept)

	rerr := nbio.run()
	fmt.assertf(rerr == nil, "Server stopped with error: %v", rerr)
}

on_accept :: proc(op: ^nbio.Operation, s: ^Server) {
	fmt.assertf(op.accept.err == nil, "Error accepting a connection: %v", op.accept.err)

	nbio.accept_poly(s.socket, s, on_accept)

	connection, index, alloc_err := xar.freelist_push_with_index(&s.connections, Connection{
		sock   = op.accept.client,
    id = id_counter
	})
  connection.index = index
  id_counter += 1

  fmt.printfln("connecting id: %d, index: %d", connection.id, connection.index)
  
  assert(alloc_err == nil)

  player_idx := add_player(connection.id)
  send(connection, common.MsgFullGameState{ game, connection.id })

  send_to_all_except({connection.id}, common.MsgAddPlayer {
    player = game.players[player_idx]
  })

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
}

