extends Node3D
@onready var button_body: StaticBody3D = $reset_button_body

# Called when the node enters the scene tree for the first time.
func _ready():
	button_body.connect("input_event", _handle_input)

func _handle_input(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and get_parent().has_method("reset"):
			get_parent().reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
