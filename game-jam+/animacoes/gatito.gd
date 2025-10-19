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
		"left": "ui_left_p2",		"right": "ui_right_p2",
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

var gun_scene = preload("res://New_Gun.tscn")
var thrown_gun_scene = preload("res://ThrownGun.tscn")

func _ready() -> void:
	if player_id == 1:
		life = LifeManager.p1_life
	else:
		life = LifeManager.p2_life

func _physics_process(delta: float) -> void:
	# Adiciona a gravidade. Isso deve sempre ser aplicado.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not airborne:
			airborne = true
	if is_on_floor() and airborne:
		airborne = false
		falling = false
		anim_control.land()

	# Lida com os controles desabilitados
	if controls_disabled:
		# Desacelera o movimento horizontal diretamente
		var friction_amount = 150 * delta # Adjust this value as needed
		if velocity.x > 0:
			velocity.x = max(0, velocity.x - friction_amount)
		elif velocity.x < 0:
			velocity.x = min(0, velocity.x + friction_amount)
	else:
		# Lógica original de movimento horizontal
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

	# Sempre chama move_and_slide() no final
	move_and_slide()

var equipado = null


func equipar(arma_no_chao):
	if equipado:
		return

	var equipped_weapon = null
	if arma_no_chao.get_script() == preload("res://sword_ground.gd"): # Check if it's a sword on the ground
		equipped_weapon = preload("res://sword.tscn").instantiate() # Instantiate the equipped sword
	else:
		equipped_weapon = gun_scene.instantiate() # Instantiate the gun (New_Gun.tscn)

	anim_control.add_child(equipped_weapon)
	equipped_weapon.position = Vector2(0, -5) # Set the equipped position
	equipped_weapon.equipar() # Call the equipar function on the equipped weapon
	equipado = equipped_weapon # Set the equipped weapon to the new instance
	
	arma_no_chao.queue_free() # Remove the weapon from the ground

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
	
		# Obtém os quadros de sprite e a animação da arma equipada
		var equipped_animated_sprite = null
		if equipado.has_node("offset"):
			equipped_animated_sprite = equipado.find_child("offset").find_child("AnimatedSprite2D")
		else:
			equipped_animated_sprite = equipado.find_child("AnimatedSprite2D")
	
		print("gatito.gd: equipped_animated_sprite: ", equipped_animated_sprite)
		if equipped_animated_sprite:
			print("gatito.gd: equipped_animated_sprite.sprite_frames: ", equipped_animated_sprite.sprite_frames)
			print("gatito.gd: equipped_animated_sprite.animation: ", equipped_animated_sprite.animation)
			
			# Set properties BEFORE adding to scene tree
			thrown_gun.thrown_sprite_frames = equipped_animated_sprite.sprite_frames
			thrown_gun.thrown_animation = equipped_animated_sprite.animation
			
			print("gatito.gd: thrown_gun.thrown_sprite_frames (after set): ", thrown_gun.thrown_sprite_frames)
			print("gatito.gd: thrown_gun.thrown_animation (after set): ", thrown_gun.thrown_animation)
	
		get_parent().add_child(thrown_gun) # Add to scene tree AFTER properties are set
	
		thrown_gun.global_position = equipado.global_position
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
