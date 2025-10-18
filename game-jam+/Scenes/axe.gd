extends Node2D


@onready var offset: Node2D = $Offset
@onready var pickup_collider: CollisionShape2D = $Offset/Area2D/CollisionShape2D

# --- Variáveis de Estado ---
var pode_atacar: bool = true
var equipada: bool = false 

func equipar():
	pode_atacar = true
	equipada = true
	offset.position = Vector2(-10, -20) 
	offset.rotation_degrees = -90
	pickup_collider.disabled = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Atirar") and pode_atacar and equipada:
		atacar()

func atacar():
	pode_atacar = false
	var tween = create_tween().set_trans(Tween.TRANS_EXPO)
	tween.tween_property(offset,"position", Vector2(25,-8),0.1).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(offset,"rotation_degrees", 50,0.1).set_ease(Tween.EASE_IN)
	tween.tween_property(offset,"position", Vector2(-10, -20),0.3).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(offset,"rotation_degrees", -90, 0.3).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(0.4).timeout
	pode_atacar = true


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.append(self)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.erase(self)
