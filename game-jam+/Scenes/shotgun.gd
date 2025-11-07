extends Node2D

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
	boom(2)
	get_node("../..").speed-=1000*get_node("../..").orientation

func boom(dano): # dando erro quando dois raios vao checar o mesmo bloco com 0 de vida por algum motivo
	Global.spawnricochete(Global.fire(get_node("../.."),dano,5,3000,global_position-Vector2(0,+15),global_rotation,get_node("../..")),global_position-Vector2(0,+15))
	Global.spawnricochete(Global.fire(get_node("../.."),dano,5,3000,global_position-Vector2(0,+15),global_rotation+PI/12,get_node("../..")),global_position-Vector2(0,+15))
	Global.spawnricochete(Global.fire(get_node("../.."),dano,5,3000,global_position-Vector2(0,+15),global_rotation-PI/12,get_node("../..")),global_position-Vector2(0,+15))


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
