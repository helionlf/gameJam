# spawner.gd
extends Node2D

@onready var timer_respawn = $Timer
@onready var ponto_spawn = $PontoSpawn

var item_spawnado_atual = null

func _ready():
	await get_tree().create_timer(2).timeout
	spawnar_item()


func _process(delta: float) -> void:
	$AnimatedSprite2D.rotation -= delta * 10

func spawnar_item():
	if item_spawnado_atual != null:
		return
	#var novo_item = load(["res://Scenes/shotgun.tscn","res://New_Gun.tscn","res://Scenes/axe.tscn","res://kunai.tscn"].pick_random()).instantiate()
	
	var novo_item = load(["res://kunai.tscn"].pick_random()).instantiate()
	novo_item.global_position = ponto_spawn.global_position
	get_parent().add_child.call_deferred(novo_item)
	item_spawnado_atual = novo_item
	print("spawno")
	novo_item.tree_exiting.connect(_on_item_foi_pego)

func _on_item_foi_pego():
	if item_spawnado_atual != null:
		item_spawnado_atual.tree_exiting.disconnect(_on_item_foi_pego)
	item_spawnado_atual = null
	timer_respawn.start()

func _on_timer_timeout() -> void:
	spawnar_item()
