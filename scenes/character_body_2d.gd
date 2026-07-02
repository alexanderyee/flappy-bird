class_name Player
extends CharacterBody2D

const JUMP_VELOCITY = -400.0

var input_disabled := false

@onready var audio_stream_player_2d: PlayerSFX = $AudioStreamPlayer2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		return
	
	if Input.is_action_just_pressed("ui_accept") and !input_disabled:
		velocity.y = JUMP_VELOCITY
		audio_stream_player_2d.play_jump_sound()

	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print(collision.get_collider())
		if collision.get_collider().get_parent() is PipeSet or collision.get_collider() is Floor:
			crash()

func crash() -> void:
	if !input_disabled:
		audio_stream_player_2d.play_crash_sound()
	SignalBus.player_collided.emit()
	
func move_player(pos: Vector2) -> void:
	position = pos
	move_and_slide()
