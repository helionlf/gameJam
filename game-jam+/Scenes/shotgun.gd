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

var sprite = "res://Sprites/Shotgun.png"

func equipar():
	pode_atirar = true
	equipada = true
	offset.position = Vector2(5,-9)
	municao = 2

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
	checar_raio(ray_center,2)
	checar_raio(ray_up,2)
	checar_raio(ray_down,2)
	get_node("../..").speed-=1000*get_node("../..").orientation

func checar_raio(ray: RayCast2D, dano): # dando erro quando dois raios vao checar o mesmo bloco com 0 de vida por algum motivo
	ray.force_raycast_update()
	var ponto_final_do_tiro
	if ray.is_colliding():
		var alvo = ray.get_collider()
		if alvo.is_in_group("player"):
			alvo.take_damage()
		elif alvo.is_in_group("tilemap"):
			var remaining = alvo.get_parent().damage(ray.get_collision_point()+Vector2(get_node("../..").orientation,0),dano)
			if remaining[1]:
				
				ray_center.add_exception(remaining[1])
				ray_down.add_exception(remaining[1])
				ray_up.add_exception(remaining[1])
			if remaining[0]:
				checar_raio(ray,remaining[0])
				return
		ponto_final_do_tiro = ray.get_collision_point()
	else:
		ponto_final_do_tiro = ray.to_global(ray.target_position)
	var ponto_inicio_do_tiro = ponto_de_tiro.global_position
	Global.spawnricochete(ponto_final_do_tiro, ponto_inicio_do_tiro)

func _on_timer_timeout():
	pode_atirar = true

func usar():
	if pode_atirar and municao > 0 and equipada:
		atirar()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hover(self)
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.erase(self)
