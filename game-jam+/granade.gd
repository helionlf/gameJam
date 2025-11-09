extends Node2D

const THROWNGRANADE = preload("uid://bk5wc8vx17nxv")

@onready var offset: Node2D = $offset
@onready var area_2d: Area2D = $offset/Area2D
var equipada = false
var jogando = false

var sprite = "res://Sprites/kunai.png"

var timeleft = 2.0
var ticking = false

func _process(delta: float) -> void:
	if ticking:
		timeleft-=delta
		if timeleft <= 0:
			jogar(0)

func equipar():
	equipada = true
	offset.position = Vector2(-15,-13)
	area_2d.set_collision_mask_value(1,true)
	area_2d.set_collision_mask_value(2,false)

func atirar():
	ticking = true
	$offset/Sprite2D.play("ticking")
func jogar(t):
	get_node("../..").desequipar()
	var a = THROWNGRANADE.instantiate()
	get_node("../../..").add_child(a)
	a.dothrow(global_position,Vector2(get_node("../..").orientation*500,-100),get_node("../..").orientation,t)
	queue_free()

func usar():
	if ticking: arremessar()
	else:atirar()

func arremessar():
	jogar(timeleft)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hover(self)
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hovering.erase(self)
