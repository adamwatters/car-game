extends Area3D

@export var order_index: int = 0

@onready var mesh = $mesh

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("checkpoints")
	pass # Replace with function body.

func mesh_is_visible(visible: bool):
	var y = 0 if visible else - 4
	mesh.position = Vector3(0, y, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
