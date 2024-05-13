extends Node

var start_node: Node3D

enum GAME_STATES {
	WAIT_FOR_PLAYER_START, COUNTDOWN, STARTED
}

signal game_state_set(state: GAME_STATES)
var game_state: GAME_STATES = GAME_STATES.WAIT_FOR_PLAYER_START
func set_game_state(state: GAME_STATES):
	game_state_set.emit(state)
	game_state = state

func setup_for_track(start: Node3D):
	start_node = start
