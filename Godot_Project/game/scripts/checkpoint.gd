extends Area3D

@export var order_index: int = 0
@onready var flag = $pole/flag

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("checkpoints")
	pass # Replace with function body.

func is_active_checkpoint(is_active: bool):
	if is_active:
		flag.position.y = 2.5
	else:
		flag.position.y = -10.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
