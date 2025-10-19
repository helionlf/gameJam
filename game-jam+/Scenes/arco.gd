extends Node2D

# --- Referências ---
@onready var timer_cooldown = $Timer 
@onready var offset: Node2D = $offset
@onready var animated_sprite: AnimatedSprite2D = $offset/AnimatedSprite2D
@onready var pickup_area: Area2D = $Area2D

# Carrega a cena da Flecha
var flecha_scene = preload("res://Scenes/flecha.tscn")


var equipada = false
var is_charging = false 
var charge_power = 0.0 

# --- Constantes de Força ---
const MIN_POWER = 200.0 
const MAX_POWER = 1000.0 
const CHARGE_RATE = 700.0 

func _ready():

	pickup_area.body_entered.connect(_on_area_2d_body_entered)
	pickup_area.body_exited.connect(_on_area_2d_body_exited)
	
	# Começa desligado
	set_process(false)
	set_process_input(false)

func equipar():
	equipada = true
	offset.position = Vector2(30,-9)
	
	pickup_area.queue_free()
	
	set_process_input(true)
	set_process(true)

func _input(event: InputEvent) -> void:
	if not equipada:
		return

	if event.is_action_pressed("Atirar"):
		is_charging = true
		charge_power = MIN_POWER 
		animated_sprite.play("puxando_arco") 

	if event.is_action_released("Atirar"):
		if is_charging:
			atirar()
			is_charging = false
			charge_power = 0.0
			animated_sprite.play("idle")

func _process(delta):
	if is_charging:
		charge_power = min(charge_power + CHARGE_RATE * delta, MAX_POWER)

func atirar():
	
	var direcao = Vector2(get_node("..").scale.x, 0).normalized()
	
	var flecha = flecha_scene.instantiate()
	
	get_tree().root.add_child(flecha)
	
	var spawn_pos = $offset.global_position 
	
	# Dispara a flecha!
	flecha.iniciar(spawn_pos, direcao, charge_power)
	
	get_node("..").tilt()
	get_node("../..").speed -= (charge_power / 3) * get_node("../..").orientation

# --- Lógica de Pickup (Idêntica à sua arma) ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.append(self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.erase(self)
