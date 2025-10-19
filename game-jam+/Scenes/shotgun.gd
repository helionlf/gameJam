extends Node2D

@onready var ray_center: RayCast2D = $offset/RayCastCenter
@onready var ray_up: RayCast2D = $offset/RayCastUp
@onready var ray_down: RayCast2D = $offset/RayCastDown

@onready var timer_cooldown = $Timer
@onready var offset: Node2D = $offset
@onready var animated_sprite: Sprite2D = $offset/AnimatedSprite2D
@onready var ponto_de_tiro: Marker2D = $offset/Marker2D

var municao: int = 2
var pode_atirar: bool = true
var equipada = false

func equipar():
	pode_atirar = true
	equipada = true
	offset.position = Vector2(5,-9)
	municao = 2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Atirar") and pode_atirar and municao > 0 and equipada:
		atirar()

var rot_tween : Tween

func atirar():
	$Shot.play()
	pode_atirar = false
	municao -= 1
	timer_cooldown.start()
	get_node("..").tilt()
	animated_sprite.rotation_degrees = -60
	if rot_tween: rot_tween.kill()
	rot_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	rot_tween.tween_property(animated_sprite,"rotation",0,0.3)
	checar_raio(ray_center)
	checar_raio(ray_up)
	checar_raio(ray_down)
	
	get_node("../..").speed-=1000*get_node("../..").orientation


func checar_raio(ray: RayCast2D):
	ray.force_raycast_update()
	var ponto_final_do_tiro
	if ray.is_colliding():
		var alvo = ray.get_collider()
		if alvo.is_in_group("player"):
			print(alvo)
			alvo.take_damage()
		ponto_final_do_tiro = ray.get_collision_point()
	else:
		ponto_final_do_tiro = ray.to_global(ray.target_position)

	var ponto_inicio_do_tiro = ponto_de_tiro.global_position
	
	Global.spawnricochete(ponto_final_do_tiro, ponto_inicio_do_tiro)

func _on_timer_timeout():
	pode_atirar = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.append(self)
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.erase(self)
