extends Node2D

@onready var PlayerScene = preload("res://animacoes/gatito.tscn")
@onready var restart_timer = $RestartTimer
@onready var death_view_timer = $DeathViewTimer
@onready var end_game_timer = $EndGameTimer

const VIDA_INICIAL = 3

var skins = [
	preload("res://animacoes/gatito.png"),
	preload("res://animacoes/gatito_branco.png"),
	preload("res://animacoes/gatito_laranja.png")
]

var stages = [
	"res://Scenes/stage_moon.tscn",
	"res://Scenes/stage_preistorico.tscn",
	"res://Scenes/stage_medieval.tscn",
	"res://Scenes/stage_predio.tscn"
]

var spawn_positions = [
	[Vector2(-120, 100), Vector2(120, 100.0)],
	[Vector2(-253, -50), Vector2(-253, 59.0)], 
	[Vector2(-178, 178), Vector2(113, 178.0)], 
	[Vector2(-182, 133), Vector2(182, 133)], 
]

var current_stage_index = 0
var players = []
var game_started = false
var is_restarting = false

func _ready():
	restart_timer.timeout.connect(_on_restart_timer_timeout)
	death_view_timer.timeout.connect(_on_death_view_timer_timeout)
	end_game_timer.timeout.connect(_on_end_game_timer_timeout)

func _input(event):
	if event is InputEventMouseButton and event.pressed and not game_started:
		LifeManager.p1_life = VIDA_INICIAL
		LifeManager.p2_life = VIDA_INICIAL
		start_new_game()

func start_new_game() -> void:
	game_started = true
	is_restarting = false

	create_players()
	load_stage(current_stage_index)

func create_players() -> void:
	players.clear()

	var shuffled_skins = skins.duplicate()
	shuffled_skins.shuffle()

	var p1 = null
	var p2 = null

	if LifeManager.p1_life > 0:
		p1 = PlayerScene.instantiate()
		p1.player_id = 1
		p1.set_skin(shuffled_skins[0])
		p1.player_died.connect(_on_player_died)
		players.append(p1)

	if LifeManager.p2_life > 0:
		p2 = PlayerScene.instantiate()
		p2.player_id = 2
		var skin_index = 1 if p1 != null else 0
		if skin_index < shuffled_skins.size():
			p2.set_skin(shuffled_skins[skin_index])
		else:
			p2.set_skin(shuffled_skins[0])
		p2.player_died.connect(_on_player_died)
		players.append(p2)

func load_stage(index) -> void:
	for arma in get_tree().get_nodes_in_group("ArmaNoMundo"):
		arma.queue_free()

	var old_stage = null
	for child in get_children():
		if child.name.begins_with("Stage"):
			old_stage = child
			child.queue_free() # Marca a fase antiga para deleção
	
	if old_stage != null:
		await old_stage.tree_exited 
	# ------------------------------------
	#var stage = load(stages[index]).instantiate()
	#stage.name = "Stage_" + str(index + 1)
	#add_child(stage)
	
	var stage_path = stages[index]
	var stage = load(stage_path).instantiate()
	stage.name = "Stage_" + str(index + 1)
	add_child(stage)
	
	match stage_path:
		"res://Scenes/stage_moon.tscn":
			players[0].position = spawn_positions[0][0]
			players[1].position = spawn_positions[0][1]
		"res://Scenes/stage_preistorico.tscn":
			players[0].position = spawn_positions[1][0]
			players[1].position = spawn_positions[1][1]
		"res://Scenes/stage_medieval.tscn":
			players[0].position = spawn_positions[2][0]
			players[1].position = spawn_positions[2][1]
		"res://Scenes/stage_predio.tscn":
			players[0].position = spawn_positions[3][0]
			players[1].position = spawn_positions[3][1]
		_:
			# fallback
			players[0].position = Vector2(-120, 0)
			players[1].position = Vector2(120, 0)
	
	stage.add_child(players[0])
	stage.add_child(players[1])
	
	#if index < spawn_positions.size():
		#print("Tomara q n chegue aqui, mas ta tudo bem")
		#players[0].position = spawn_positions[index][0]
		#players[1].position = spawn_positions[index][1]
	#else:
		#print("Tomara q n chegue aqui, mas ta tudo bem")
		#players[0].position = Vector2(-120, 0)
		#players[1].position = Vector2(120, 0)
	#
	#print("aaaa")


func _on_player_died(id_do_jogador_que_morreu):
	if is_restarting or not game_started:
		return

	if id_do_jogador_que_morreu == 1:
		LifeManager.p1_life -= 1
		print("P1 tem ", LifeManager.p1_life, " vidas restantes.")
		if LifeManager.p1_life <= 0:
			print("Jogador 1 foi eliminado!")
	else:
		LifeManager.p2_life -= 1
		print("P2 tem ", LifeManager.p2_life, " vidas restantes.")
		if LifeManager.p2_life <= 0:
			print("Jogador 2 foi eliminado!")

	is_restarting = true
	print("Um jogador morreu! Esperando 2 segundos para reiniciar a rodada...")
	death_view_timer.start()

func _on_death_view_timer_timeout():
	print("Iniciando contagem de 1.5s para reiniciar...")
	restart_timer.start()

func _on_restart_timer_timeout() -> void:
	is_restarting = false
	await cleanup_and_start_round()

func cleanup_and_start_round() -> void:
	players.clear()

	var old_stage = null
	for child in get_children():
		if child.name.begins_with("Stage"):
			old_stage = child
			child.queue_free()

	if old_stage != null:
		await old_stage.tree_exited

	create_players()

	if players.is_empty():
		print("ERRO INESPERADO: Nenhum jogador criado após restart! Voltando ao menu...")
		get_tree().reload_current_scene()
		return

	load_stage(current_stage_index)

	if players.size() == 1:
		handle_game_over(players[0].player_id)

func handle_game_over(winner_id):
	print("🏁 FIM DE JOGO! Jogador ", winner_id, " venceu!")
	end_game_timer.start()

func _on_end_game_timer_timeout():
	game_started = false
	get_tree().reload_current_scene()

func next_stage():
	pass
