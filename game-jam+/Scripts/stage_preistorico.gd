extends Node2D


func _ready() -> void:
	Global.mundo = self
	$Musica.play()
