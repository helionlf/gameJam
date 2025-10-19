extends Node2D

func _on_Btn1_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Botao 1 pressionado, indo para o cenario da lua")
		get_tree().change_scene_to_file("res://Scenes/stage_moon.tscn")

func _on_Btn2_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Botao 2 pressionado, indo para o cenario da arma")
		get_tree().change_scene_to_file("res://Gun.tscn")

func _on_Btn3_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Botao 3 pressionado, indo para o cenario da espada")
		get_tree().change_scene_to_file("res://sword.tscn")
