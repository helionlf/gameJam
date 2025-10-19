extends Node2D


@onready var PlayerScene = preload("res://animacoes/gatito.tscn")

var skins = [
	preload("res://animacoes/gatito.png"),
	preload("res://animacoes/gatito_branco.png"),
	preload("res://animacoes/gatito_laranja.png") 
]

func _ready() -> void:
	Global.mundo = self
	start_tutorial()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func start_tutorial() -> void:
	var shuffled_skins = skins.duplicate()
	shuffled_skins.shuffle()
	
	var gatito = PlayerScene.instantiate()
	gatito.player_id = 1
	gatito.set_skin(shuffled_skins[0])
	
	self.add_child(gatito)
	gatito.position = Vector2(-120, 0)


func _on_texture_button_pressed() -> void:
	if $Control.visible:
		$Control.visible = false
	else:
		$Control.visible = true
	
