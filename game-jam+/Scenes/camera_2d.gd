extends Camera2D

var players : Array[Node2D] = []

func _ready() -> void:
	Global.camera = self

func _process(_delta: float) -> void:
	var maxdistance = 1.7
	for i in players:
		if i.global_position.y > 500: i.take_damage()
		for j in players: if i != j:
			var a =  (i.global_position-j.global_position).length()
			if a > maxdistance: maxdistance = a
	setzoom(8/maxdistance**0.3)
	var mediumpos = Vector2(0,0)
	for i in players: mediumpos+=i.global_position
	mediumpos/=len(players)
	setpos(mediumpos)

func setzoom(n):
	n = min(n,2)
	zoom = (Vector2(n,n)+zoom*19)/20

func setpos(n):
	global_position = (n+global_position*19)/20
	if global_position.y > 60: global_position.y = 60
