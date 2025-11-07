extends CharacterBody2D

const VELOCIDADE_ARREMESSO = 1500.0
const MAX_RANGE = 1500.0

@onready var sprite_offset = $offset
@onready var animated_sprite = $offset/AnimatedSprite2D
@onready var pickup_area = $PickupArea
@onready var physics_collider = $CollisionShape2D
@onready var raycast = $RayCast2D

var equipada: bool = false
var is_thrown: bool = false
var is_stuck: bool = false
var current_tween: Tween

func _ready():
	set_physics_process(false)
	physics_collider.disabled = true
	pickup_area.monitoring = true

func equipar():
	equipada = true
	is_thrown = false
	is_stuck = false
	set_physics_process(false)

	if current_tween:
		current_tween.kill()
		current_tween = null

	sprite_offset.position = Vector2.ZERO
	sprite_offset.rotation = 0
	animated_sprite.position = Vector2.ZERO
	animated_sprite.rotation = 0


	pickup_area.monitoring = false
	physics_collider.disabled = true

	set_process_input(true)
	raycast.clear_exceptions()

func _input(event: InputEvent):
	if event.is_action_pressed("Atirar") and equipada:
		arremessar()

func arremessar():
	equipada = false
	is_thrown = true
	is_stuck = false
	set_process_input(false)

	var jogador = get_parent().get_parent()
	if jogador:
		jogador.desequipar()

	# --- CORREÇÃO DE DIREÇÃO ---
	# Pega a orientação (1 ou -1) diretamente do jogador
	var direcao_numerica = get_parent().scale.x # Pega a escala do anim_control
	if jogador: # Se temos o jogador, usa a variável dele que é mais segura
		direcao_numerica = jogador.orientation
	var direcao = Vector2(direcao_numerica, 0)
	# --------------------------
	var pos_inicio = global_position + direcao * 5.0 


	reparent(get_tree().root)
	global_position = pos_inicio
	add_to_group("arma_no_mundo")

	raycast.target_position = direcao * MAX_RANGE

	if jogador:
		raycast.add_exception(jogador)

	raycast.force_raycast_update()

	var ponto_final
	var hit_something = false
	var hit_opponent_player = false
	var target_node = null

	if raycast.is_colliding():
		hit_something = true
		ponto_final = raycast.get_collision_point()
		target_node = raycast.get_collider()
		if target_node.is_in_group("player"):
			hit_opponent_player = true
	else:
		ponto_final = raycast.to_global(raycast.target_position)

	var distance = pos_inicio.distance_to(ponto_final)
	var duration = 0.1
	if VELOCIDADE_ARREMESSO > 0:
		duration = max(0.01, distance / VELOCIDADE_ARREMESSO)
	rotation = direcao.angle()


	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	# Move o NÓ RAIZ
	current_tween.tween_property(self, "global_position", ponto_final, duration).set_trans(Tween.TRANS_LINEAR)
	await current_tween.finished
	current_tween = null
	is_thrown = false
	if hit_opponent_player and target_node != null:
		target_node.take_damage()
		stick_in_wall(ponto_final)
	elif hit_something:
		stick_in_wall(ponto_final)
	else:
		stick_in_wall(ponto_final)

func stick_in_wall(posicao_final):
	if is_stuck:
		return
	is_thrown = false
	is_stuck = true
	set_physics_process(false)
	velocity = Vector2.ZERO
	global_position = posicao_final
	pickup_area.monitoring = true
	raycast.clear_exceptions()

func _on_pickup_area_body_entered(body: Node2D):
	if not equipada and body.is_in_group("player"):
		body.hovering.append(self)

func _on_pickup_area_body_exited(body: Node2D):
	if body.is_in_group("player"):
		body.hovering.erase(self)
