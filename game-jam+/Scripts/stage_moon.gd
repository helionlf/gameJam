extends Node2D


func _ready() -> void:
	Global.mundo = self


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.take_damage()
