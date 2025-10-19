extends Node2D

signal arma_desapareceu

@onready var raycast: RayCast2D = $RayCast2D
@onready var timer_cooldown = $Timer
@onready var timer_desaparecer = $TimerDesaparecer
@onready var animated_sprite = $AnimatedSprite2D

var municao: int = 10
var pode_atirar: bool = true

func _ready():
	if get_parent() is RigidBody2D:
		visible = true
		set_process(true)
	else:
		visible = false 
		set_process(false)

func equipar_arma():
	visible = true
	set_process(true)
	municao = 10
	pode_atirar = true

func desequipar():
	visible = false
	set_process(false)

func _process(_delta):
	if get_parent() is RigidBody2D:
		return

	if Input.is_action_just_pressed("Atirar") and pode_atirar and municao > 0:
		atirar()

var rot_tween : Tween

func atirar():
	pode_atirar = false
	municao -= 1
	timer_cooldown.start()
	animated_sprite.play("Atirando")
	#var direcao_arma = 1
	#if get_parent().scale.x < 0:
		#direcao_arma = -1
	#raycast.target_position.x = 1000 * direcao_arma
	animated_sprite.rotation_degrees = -60
	if rot_tween: rot_tween.kill()
	rot_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	rot_tween.tween_property(animated_sprite,"rotation",0,0.3)
	
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var alvo = raycast.get_collider()
		if alvo.is_in_group("inimigo"):
			pass
			#
			# COLOQUE SEU CÓDIGO DE DANO AQUI
			# Ex: alvo.sofrer_dano(10)
			#
	
	if municao == 0:
		timer_desaparecer.start()

func _on_timer_timeout():
	pode_atirar = true

func _on_timer_desaparecer_timeout():
	$AnimatedSprite2D.play("Desapearing")
	await get_tree().create_timer(0.3).timeout
	
	visible = false
	set_process(false)
	arma_desapareceu.emit()
