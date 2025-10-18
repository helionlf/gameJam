extends Area2D

var player_dentro = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_dentro = body

func _on_body_exited(body):
	if body == player_dentro:
		player_dentro = null 

func _process(_delta):
	if player_dentro != null and Input.is_action_just_pressed("pegar"):
		player_dentro.equipar_arma_do_jogador()
		queue_free()
