class_name Pipes
extends Node2D


func stop() -> void:
	for child in get_children():
		assert(child is PipeSet)
		var pipe_set: PipeSet = child as PipeSet
		pipe_set.set_speed(0)

func clear_pipes() -> void:
	for child: PipeSet in get_children():
		child.disable_collisions()
		child.queue_free()
