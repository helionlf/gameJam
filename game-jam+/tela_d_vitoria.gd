extends ColorRect

@onready var winner_label: Label = $Label

func _ready() -> void:
	winner_label.text = [0,"Player 1 Venceu!", "Player 2 Venceu!"][Global.quemganhou]


func _on_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/start_screen.tscn")
  
