class_name SFXPlayer
extends AudioStreamPlayer2D

@export var point_scored_sound: AudioStream

func play_point_scored() -> void:
	stream = point_scored_sound
	play()
