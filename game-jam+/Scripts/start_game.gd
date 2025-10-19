extends Node2D

@onready var PlayerScene = preload("res://animacoes/gatito.tscn")
@onready var restart_timer = $RestartTimer
@onready var death_view_timer = $DeathViewTimer
@onready var end_game_timer = $EndGameTimer

const VIDA_INICIAL = 9

var skins = [
	preload("res://animacoes/gatito.png"),
	preload("res://animacoes/gatito_branco.png"),
	preload("res://animacoes/gatito_laranja.png")
]

# Lista original de fases
var all_stages = [
	"res://Scenes/stage_moon.tscn",
	"res://Scenes/stage_preistorico.tscn",
	"res://Scenes/stage_medieval.tscn",
	"res://Scenes/stage_predio.tscn"
]

var spawn_positions = [
	[Vector2(-120, 100), Vector2(120, 100.0)],
	[Vector2(-253, 170), Vector2(-253, 45)],
	[Vector2(-178, 178), Vector2(113, 178.0)],
	[Vector2(-182, 133), Vector2(182, 133)],
]

# Lista embaralhada para a ordem das fases
var shuffled_stages = []
var current_shuffled_index = 0

var players = []
var game_started = false
var is_restarting = false

func _ready():
	restart_timer.timeout.connect(_on_restart_timer_timeout)
	death_view_timer.timeout.connect(_on_death_view_timer_timeout)
	end_game_timer.timeout.connect(_on_end_game_timer_timeout)
	randomize()

func _input(event):
	if event is InputEventMouseButton and event.pressed and not game_started:
		$Music.play()
		LifeManager.p1_life = VIDA_INICIAL
		LifeManager.p2_life = VIDA_INICIAL
		start_new_game()

func start_new_game() -> void:
	game_started = true
	is_restarting = false

	# Embaralha as fases no início do jogo
	shuffled_stages = all_stages.duplicate()
	shuffled_stages.shuffle()
	current_shuffled_index = 0 # Começa na primeira fase embaralhada

	create_players()

	var stage_path = shuffled_stages[current_shuffled_index]
	var spawn_index = get_spawn_index_for_stage(stage_path)
	load_stage(stage_path, spawn_index)

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

func load_stage(stage_path, spawn_index) -> void:
	for arma in get_tree().get_nodes_in_group("ArmaNoMundo"):
		arma.queue_free()

	var old_stage = null
	for child in get_children():
		if child.name.begins_with("Stage"):
			old_stage = child
			child.queue_free()

	var stage = load(stage_path).instantiate()
	stage.name = "Stage_" + stage_path.get_file().get_basename()
	add_child(stage)

	for player_node in players:
		stage.add_child(player_node)

	# Usa Vector2 global_position para garantir
	if players.size() >= 1 and spawn_index < spawn_positions.size():
		players[0].global_position = spawn_positions[spawn_index][0]
	if players.size() == 2 and spawn_index < spawn_positions.size():
		players[1].global_position = spawn_positions[spawn_index][1]

	print("Stage Loaded: ", stage_path)


func _on_player_died(id_do_jogador_que_morreu):
	if is_restarting or not game_started:
		return

	var game_over = false
	var lives_remaining = 0

	if id_do_jogador_que_morreu == 1:
		lives_remaining = LifeManager.p1_life
		print("P1 tem ", lives_remaining, " vidas restantes.")
		if lives_remaining <= 0:
			game_over = true
			handle_game_over(2)
	else:
		lives_remaining = LifeManager.p2_life
		print("P2 tem ", lives_remaining, " vidas restantes.")
		if lives_remaining <= 0:
			game_over = true
			handle_game_over(1)

	if not game_over:
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

	# --- LÓGICA DE TROCA DE FASE A CADA RODADA ---
	# Avança para a próxima fase na lista embaralhada
	current_shuffled_index += 1
	# Se chegou ao fim da lista, volta para o início (loop)
	if current_shuffled_index >= shuffled_stages.size():
		current_shuffled_index = 0
		# Opcional: Embaralhar de novo se quiser uma nova ordem após o loop
		shuffled_stages.shuffle()

	var next_stage_path = shuffled_stages[current_shuffled_index]
	var next_spawn_index = get_spawn_index_for_stage(next_stage_path)
	load_stage(next_stage_path, next_spawn_index)
	# ---------------------------------------------

	# Verifica se o jogo acabou APÓS carregar a nova fase
	if players.size() == 1:
		handle_game_over(players[0].player_id)


func handle_game_over(winner_id):
	print("🏁 FIM DE JOGO! Jogador ", winner_id, " venceu!")
	end_game_timer.start()

func _on_end_game_timer_timeout():
	game_started = false
	get_tree().reload_current_scene()

func get_spawn_index_for_stage(stage_path):
	# Precisamos encontrar o índice na lista ORIGINAL para pegar a posição correta
	for i in range(all_stages.size()):
		if all_stages[i] == stage_path:
			return i
	return 0

func next_stage():
	pass
