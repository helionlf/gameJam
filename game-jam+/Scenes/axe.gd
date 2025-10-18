extends Area2D

# --- Referências ---
@onready var timer_cooldown = $Timer
@onready var offset: Node2D = $Offset
@onready var animated_sprite: AnimatedSprite2D = $offset/AnimatedSprite2D
@onready var pickup_collider = $CollisionShape2D 

# --- Variáveis de Estado ---
var pode_atacar: bool = true
var equipada: bool = false 

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func equipar():
	pode_atacar = true
	equipada = true
	
	offset.position = Vector2(30, -9) 
	
	pickup_collider.disabled = true

# --- Input de Ataque ---
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Atirar") and pode_atacar and equipada:
		atacar()

# --- Função de Ataque (Simplificada) ---
func atacar():
	pode_atacar = false
	timer_cooldown.start()

func _on_timer_timeout():
	pode_atacar = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.append(self)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.erase(self)
