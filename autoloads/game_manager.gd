extends Node

enum State { ACTUAL, ASTRONAUT_DREAM, KNIGHT_DREAM }

var current_state: State = State.ACTUAL
var active_character: String = "none" # Pilihannya: "none", "astronaut", "knight"

# Fungsi helper untuk cek apakah karakter boleh digerakkan
func can_move(char_name: String) -> bool:
	if current_state == State.ACTUAL:
		return false
	return active_character == char_name
