extends Node3D

@onready var timer = $Timer
@onready var beep_sound = $beep_sound
@onready var numbers_container = $numbers

var numbers: Array[Node3D] = []
var count = 0

var callback: Callable

func start(cb: Callable):
	callback = cb
	timer.start()
	timer.connect("timeout", _handle_tick)

func _handle_tick():
	if count < numbers.size() - 1:
		numbers[count].position.y = -100
		count += 1
		numbers[count].position.y = 0
		if count == numbers.size() - 1:
			beep_sound.pitch_scale = 1
			beep_sound.play()
			timer.stop()
			callback.call()
		else:
			beep_sound.pitch_scale = 2
			beep_sound.play()
	#var mesh = text_mesh as TextMesh
	#time_elapsed += 1
	#text_mesh.mesh.text = "%s" % time_elapsed

func get_numbers() -> Array[Node3D]:
	if numbers.is_empty():
		var new_numbers: Array[Node3D] = []
		for number in numbers_container.get_children():
			if number is Node3D:
				new_numbers.append(number)
		numbers = new_numbers
	return numbers
	
func _ready():
	for number in get_numbers().slice(1):
		number.position.y = -100
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
