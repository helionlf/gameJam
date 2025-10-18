
extends Node2D

var cena_projetil = preload("res://projetil.tscn")


func _process(delta):
	if Input.is_action_just_pressed("Atirar"):
		atirar()

func atirar():
	var novo_projetil = cena_projetil.instantiate()
	$AnimatedSprite2D.play("Atirando")
	get_tree().root.add_child(novo_projetil)
	
	novo_projetil.global_position = $Marker2D.global_position
