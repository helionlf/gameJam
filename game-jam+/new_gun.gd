extends Node2D

@onready var raycast: RayCast2D = $offset/RayCast2D
@onready var timer_cooldown = $Timer
@onready var offset: Node2D = $offset

@onready var animated_sprite: AnimatedSprite2D = $offset/AnimatedSprite2D

var municao: int = 10
var pode_atirar: bool = true
var equipada = false
var player_dentro = null

func equipar():
	pode_atirar = true
	equipada = true
	offset.position = Vector2(30,-9)
	if $Area2D:
		$Area2D.queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Atirar") and pode_atirar and municao > 0 and equipada:
		atirar()

var rot_tween : Tween

func atirar():
	pode_atirar = false
	#municao -= 1
	timer_cooldown.start()
	animated_sprite.play("Atirando")
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
		var a = raycast.get_collision_point()
		Global.spawnricochete(a,global_position)
	get_node("../../").speed-=400*get_node("../../").orientation

func _on_timer_timeout():
	pode_atirar = true

func _process(_delta):
	if player_dentro != null and Input.is_action_just_pressed("pegar_p1") and not equipada:
		player_dentro.equipar(self)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_dentro = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body == player_dentro:
		player_dentro = null
