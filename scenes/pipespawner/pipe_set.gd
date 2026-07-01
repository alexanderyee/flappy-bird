class_name PipeSet
extends Node2D

@onready var top_pipe: StaticBody2D = $TopPipe
@onready var bottom_pipe: StaticBody2D = $BottomPipe

var _speed: float
var _gap_size: int


func setup(speed: float, offset: int, gap_size: int) -> void:
	set_speed(speed)
	position.y += offset
	_gap_size = gap_size


func _ready() -> void:
	set_gap(_gap_size)


func _process(delta: float) -> void:
	position.x += _speed * delta


func set_speed(speed: float) -> void:
	_speed = speed


func set_gap(gap_size: int) -> void:
	top_pipe.position.y -= gap_size / 2.0
	bottom_pipe.position.y += gap_size / 2.0
