extends ShapeCast2D

func fire(damage,girth,length,globpos,globrot,player):
	queue_free()
	shape.size.y = girth
	target_position.x = length
	global_rotation = globrot
	global_position = globpos
	force_update_transform()
	force_shapecast_update()
	if is_colliding():
		while damage > 0 and is_colliding():
			var alvo = get_collider(0)
			if alvo.is_in_group("player") and alvo != player:
				alvo.take_damage()
				damage = 0
			elif alvo.is_in_group("tilemap"):
				Global.spawndestruction(alvo.get_parent(),get_collision_point(0),alvo.color())
				damage = alvo.damage(damage)
				add_exception(alvo)
			else: add_exception(alvo)
			force_shapecast_update()
		if damage == 0 and is_colliding():
			return get_collision_point(0)
	return global_position+Vector2(target_position.x*cos(rotation)/10,target_position.x*sin(rotation)/10)
