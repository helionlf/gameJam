extends Node2D

@onready var offset: Node2D = $offset
@onready var area_2d: Area2D = $offset/Area2D
var equipada = false
var jogando = false

var sprite = "res://Sprites/kunai.png"

func equipar():
	equipada = true
	offset.position = Vector2(-15,-13)
	area_2d.set_collision_mask_value(1,true)
	area_2d.set_collision_mask_value(2,false)

func _process(delta: float) -> void:
	if jogando: global_position.y+=delta*50

func atirar():
	reparent(get_node("../../.."))
	var p = offset.global_position
	offset.position = Vector2(0,0)
	global_position = p
	jogando = true
	global_skew = 0

func boom():
	for i in 12:
		Global.fire(get_node("../.."),5,20,50,global_position-Vector2(0,+15),i*30,get_node("../.."))
	Global.kaboom(get_parent(),global_position)
	queue_free()

func usar():
	atirar()

func arremessar():
	atirar()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hover(self)
	if jogando: boom()
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.erase(self)
