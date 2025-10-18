
extends Area2D

var velocidade = 500

func _process(delta):
	position.x += velocidade * delta
