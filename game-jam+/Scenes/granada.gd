extends CharacterBody2D

const GRAVIDADE = 1000.0
const VELOCIDADE_ARREMESSO_X = 500.0
const VELOCIDADE_ARREMESSO_Y = -300.0

@onready var offset = $offset
@onready var animated_sprite = $offset/AnimatedSprite2D
@onready var pickup_area = $Area2D
@onready var explosion_area = $Explosion
@onready var physics_collider = $CollisionShape2D
@onready var grace_timer = $GraceTimer # <-- 1. Adicione a referência

var equipada: bool = false
var is_exploding: bool = false
var pode_explodir: bool = false # <-- 2. Adicione esta trava

func _ready():
	set_physics_process(false) 
	physics_collider.disabled = true
	explosion_area.monitoring = false 
	
	animated_sprite.play("Ovo") 
	
	pickup_area.body_entered.connect(_on_area_2d_body_entered)
	pickup_area.body_exited.connect(_on_area_2d_body_exited)

func equipar():
	equipada = true
	set_physics_process(false) 
	offset.position = Vector2(30, -9) 
	pickup_area.queue_free()
	physics_collider.disabled = true
	set_process_input(true)

func _input(event: InputEvent):
	if event.is_action_pressed("Atirar") and equipada:
		arremessar()

func arremessar():
	equipada = false
	set_process_input(false)
	
	var jogador = get_parent().get_parent() 
	if jogador:
		jogador.desequipar()

	var pos_global_atual = global_position
	var direcao_arremesso = Vector2(get_parent().scale.x, 0).normalized()

	reparent(get_tree().root)
	global_position = pos_global_atual
	add_to_group("arma_no_mundo") 
	
	set_physics_process(true)
	physics_collider.disabled = false
	
	velocity.x = direcao_arremesso.x * VELOCIDADE_ARREMESSO_X
	velocity.y = VELOCIDADE_ARREMESSO_Y
	
	grace_timer.start() # <-- 3. Inicia o timer de 0.2s

func _physics_process(delta):
	velocity.y += GRAVIDADE * delta
	move_and_slide()
	
	# 4. Adiciona a checagem "pode_explodir"
	if get_slide_collision_count() > 0 and pode_explodir:
		explodir()
		
	for i in get_slide_collision_count():
		var colisao = get_slide_collision(i)
		# 4. Adiciona a checagem "pode_explodir"
		if colisao.get_collider().is_in_group("player") and pode_explodir:
			explodir()

# --- 5. Adicione esta nova função ---
func _on_grace_timer_timeout():
	pode_explodir = true

# --- Estado 4: Explosão ---
func explodir():
	if is_exploding:
		return
		
	is_exploding = true
	set_physics_process(false) 
	velocity = Vector2.ZERO
	physics_collider.disabled = true
	
	animated_sprite.play("Explosao") 
	
	# Liga a área de dano (Explosion)
	explosion_area.monitoring = true
	
	await get_tree().create_timer(0.01).timeout
	
	for body in explosion_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage()
	
	await get_tree().create_timer(0.5).timeout
	queue_free()

# --- Lógica de Pickup ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.append(self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.erase(self)
