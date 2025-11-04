extends Node2D

@onready var raycast: RayCast2D = $offset/RayCast2D
@onready var offset: Node2D = $offset

@onready var animated_sprite: AnimatedSprite2D = $offset/AnimatedSprite2D

var municao: int = 7
var pode_atirar: bool = true
var equipada = false

var sprite = "res://animacoes/soapistola.png"

func equipar():
	pode_atirar = true
	equipada = true
	offset.position = Vector2(25,-9)

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("Atirar") and pode_atirar and municao > 0 and equipada:
		#atirar()

var rot_tween : Tween

func atirar():
	$Shot.play()
	pode_atirar = false
	municao -= 1
	animated_sprite.play("Atirando")
	get_node("..").tilt()
	animated_sprite.rotation_degrees = -60
	if rot_tween: rot_tween.kill()
	rot_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	rot_tween.tween_property(animated_sprite,"rotation",0,0.3)
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var alvo = raycast.get_collider()
		if alvo.is_in_group("player"):
			print(alvo)
			alvo.take_damage()
		elif alvo.is_in_group("tilemap"):
			print(alvo)
			alvo.set_cell(alvo.local_to_map(alvo.to_local(raycast.get_collision_point()+Vector2(get_node("../..").orientation,0))))
		var a = raycast.get_collision_point()
		Global.spawnricochete(a,global_position-Vector2(0,+15))
	else:
		Global.spawnricochete(Vector2(get_node("../..").orientation*1000+global_position.x,global_position.y-17),global_position-Vector2(0,+15))
	get_node("../..").speed-=400*get_node("../..").orientation
	await get_tree().create_timer(0.2).timeout
	pode_atirar = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.append(self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.erase(self)

func usar():
	if pode_atirar and municao > 0 and equipada:
		atirar()

func arremessar():
	pass
