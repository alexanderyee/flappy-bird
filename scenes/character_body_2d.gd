class_name Player
extends CharacterBody2D

const JUMP_VELOCITY = -400.0

var input_disabled := false

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		SignalBus.player_collided.emit()
		return

	if Input.is_action_just_pressed("ui_accept") and !input_disabled:
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().get_parent() is PipeSet:
			SignalBus.player_collided.emit()

	
