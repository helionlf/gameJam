# flecha.gd
extends CharacterBody2D

@export var gravidade: float = 980.0

func iniciar(posicao_global, direcao, poder_de_forca):
	global_position = posicao_global
	velocity = direcao * poder_de_forca

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravidade * delta
	
	rotation = velocity.angle()
	
	move_and_slide()
	

	if get_slide_collision_count() > 0:
		var colisao = get_slide_collision(0)
		if colisao:
			if colisao.get_collider().is_in_group("player"):
				colisao.get_collider().take_damage()
			
			set_physics_process(false)
