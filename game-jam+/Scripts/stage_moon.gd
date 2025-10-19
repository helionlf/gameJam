extends Node2D


func _ready() -> void:
	Global.mundo = self
	$Musica.play()


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.take_damage()
