extends Node2D

@onready var PlayerScene = preload("res://animacoes/gatito.tscn")
@onready var restart_timer = $RestartTimer 
@onready var death_view_timer = $DeathViewTimer

const VIDA_INICIAL = 3

var skins = [
	preload("res://animacoes/gatito.png"),
	preload("res://animacoes/gatito_branco.png"),
	preload("res://animacoes/gatito_laranja.png") 
]

var stages = [
	"res://Scenes/stage_moon.tscn",
	"res://Scenes/stage_preistorico.tscn"
]

var spawn_positions = [
	[Vector2(-120, 0), Vector2(120, 100.0)],
	[Vector2(-253, -50), Vector2(-253, 59.0)], 
]

var current_stage_index = 0
var players = []
var game_started = false
var is_restarting = false # <-- ADICIONADO (Evita que os 2 players morrendo ativem isso 2x)

func _ready(): 
	restart_timer.timeout.connect(_on_restart_timer_timeout)
	death_view_timer.timeout.connect(_on_death_view_timer_timeout) # <-- ADICIONADO

func _input(event):
	if event is InputEventMouseButton and event.pressed and not game_started:
		start_game()

func start_game() -> void:
	game_started = true
	stages.shuffle()
	LifeManager.p1_life = VIDA_INICIAL
	LifeManager.p2_life = VIDA_INICIAL
	var shuffled_skins = skins.duplicate()
	shuffled_skins.shuffle()
	
	players.clear() 
	
	var p1 = PlayerScene.instantiate()
	p1.player_id = 1
	p1.set_skin(shuffled_skins[0])
	p1.player_died.connect(_on_player_died) 
	var p2 = PlayerScene.instantiate()
	p2.player_id = 2
	p2.set_skin(shuffled_skins[1])
	p2.player_died.connect(_on_player_died) 
	
	players = [p1, p2]
	
	await load_stage(current_stage_index)

func load_stage(index) -> void:
	
	# --- Limpeza (como você já tem) ---
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


func _on_player_died(_player_node):

	if is_restarting:
		return
	
	is_restarting = true
	print("Um jogador morreu! Esperando 2 segundos para reiniciar...")
	
	death_view_timer.start()


func _on_death_view_timer_timeout():
	get_tree().paused = true
	print("Pausando! Iniciando contagem de 1.5s para reiniciar...")

	restart_timer.start()

func _on_restart_timer_timeout() -> void:
	get_tree().paused = false
	is_restarting = false 

	await start_game()


func next_stage():
	current_stage_index += 1
	if current_stage_index < stages.size():
		load_stage(current_stage_index)
	else:
		print("🏁 Jogo finalizado!")
