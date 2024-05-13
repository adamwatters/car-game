extends Node3D

var initial_global_position: Vector3
var target_global_position: Vector3

var inner_local_initial_position: Vector3
var animation_clock = 0

@onready var balloon_inner = $balloon_inner
@onready var start_button = $balloon_inner/balloon_content/start_button
@onready var count_down = $balloon_inner/balloon_content/countdown
@onready var timer = $balloon_inner/balloon_content/timer

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.game_state_set.connect(_handle_game_state)
	inner_local_initial_position = balloon_inner.position
	count_down.position.y = -100

func _handle_game_state(state: Global.GAME_STATES):
	if state == Global.GAME_STATES.COUNTDOWN:
		start_button.position.y = -100
		timer.position.y = -100
		count_down.position.y = 0
		target_global_position = Global.start_node.global_position
		await get_tree().create_timer(1.0).timeout
		count_down.start(_on_countdown_finished)
		# run a startdown and return 
		
	if state == Global.GAME_STATES.STARTED:
		await get_tree().create_timer(2.0).timeout
		timer.position.y = 0
		count_down.position.y = -100
		target_global_position = initial_global_position

func _on_countdown_finished():
	Global.set_game_state(Global.GAME_STATES.STARTED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	animation_clock += delta
	balloon_inner.position.y = inner_local_initial_position.y + sin(animation_clock)
	global_position = lerp(global_position, Vector3(target_global_position.x, global_position.y, target_global_position.z), delta)
