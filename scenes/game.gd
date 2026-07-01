extends Node

@onready var da_bird: Player = $"da bird"
@onready var pipes: Pipes = $Pipes
@onready var parallax_2d_sky: Parallax2D = $World/Parallax2DSky
@onready var parallax_2d_clouds: Parallax2D = $World/Parallax2DClouds
@onready var parallax_2d_trees: Parallax2D = $World/Parallax2DTrees
@onready var pipe_spawner: Node2D = $PipeSpawner

var score := 0
var parallaxes: Array[Parallax2D]


func _ready() -> void:
	SignalBus.player_collided.connect(_on_player_collided)
	SignalBus.player_cleared_pipe.connect(_on_player_cleared_pipe)
	parallaxes = [parallax_2d_sky, parallax_2d_clouds, parallax_2d_trees]

func _on_player_collided() -> void:
	pipes.stop()
	for p in parallaxes:
		p.autoscroll.x = 0
	pipe_spawner.spawn_disabled = true
	da_bird.input_disabled = true
	

func _on_player_cleared_pipe() -> void:
	score += 1
	%UI.update_score(score)
