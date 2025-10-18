extends Control

signal player_joined(player_id)
signal start_pressed

var confirmed_players = []
var join_keys = {
	1: "ui_join_p1",
	2: "ui_join_p2",
	3: "ui_join_p3",
	4: "ui_join_p4"
}

@onready var menu = $CanvasLayer/MenuBar

func _ready():
	print("Menu pronto — pressione C, V para entrar.")
	$CanvasLayer/Go.pressed.connect(_on_go_pressed)

func _input(event):
	for i in join_keys.keys():
		if Input.is_action_just_pressed(join_keys[i]) and i not in confirmed_players:
			confirmed_players.append(i)
			menu.get_child(i - 1).color = Color(0.6, 1, 0.2)
			emit_signal("player_joined", i)

func _on_go_pressed():
	if confirmed_players.size() >= 2:
		emit_signal("start_pressed")
