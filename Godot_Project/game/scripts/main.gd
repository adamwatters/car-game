extends Node3D

@onready var start = $start
@onready var timer = $balloon/balloon_inner/balloon_content/timer

var car_scene = preload("res://game/scenes/car.tscn")

var checkpoints: Array[Node] = []
var start_positions: Array[Node] = []
var next_checkpoint_index: int

func _setup():
	Global.setup_for_track(start)

func _set_next_checkpoint(next_index: int):
	next_checkpoint_index = next_index
	for checkpoint in checkpoints:
		if next_checkpoint_index == checkpoint.order_index:
			checkpoint.is_active_checkpoint(true)
		else:
			checkpoint.is_active_checkpoint(false)
			
func _ready():
	start_positions = get_tree().get_nodes_in_group("start_positions")
	
	var index: int = 0
	for start_position in start_positions:
		var new_car = car_scene.instantiate()
		
		# two seperate ifs below because otherwise editor doesn't give property hints 
		if start_position is Node3D:
			if new_car is Car:
				new_car.global_position = Vector3(start_position.global_position.x, 5, start_position.global_position.z)
				new_car.basis = start_position.basis
				if index == 0:
					new_car.controlledBy = Car.ControlledBy.player
				else:
					new_car.controlledBy = Car.ControlledBy.cpu
				index += 1
				new_car.locked = true
				add_child(new_car)

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
