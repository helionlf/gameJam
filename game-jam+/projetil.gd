
extends Area2D

var velocidade = 1000

func _process(delta):
	position.x += velocidade * delta
