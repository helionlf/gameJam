extends Area2D

const VELOCIDADE_ARREMESSO = 1500.0

@onready var animated_sprite = $offset/AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var velocity = Vector2.ZERO
var equipada: bool = false
var is_thrown: bool = false
var is_stuck: bool = false

func _ready():
	set_process(false)
	monitoring = true
	monitorable = true

func equipar():
	equipada = true
	is_thrown = false
	is_stuck = false
	set_process(false)

	rotation = 0
	animated_sprite.rotation = 0
	position = Vector2(20, -15)

	monitoring = false
	monitorable = false

	set_process_input(true)

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

	var pos_inicio = global_position
	var direcao = Vector2(get_parent().scale.x, 0).normalized()

	reparent(get_tree().root)
	global_position = pos_inicio

	velocity = direcao * VELOCIDADE_ARREMESSO
	rotation = direcao.angle()

	monitoring = true
	monitorable = true
	set_process(true)

func _process(delta):
	if is_thrown:
		global_position += velocity * delta

func _on_body_entered(body: Node2D):
	if is_thrown:
		if body.is_in_group("player"):
			body.take_damage()
		stick()
	elif not equipada and body.is_in_group("player"):
		body.hovering.append(self)

func _on_body_exited(body: Node2D):
	if not equipada and body.is_in_group("player"):
		body.hovering.erase(self)

func stick():
	if is_stuck or not is_thrown:
		return

	is_thrown = false
	is_stuck = true
	set_process(false)
	velocity = Vector2.ZERO

	monitoring = true
	monitorable = true
