extends RigidBody2D

@export var thrown_sprite_frames: SpriteFrames # Quadros de sprite da arma lançada
@export var thrown_animation: String # Animação da arma lançada

var thrower = null

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	if $Timer:
		$Timer.start()
	
	# Aplica os quadros de sprite e a animação passados para o AnimatedSprite2D da arma lançada
	var animated_sprite = $"AnimatedSprite2D" # Agora acessa diretamente seu próprio AnimatedSprite2D
	print("ThrownGun.gd: animated_sprite: ", animated_sprite)
	print("ThrownGun.gd: thrown_sprite_frames (received): ", thrown_sprite_frames)
	print("ThrownGun.gd: thrown_animation (received): ", thrown_animation)
	if animated_sprite and thrown_sprite_frames:
		animated_sprite.sprite_frames = thrown_sprite_frames
		animated_sprite.animation = thrown_animation
		animated_sprite.play() # Começa a tocar a animação
		print("ThrownGun.gd: animated_sprite.sprite_frames (after set): ", animated_sprite.sprite_frames)
		print("ThrownGun.gd: animated_sprite.animation (after set): ", animated_sprite.animation)

	# Faz a arma lançada girar em seu próprio eixo
	angular_velocity = 20.0 # Ajuste este valor para rotação mais rápida/lenta

func _on_Timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") and body != thrower:
		if body.has_method("disable_controls"):
			body.disable_controls(1.0)
		# Aplica o recuo
		var knockback_direction = linear_velocity.normalized()
		var knockback_force = 200 # Ajuste este valor conforme necessário
		body.velocity.x = knockback_direction.x * knockback_force
		body.velocity.y = -knockback_force * 0.5 # Empurra ligeiramente para cima
		queue_free()
