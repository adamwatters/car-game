extends Node3D
@onready var car = $car_physics
@onready var car_mesh = $car_mesh
@onready var car_mesh_inner = $car_mesh/car_mesh_inner
@onready var car_body = $car_mesh/car_mesh_inner/ambulance/body
@onready var car_wheel_left = $car_mesh/car_mesh_inner/ambulance/wheel_frontLeft
@onready var car_wheel_right = $car_mesh/car_mesh_inner/ambulance/wheel_frontRight
@onready var ground_ray = $car_mesh/car_mesh_inner/ground_ray

var look_at_target_y_offset = 0.0
var lerped_linear_velocity = Vector3(0,0,0)

func go_to_position(position: Vector3):
	#car.freeze = true
	#car.angular_velocity = Vector3(0,0,0)
	#car.linear_velocity = Vector3(0,0,0)
	car.global_position = position
	#car.freeze = false

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
# Called when the node enters the scene tree for the first time.
func _ready():
	ground_ray.add_exception(car)
	pass # Replace with function body.

# Engine power
const engine_power = 15
const breaking_power = 5

# Turn amount, in degrees
const max_steering_angle = 40
# How quickly the car turns
const turn_speed = 2
# Below this speed, the car doesn't turn
const turn_stop_limit = 0.75

var is_accelerating = false
var is_breaking = false
var steering_angle = 0

func _process(delta):
	
	# -------------------
	# capture input
	
	is_accelerating = Input.is_action_pressed("ui_select")
	is_breaking = Input.is_action_pressed("ui_accept")	
	var turn_input = -1 * Input.get_action_strength("ui_left") + Input.get_action_strength("ui_right")
	steering_angle = deg_to_rad(turn_input * max_steering_angle)
	
	# -------------------
	# turn the wheels
	
	var left_wheel_rotation = car_wheel_left.global_basis.get_rotation_quaternion()
	# left wheel has rotation in the model - so add PI below
	var left_wheel_target_rotation = car_mesh.global_basis.rotated(car_mesh.global_basis.y, PI + steering_angle * -1).get_rotation_quaternion()
	var left_wheel_slerped_quat = left_wheel_rotation.slerp(left_wheel_target_rotation, delta * 8).normalized()
	car_wheel_left.global_basis = Basis(left_wheel_slerped_quat)
	
	var right_wheel_rotation = car_wheel_right.global_basis.get_rotation_quaternion()
	var right_wheel_target_rotation = car_mesh.global_basis.rotated(car_mesh.global_basis.y, steering_angle * -1).get_rotation_quaternion()
	var right_wheel_slerped_quat = right_wheel_rotation.slerp(right_wheel_target_rotation, delta * 8).normalized()
	car_wheel_right.global_basis = Basis(right_wheel_slerped_quat)
	
	# -------------------
	# tilt the body
	
	# car.linear_velocity.length() maxes out around 200
	var tilt_angle = steering_angle * clamp(car.linear_velocity.length_squared() / 400, 0, 0.25)
	var base_rotation = car_body.global_basis.get_rotation_quaternion()
	var target_rotation = car_mesh.global_basis.rotated(car_mesh.global_basis.z, tilt_angle).get_rotation_quaternion()
	var slerped_quat = base_rotation.slerp(target_rotation, delta * 8).normalized()
	car_body.global_basis = Basis(slerped_quat)
	# -------------------
	
func _physics_process(delta):
	car_mesh.global_position = car.global_position
	
	# -------------------
	# turn the car mesh
	
	var look_at_dir: Vector3 = car.linear_velocity * Vector3(1, 0, 1)
	if look_at_dir.length() > 0.0001:	
		car_mesh.look_at(car_mesh.global_position + look_at_dir)
		
	# -------------------
	
	
	var x_z_linear_velocity = car.linear_velocity
	x_z_linear_velocity.y = 0
	
	#if not x_z_linear_velocity.is_zero_approx():
		#car_mesh.look_at(car_mesh.global_position + x_z_linear_velocity) # do this with basis
	
	var is_on_ground = ground_ray.is_colliding()
	
	if is_on_ground:
		var central_force = Vector3(0,0,0)
		
		## stearing angle is decreased at very low speed
		var adjusted_stearing_angle = steering_angle * clamp(car.linear_velocity.length_squared() / 2, 0, 1)
		## stearing angle is decreased at very low speed
		var rotated_linear_velocity = car.linear_velocity.rotated(car_mesh.global_basis.y.normalized(), adjusted_stearing_angle * -1)
		car.linear_velocity = car.linear_velocity.slerp(rotated_linear_velocity, delta * 2)
		
		if is_accelerating:
			central_force += car_mesh.global_basis.z * -1 * engine_power
			#central_force += car_mesh.global_basis.rotated(car_mesh.global_basis.y, steering_angle * -1).z * -1 * engine_power
		if is_breaking:
			central_force += car_mesh.global_basis.z * 1 * breaking_power
		car.apply_central_force(central_force)

