extends Node2D

signal arma_desapareceu

@onready var raycast: RayCast2D = $RayCast2D
@onready var timer_cooldown = $Timer
@onready var timer_desaparecer = $TimerDesaparecer
@onready var animated_sprite = $AnimatedSprite2D

var municao: int = 7
var pode_atirar: bool = true

func _ready():
	visible = false 
	set_process(false)

func equipar_arma():
	visible = true
	set_process(true)
	municao = 7
	pode_atirar = true

func desequipar():
	visible = false
	set_process(false)

func _process(delta):
	if Input.is_action_just_pressed("Atirar") and pode_atirar and municao > 0:
		atirar()

func atirar():
	pode_atirar = false
	municao -= 1
	
	timer_cooldown.start()
	animated_sprite.play("Atirando")
	
	var direcao_arma = 1
	if get_parent().scale.x < 0:
		direcao_arma = -1
		
	raycast.target_position.x = 1000 * direcao_arma
	
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var alvo = raycast.get_collider()
		
		if alvo.is_in_group("inimigo"):
			pass
			# Coloque seu código de dano aqui
			# Ex: alvo.sofrer_dano(10)
	
	if municao == 0:
		timer_desaparecer.start()

func _on_timer_timeout():
	pode_atirar = true

func _on_timer_desaparecer_timeout():
	animated_sprite.play("Desapearing")
	await get_tree().create_timer(0.3)
	
	visible = false
	set_process(false)
	arma_desapareceu.emit()
