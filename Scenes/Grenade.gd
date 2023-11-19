extends RigidBody3D

@onready var timer := 3.0

func _process(delta):
	if timer <= 0:
		do_explode()
	else:
		timer -= delta
		

func do_explode():
	for i in range($ShapeCast3D.get_collision_count()):
		var collider = $ShapeCast3D.get_collider(i)
		if collider is CharacterBody3D:
			apply_explosion_force(collider)
	
	queue_free()
		
func apply_explosion_force(player):
	var dir = position.direction_to(player.position)
	var dist = position.distance_to(player.position)
	player.velocity += dir * (1/dist) * 25
