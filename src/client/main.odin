package client
import "core:nbio"
import "core:net"
import "core:fmt"
import "core:time"
import "core:math"
import rl "vendor:raylib"
import "../common"

game: common.Game
current_player: ^common.Player = nil

server_initialized := false

should_quit: bool = false

MAX_FPS := 120

wanted_frame_time : time.Duration = time.Second / time.Duration(MAX_FPS)

game_loop :: proc(op: ^nbio.Operation) {
  should_quit ||= rl.WindowShouldClose()
  if should_quit do return
  start_frame_time := time.now()
  defer {
    end_frame_time := time.now()
    frame_time := time.diff(start_frame_time, end_frame_time)
    time_to_wait : time.Duration = math.max(wanted_frame_time - frame_time, 0)
    nbio.timeout(time_to_wait, game_loop)
  }

	rl.BeginDrawing()
	defer rl.EndDrawing()
  rl.ClearBackground(rl.BLACK)
  if server_initialized {
    update_game()
    draw_game()
  } else {
    rl.DrawText("waiting to be initialized", 0, 200, 100, rl.WHITE)
  }

	dt := rl.GetFrameTime()
	fps := 1.0 / dt
	rl.DrawText(rl.TextFormat("dt: %f", dt), 0, 0, 20, rl.WHITE)
	rl.DrawText(rl.TextFormat("fps: %f", fps), 0, 30, 20, rl.WHITE)
}
main :: proc() {
	err := nbio.acquire_thread_event_loop()
	fmt.assertf(err == nil, "Could not initialize nbio: %v", err)
	defer nbio.release_thread_event_loop()

  ip4_addr, ok := net.parse_ip4_address("127.0.0.1")
  fmt.assertf(ok, "couldnl't parse ip4_addr")

  nbio.dial({ ip4_addr, 8080 }, on_dial)

	rl.SetConfigFlags({rl.ConfigFlag.WINDOW_RESIZABLE, rl.ConfigFlag.MSAA_4X_HINT})
	rl.InitWindow(1280, 720, "Catan")
	defer rl.CloseWindow()

	init_assets()
	defer delete_assets()

  nbio.next_tick(game_loop)

  for {
    if err := nbio.tick(timeout=0); err != nil {
      fmt.println(err)
      break;
    }

    if (should_quit) {
      break;
    }
  }

}
