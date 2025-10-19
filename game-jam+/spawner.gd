# spawner.gd
extends Node2D

var scene_para_spawnar

@onready var timer_respawn = $Timer
@onready var ponto_spawn = $PontoSpawn

var item_spawnado_atual = null

func _ready():
	await get_tree().create_timer(2).timeout
	spawnar_item()


func _process(delta: float) -> void:
	$AnimatedSprite2D.rotation -= delta * 10

func spawnar_item():
	if scene_para_spawnar == null:
		print("Erro no Spawner: Nenhuma cena foi definida no inspetor!")
		return
	
	if item_spawnado_atual != null and is_instance_valid(item_spawnado_atual):
		return

	var novo_item = load(["res://Scenes/shotgun.tscn","res://New_Gun.tscn","res://Scenes/axe.tscn"].pick_random()).instantiate()
	
	novo_item.global_position = ponto_spawn.global_position

	
	
	get_parent().add_child.call_deferred(novo_item)
	item_spawnado_atual = novo_item
	print("spawno")
	
	novo_item.tree_exiting.connect(_on_item_foi_pego)

func _on_item_foi_pego():
	item_spawnado_atual = null
	timer_respawn.start()

func _on_timer_respawn_timeout():
	spawnar_item()
