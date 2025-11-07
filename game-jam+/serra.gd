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

func _on_pikcup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.append(self) # <-- CORRIGIDO para 'append'

func _on_pikcup_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.erase(self) # <-- CORRIGIDO para 'erase'
