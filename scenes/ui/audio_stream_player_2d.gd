class_name PlayerSFX
extends AudioStreamPlayer2D

@export var jump_sound: AudioStream
@export var crash_sound: AudioStream

func play_jump_sound() -> void:
	stream = jump_sound
	play()

func play_crash_sound() -> void:
	stream = crash_sound
	play()
