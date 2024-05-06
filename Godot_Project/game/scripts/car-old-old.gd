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
	car.freeze = true
	car.angular_velocity = Vector3(0,0,0)
	car.linear_velocity = Vector3(0,0,0)
	car.global_position = position
	car.freeze = false

# Called when the node enters the scene tree for the first time.
func _ready():
	ground_ray.add_exception(car)
	pass # Replace with function body.

func _process(delta):
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	var is_on_ground = ground_ray.is_colliding()

	## acceleration
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var force_vector = input_vector * delta * 1000
	if is_on_ground:
		var collider = ground_ray.get_collider()
		if collider.name == "ground":
			car.angular_damp = 6
		else:
			car.angular_damp = 2
		
		car.apply_central_force(Vector3(force_vector.x, 0, force_vector.y))

	## set the car mesh position
	car_mesh.global_position = car.global_position

	## handle inclines
	var n = ground_ray.get_collision_normal()
	var ground_normal_angle = acos(n.dot(Vector3(0,1,0)))
	lerped_linear_velocity = lerp(lerped_linear_velocity, car.linear_velocity.normalized(), delta * 10)
	var look_at_target = car_mesh.global_position + lerped_linear_velocity
	var y_offset = 0
	if is_on_ground:
		y_offset = ground_normal_angle * clamp(car.linear_velocity.y, -1, 1) # brings offset back to 0
		look_at_target_y_offset = lerpf(look_at_target_y_offset, y_offset, delta * 20)
	else:
		y_offset = ground_normal_angle * clamp(car.linear_velocity.y, 0, 1)
		look_at_target_y_offset = lerpf(look_at_target_y_offset, y_offset, delta * 2) #slower adjustment
		# maybe do something with linear velocity here to tilt back down
		pass

	look_at_target.y = car_mesh.global_position.y + look_at_target_y_offset

	if not look_at_target.is_equal_approx(car_mesh.global_position):
		car_mesh.look_at(look_at_target)

	## tilt the body and turn the wheels
	if not input_vector.is_zero_approx():
		var linear_velocity_normalized = Vector2(car.linear_velocity.x, car.linear_velocity.z).normalized()
		var input_vector_normalized = input_vector.normalized()
		var angle = acos(linear_velocity_normalized.dot(input_vector_normalized))

		var linear_velocity_3d = Vector3(linear_velocity_normalized.x, linear_velocity_normalized.y, 0)
		var input_vector_3d = Vector3(input_vector_normalized.x, input_vector_normalized.y, 0)
		var cross_product_z = linear_velocity_3d.cross(input_vector_3d).z
		var direction = 0

		if cross_product_z > 0:
			direction = 1  
		elif cross_product_z < 0:
			direction = -1 
		else:
			direction = 0  

		var turn_angle = angle * direction
		var wheel_turn_angle = turn_angle / -3
		var car_tilt_angle = clamp(turn_angle * car.linear_velocity.length() / 40, -0.25, 0.25)

		car_wheel_left.rotation.y = lerp(car_wheel_left.rotation.y, wheel_turn_angle, 4 * delta)
		car_wheel_right.rotation.y = lerp(car_wheel_right.rotation.y, wheel_turn_angle, 4 * delta)
		car_body.rotation.z = lerp(car_body.rotation.z, car_tilt_angle, 10 * delta)
	else:
		car_body.rotation.z = lerp(car_body.rotation.z, 0.0, 10 * delta)
