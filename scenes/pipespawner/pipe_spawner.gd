extends Node2D

const PIPE_SET = preload("uid://bghq45rw1727i")

@export var is_flipped_v := false
@export var speed := -100.0
@export var spawn_frequency := 1.0
@export var spawn_offset_range := 100
@export var max_diff_between_pipe_offset := 100
@export var gap_size := 200

var spawn_disabled := false
var previous_pipe_y_offset := 0

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
	var offset_y := rng.randi_range(-spawn_offset_range, spawn_offset_range)
	var num_tries := 0
	while abs(offset_y - previous_pipe_y_offset) >= max_diff_between_pipe_offset:
		offset_y = rng.randi_range(-spawn_offset_range, spawn_offset_range)
		num_tries += 1
		assert(num_tries <= 1_000_000)
	pipe_set.setup(speed, offset_y, gap_size)
	pipes.add_child(pipe_set)


func _on_despawn_barrier_area_entered(area: Area2D) -> void:
	if area.get_parent() is PipeSet:
		area.get_parent().queue_free()
