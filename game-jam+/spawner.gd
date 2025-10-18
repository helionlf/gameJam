# spawner.gd
extends Node2D

@export var scene_para_spawnar: PackedScene

@onready var timer_respawn = $Timer
@onready var ponto_spawn = $PontoSpawn

var item_spawnado_atual = null

func _ready():
	$AnimatedSprite2D.play("default")
	timer_respawn.timeout.connect(_on_timer_timeout)
	spawnar_item()
	print("oi")
	

func spawnar_item():
	if scene_para_spawnar == null:
		print("Erro no Spawner: Nenhuma cena foi definida no inspetor!")
		return
	
	if item_spawnado_atual != null and is_instance_valid(item_spawnado_atual):
		return

	var novo_item = scene_para_spawnar.instantiate()
	
	novo_item.global_position = ponto_spawn.global_position
	
	get_parent().add_child.call_deferred(novo_item)

	item_spawnado_atual = novo_item
	
	novo_item.tree_exiting.connect(_on_item_foi_pego)

	print("SUCESSO: Spawner criou ", novo_item.name, " na posição ", novo_item.global_position)


func _on_item_foi_pego():
	item_spawnado_atual = null
	$Timer.start()

func _on_timer_timeout() -> void:
	spawnar_item()
