extends CharacterBody2D

@onready var anim_control: Node2D = $"anim control"
@onready var animation_player: AnimationPlayer = $"anim control/AnimationPlayer"

@export var player_id: int
@export var life: int

const INPUTS = {
	1: {
		"left": "ui_left_p1",
		"right": "ui_right_p1",
		"jump": "ui_jump_p1",
	},
	2: {
		"left": "ui_left_p2",
		"right": "ui_right_p2",
		"jump": "ui_jump_p2",
	},
}

var speed = 0
const accel = 40
const maxSPEED = 500
const JUMP_VELOCITY = -400.0

var airborne = false
var moving = false
var falling = false
var orientation = 1
var controls_disabled = false

var gun_scene = preload("res://Gun.tscn")
var thrown_gun_scene = preload("res://ThrownGun.tscn")

func _ready() -> void:
	if player_id == 1:
		life = LifeManager.p1_life
	else:
		life = LifeManager.p2_life

func _physics_process(delta: float) -> void:
	if controls_disabled:
		velocity = velocity.move_toward(Vector2.ZERO, 100)
		move_and_slide()
		return

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not airborne:
			airborne = true
	if is_on_floor() and airborne:
		airborne = false
		falling = false
		anim_control.land()
	
	var inputs = INPUTS[player_id]
	var direction := Input.get_axis(inputs["left"], inputs["right"])
	if Input.is_action_pressed(inputs["jump"]):
		if is_on_floor():
			anim_control.land()
			velocity.y = JUMP_VELOCITY
		elif is_on_wall_only() and direction:
			anim_control.land()
			velocity.y = JUMP_VELOCITY
			if sign(direction) != sign(speed): direction *= -1
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

var equipado = null


func equipar(arma_no_chao):
	if equipado:
		return

	var gun = gun_scene.instantiate()
	anim_control.add_child(gun)
	gun.position = Vector2(10, -15)
	gun.equipar_arma()
	equipado = gun
	
	arma_no_chao.queue_free()

func desequipar():
	if equipado:
		equipado.queue_free()
		equipado = null

func _input(event):
	if event.is_action_pressed("right_mouse_button"):
		if equipado:
			throw_weapon()

func throw_weapon():
	var thrown_gun = thrown_gun_scene.instantiate()
	get_parent().add_child(thrown_gun)
	thrown_gun.global_position = equipado.global_position
	if orientation == -1:
		thrown_gun.rotation_degrees = 180
	
	thrown_gun.linear_velocity = Vector2(500 * orientation, -200)
	thrown_gun.thrower = self
	thrown_gun.add_collision_exception_with(self)

	desequipar()

func set_skin(skin):
	$"anim control/body".texture = skin

func take_damage():
	life -= 1
	if player_id == 1:
		LifeManager.p1_life = life
	else:
		LifeManager.p2_life = life
	print(life)
	print(LifeManager.p1_life)
	print(LifeManager.p2_life)
	if life <= 0:
		queue_free()
		print("Player morreu!")

func disable_controls(duration):
	controls_disabled = true
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(_on_enable_controls_timeout)

func _on_enable_controls_timeout():
	controls_disabled = false
