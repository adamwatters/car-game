extends Node3D

@onready var car = $car
@onready var start = $start
@onready var timer = $balloon/timer

var checkpoints: Array[Node] = []
var next_checkpoint_index: int

func _setup():
	pass
	#car.go_to_position(start.global_position)

func _set_next_checkpoint(next_index: int):
	next_checkpoint_index = next_index
	for checkpoint in checkpoints:
		if next_checkpoint_index == checkpoint.order_index:
			checkpoint.is_active_checkpoint(true)
		else:
			checkpoint.is_active_checkpoint(false)
			
func _ready():
	checkpoints = get_tree().get_nodes_in_group("checkpoints")
	_set_next_checkpoint(0)
	for checkpoint in checkpoints:
		checkpoint.connect("body_entered", func(_body):
			if checkpoint.order_index == next_checkpoint_index:
				if checkpoint.order_index + 1 == checkpoints.size():
					var time = timer.stop()
					print("finished in %s" % time)
				else:
					print("checkpoint %s" % checkpoint.order_index)
					_set_next_checkpoint(checkpoint.order_index + 1)
		)
	_setup()

func reset():
	timer.reset()
	_set_next_checkpoint(0)
	_setup()
