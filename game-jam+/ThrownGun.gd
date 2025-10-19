extends RigidBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var thrower = null
var lethal = false

func set_sprite(nomedosprite):
	sprite_2d.texture = load(nomedosprite)
	if nomedosprite == "res://Sprites/axe.png":
		lethal = true

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	if $Timer:
		$Timer.start()
	angular_velocity = 20.0 # Ajuste este valor para rotação mais rápida/lenta

func _on_Timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") and body != thrower:
		if lethal:
			body.take_damage()
		else:
			body.disable_controls(1.0)
			var knockback_direction = linear_velocity.normalized()
			var knockback_force = 300 # Ajuste este valor conforme necessário
			body.speed = knockback_direction.x * knockback_force
			body.velocity.y = -knockback_force * 0.5 # Empurra ligeiramente para cima
			queue_free()

func take_damage():
	queue_free()
