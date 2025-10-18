extends RigidBody2D

var thrower = null

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	if $Timer:
		$Timer.start()

func _on_Timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player") and body != thrower:
		if body.has_method("disable_controls"):
			body.disable_controls(1.0)
		queue_free()
