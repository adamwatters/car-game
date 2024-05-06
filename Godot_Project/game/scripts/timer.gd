extends Node3D
@onready var text_mesh = $text_mesh
@onready var timer = $timer
@export var initial_time = 0
var time_elapsed: int
# Called when the node enters the scene tree for the first time.
func _ready():
	text_mesh.mesh.text = "%s" % initial_time
	time_elapsed = initial_time
	timer.start()
	timer.connect("timeout", _handle_tick)
	pass # Replace with function body.

func reset():
	timer.stop()
	time_elapsed = initial_time
	text_mesh.mesh.text = "%s" % time_elapsed
	timer.start()

func stop():
	timer.stop()
	return time_elapsed

func _handle_tick():
	var mesh = text_mesh as TextMesh
	time_elapsed += 1
	text_mesh.mesh.text = "%s" % time_elapsed

