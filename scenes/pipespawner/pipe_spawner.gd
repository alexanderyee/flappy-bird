extends Node2D

const PIPE_SET = preload("uid://bghq45rw1727i")

@export var is_flipped_v := false
@export var speed := -100.0
@export var spawn_frequency := 1.0
@export var spawn_offset_range := 100
@export var gap_size := 200

var spawn_disabled := false

@onready var pipes: Node2D = $"../Pipes"
@onready var timer: Timer = $Timer

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if timer.is_stopped():
		timer.start(spawn_frequency)


func _on_timer_timeout() -> void:
	if spawn_disabled:
		return

	var pipe_set: PipeSet = PIPE_SET.instantiate()
	pipe_set.setup(speed, rng.randi_range(-spawn_offset_range, spawn_offset_range), gap_size)
	pipes.add_child(pipe_set)


func _on_despawn_barrier_area_entered(area: Area2D) -> void:
	if area.get_parent() is PipeSet:
		area.get_parent().queue_free()
