extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("input_event", _handle_input)

func _handle_input(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			Global.set_game_state(Global.GAME_STATES.COUNTDOWN)
