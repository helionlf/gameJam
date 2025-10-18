extends Node2D

@onready var PlayerScene = preload("res://animacoes/gatito.tscn")

var skins = [
	preload("res://animacoes/gatito.png"),
	preload("res://animacoes/gatito_branco.png"),
	preload("res://animacoes/gatito_laranja.png")   
]

var stages = [
	"res://animacoes/world.tscn"
	#"res://Scenes/stage_moon.tscn",
	#"res://stages/Stage2.tscn",
	#"res://stages/Stage3.tscn",
	#"res://stages/Stage4.tscn"
]

var current_stage_index = 0
var players = []
var game_started = false

func _input(event):
	if event is InputEventMouseButton and event.pressed and not game_started:
		start_game()

func start_game():
	game_started = true

	stages.shuffle()
	var shuffled_skins = skins.duplicate()
	shuffled_skins.shuffle()

	var p1 = PlayerScene.instantiate()
	p1.player_id = 1
	p1.set_skin(shuffled_skins[0])

	var p2 = PlayerScene.instantiate()
	p2.player_id = 2
	p2.set_skin(shuffled_skins[1])

	players = [p1, p2]

	load_stage(current_stage_index)

func load_stage(index):
	for child in get_children():
		if child.name.begins_with("Stage"):
			child.queue_free()

	var stage = load(stages[index]).instantiate()
	stage.name = "Stage_" + str(index + 1)
	add_child(stage)

	stage.add_child(players[0])
	stage.add_child(players[1])

	players[0].position = Vector2(100, 0)
	players[1].position = Vector2(-100, 0)

func next_stage():
	current_stage_index += 1
	if current_stage_index < stages.size():
		load_stage(current_stage_index)
	else:
		print("🏁 Jogo finalizado!")
		#Voltar ao menu
