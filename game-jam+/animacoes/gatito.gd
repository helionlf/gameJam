extends CharacterBody2D

@onready var anim_control: Node2D = $"anim control"
@onready var animation_player: AnimationPlayer = $"anim control/AnimationPlayer"
@onready var arma_no_player: Node2D = $"anim control/Gun"
@onready var espada_no_player: Area2D = $"anim control/Sword"

var tem_espada = false

var speed = 0
const accel = 40
const maxSPEED = 500
const JUMP_VELOCITY = -400.0

var airborne = false
var moving = false
var falling = false
var orientation = 1

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not airborne:
			airborne = true
	if is_on_floor() and airborne:
		airborne = false
		falling = false
		anim_control.land()
	
	var direction := Input.get_axis("A", "D")
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			anim_control.land()
			velocity.y = JUMP_VELOCITY
		elif is_on_wall_only() and direction:
			anim_control.land()
			velocity.y = JUMP_VELOCITY
			speed = -300*direction
	
	if direction:
		if airborne: speed += direction * accel * 0.8
		else: speed += direction * accel
		speed = clamp(speed, -maxSPEED, maxSPEED)
		velocity.x = speed
		if direction != orientation:
			orientation = direction
			anim_control.scale.x = direction
			anim_control.land()
		if not moving:
			animation_player.play("run")
			moving = true
			anim_control.land()
	else:
		speed = move_toward(speed, 0, accel)
		velocity.x = speed
		moving = false
		animation_player.play("RESET")
	anim_control.incline(speed)
	
	if airborne and velocity.y > 0 and not falling:
		falling = true
		#anim_control.stretch()
	move_and_slide()

func equipar_arma_do_jogador():
	if arma_no_player.visible:
		return

	if arma_no_player:
		arma_no_player.equipar_arma()
		espada_no_player.desequipar()

# --- ADICIONE ESTA NOVA FUNÇÃO ---
func equipar_espada_do_jogador():
	tem_espada = true # Agora o jogador "possui" a espada
	
	if espada_no_player.visible:
		return
	
	espada_no_player.equipar()
	arma_no_player.desequipar()
# ---------------------------------

func _on_arma_desapareceu():
	if tem_espada:
		espada_no_player.equipar()
