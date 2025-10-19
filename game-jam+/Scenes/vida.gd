extends Control

@export var player_id : int = 1

@onready var hearts_container = $MarginContainer/HeartsContainer 

var heart_full_texture = preload("res://Sprites/Heart (1).png") #
var heart_empty_texture = preload("res://Sprites/Heartless (1).png") 

func _ready():
	LifeManager.life_changed.connect(_on_life_changed)

	var initial_life = LifeManager.p1_life if player_id == 1 else LifeManager.p2_life
	update_hearts(initial_life)

func update_hearts(current_life):
	var hearts = hearts_container.get_children()
	var max_hearts = hearts.size()

	for i in range(max_hearts):
		if i < current_life:
			hearts[i].texture = heart_full_texture
			hearts[i].visible = true
		else:
			hearts[i].texture = heart_empty_texture
			

func _on_life_changed(p_id, new_life):
	if p_id == player_id:
		update_hearts(new_life)
