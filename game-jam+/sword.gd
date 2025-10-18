# sword.gd
extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var is_attacking = false

func _ready():
	# --- MUDANÇA AQUI ---
	# Começa desligada, assim como a arma
	visible = false
	set_process(false)
	collision_shape.disabled = true
	# --------------------
	
	animated_sprite.animation_finished.connect(_on_animation_finished)
	body_entered.connect(_on_body_entered) 

func equipar():
	visible = true
	set_process(true) 
	is_attacking = false
	collision_shape.disabled = true
	animated_sprite.play("idle")

func desequipar():
	visible = false
	set_process(false) 
	collision_shape.disabled = true

func _process(delta):
	if Input.is_action_just_pressed("Atirar") and not is_attacking:
		atacar()

func atacar():
	is_attacking = true
	collision_shape.disabled = false
	animated_sprite.play("ataque_espada") 

func _on_animation_finished():
	if animated_sprite.animation == "ataque_espada": 
		is_attacking = false
		collision_shape.disabled = true
		animated_sprite.play("idle") 

func _on_body_entered(body):
	if is_attacking and body.is_in_group("inimigo"):
		pass
