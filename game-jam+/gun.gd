extends Node2D

var cena_projetil = preload("res://projetil.tscn") 

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

func _process(delta):
	if Input.is_action_just_pressed("Atirar") and pode_atirar and municao > 0:
		atirar()

func atirar():
	pode_atirar = false
	municao -= 1
	
	$Timer.start()
	$AnimatedSprite2D.play("Atirando")
	
	var direcao_tiro = Vector2.RIGHT 
	
	if get_parent().scale.x < 0:
		direcao_tiro = Vector2.LEFT
	
	var novo_projetil = cena_projetil.instantiate() 
	get_tree().root.add_child(novo_projetil)
	novo_projetil.iniciar($Marker2D.global_position, direcao_tiro)
	
	if municao == 0:
		$AnimatedSprite2D.play("Desapearing")
		await get_tree().create_timer(.3)
		$TimerDesaparecer.start()

func desequipar():
	visible = false
	set_process(false)

func _on_timer_desaparecer_timeout():
	visible = false
	set_process(false)

func _on_timer_timeout():
	pode_atirar = true
