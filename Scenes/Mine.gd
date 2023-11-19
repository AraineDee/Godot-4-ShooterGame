extends Area3D


func do_explode():
	for i in range($ShapeCast3D.get_collision_count()):
		var collider = $ShapeCast3D.get_collider(i)
		if collider is HitboxComponent:
			collider.on_hit(51)
	
	queue_free()


func _on_body_entered(body):
	do_explode()
