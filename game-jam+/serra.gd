extends RigidBody2D

# --- Constantes de Física (Comentadas por enquanto) ---
# const GRAVIDADE = 1000.0
# const VELOCIDADE_ARREMESSO = 700.0
# const POTENCIA_KICK = 400.0

# --- Referências ---
@onready var offset = $offset
@onready var animated_sprite = $offset/AnimatedSprite2D
@onready var pickup_area: Area2D = $offset/PikcupArea
# @onready var damage_area = $DamageArea # (Comentado)
@onready var physics_collider = $CollisionShape2D 

# --- Variáveis de Estado (Igual à Arma) ---
var equipada: bool = false 

func _ready():
	freeze = true


# --- Estado 2: Segurada (Igual à Arma) ---
func equipar():
	equipada = true 
	set_physics_process(false) 
	
	# Posição de "segurar"
	offset.position = Vector2(30, -20) 
	
	pickup_area.queue_free()
	physics_collider.disabled = true
	
	# Não liga o input, pois não vamos arremessar
	# set_process_input(true) # (Comentado)

# --- Ouvir o Arremesso (Comentado) ---
# func _input(event: InputEvent):
	# if event.is_action_pressed("Atirar") and equipada: 
		# arremessar()

# --- Estado 3: Arremessada (Comentado) ---
# func arremessar():
	# equipada = false 
	# set_process_input(false)
	# var jogador = get_parent().get_parent() 
	# if jogador:
		# jogador.desequipar()

	# var pos_global_atual = global_position
	# var direcao_arremesso = Vector2(get_parent().scale.x, 0).normalized()

	# reparent(get_tree().root)
	# global_position = pos_global_atual
	
	# set_physics_process(true)
	# physics_collider.disabled = false
	# damage_area.monitoring = true
	
	# velocity.x = direcao_arremesso.x * VELOCIDADE_ARREMESSO
	# velocity.y = -200.0
	
	# animated_sprite.play("girando")

# --- Loop de Física (Comentado) ---
# func _physics_process(delta):
	# if not is_on_floor():
		# velocity.y += GRAVIDADE * delta
	
	# move_and_slide()
	
	# if get_slide_collision_count() > 0:
		# var colisao = get_slide_collision(0)
		# if colisao.get_normal().y < -0.5:
			# velocity.y = -POTENCIA_KICK
		# else:
			# velocity.x = velocity.bounce(colisao.get_normal()).x

# --- Lógica de Dano (Comentado) ---
# func _on_damage_area_body_entered(body: Node2D):
	# if body.is_in_group("player"):
		# body.take_damage()

# --- Lógica de Pickup (CORRIGIDA) ---
# Esta parte é a única que fica ativa, junto com equipar()
func _on_pikcup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.append(self) # <-- CORRIGIDO para 'append'

func _on_pikcup_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.erase(self) # <-- CORRIGIDO para 'erase'
