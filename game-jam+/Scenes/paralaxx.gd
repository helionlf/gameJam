extends TileMapLayer

@export var cameradistance = 1.0


func _process(_delta: float) -> void:
	if Global.camera:
		global_position = Global.camera.global_position * cameradistance
