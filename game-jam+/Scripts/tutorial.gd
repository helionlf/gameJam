extends Node2D


@onready var PlayerScene = preload("res://animacoes/gatito.tscn")
@onready var btn = $Control/TextureButton

var skins = [
	preload("res://animacoes/gatito.png"),
	preload("res://animacoes/gatito_branco.png"),
	preload("res://animacoes/gatito_laranja.png") 
]

func _ready() -> void:
	Global.mundo = self
	start_tutorial()
	btn.text = "Esconder"
	

func _process(delta: float) -> void:
	if $Control/p1_controles.visible and $Control/p2_controles.visible:
		btn.text = "Esconder"
	else:
		btn.text = "Mostrar"


func start_tutorial() -> void:
	var shuffled_skins = skins.duplicate()
	shuffled_skins.shuffle()
	
	var gatito = PlayerScene.instantiate()
	gatito.player_id = 1
	gatito.set_skin(shuffled_skins[0])
	add_child(gatito)
	
	gatito.position = Vector2(-120, 0)
	
	gatito = PlayerScene.instantiate()
	gatito.player_id = 2
	gatito.set_skin(shuffled_skins[0])
	add_child(gatito)
	
	gatito.position = Vector2(120, 0)


func _on_texture_button_pressed() -> void:
	if $Control/p1_controles.visible and $Control/p2_controles.visible:
		$Control/p1_controles.visible = false
		$Control/p2_controles.visible = false
	else:
		$Control/p1_controles.visible = true
		$Control/p2_controles.visible = true
	


func _on_sair_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/start_screen.tscn")
