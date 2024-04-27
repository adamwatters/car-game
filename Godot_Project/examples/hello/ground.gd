extends StaticBody3D

signal spatial_drag(Dictionary)

func _process(delta):
	pass

func _on_spatial_drag(params: Dictionary):
	pass
	#if params['phase'] == "began" or params['phase'] == "changed":
		#var transform = params.global_transform as Transform3D
		#drag_vector = Vector3(transform.origin.x, 0, transform.origin.z).normalized() * 150
	#if params['phase'] == "ended":
			#drag_vector = Vector3(0,0,0)
