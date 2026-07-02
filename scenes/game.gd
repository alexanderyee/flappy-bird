extends Node

@onready var da_bird: Player = $"da bird"
@onready var pipes: Pipes = $Pipes
@onready var parallax_2d_sky: Parallax2D = $World/Parallax2DSky
@onready var parallax_2d_clouds: Parallax2D = $World/Parallax2DClouds
@onready var parallax_2d_trees: Parallax2D = $World/Parallax2DTrees
@onready var pipe_spawner: Node2D = $PipeSpawner

var score := 0
var high_score := 0
var parallaxes: Array[Parallax2D]
var parallax_speeds: Array[float]
var bird_spawn_pos: Vector2

func _ready() -> void:
	SignalBus.player_collided.connect(_on_player_collided)
	SignalBus.player_cleared_pipe.connect(_on_player_cleared_pipe)
	SignalBus.game_restarted.connect(_on_game_restart)
	parallaxes = [parallax_2d_sky, parallax_2d_clouds, parallax_2d_trees]
	for p in parallaxes:
		parallax_speeds.append(p.autoscroll.x)
	bird_spawn_pos = da_bird.position
	

func start() -> void:
	for i in 3:
		parallaxes[i].autoscroll.x = parallax_speeds[i]
	# clear pipes
	pipes.clear_pipes()
	pipe_spawner.spawn_disabled = false
	# reset bird
	da_bird.move_player(bird_spawn_pos)
	da_bird.input_disabled = false
	
	score = 0

func _on_player_collided() -> void:
	pipes.stop()
	for p in parallaxes:
		p.autoscroll.x = 0
	pipe_spawner.spawn_disabled = true
	da_bird.input_disabled = true
	%UI.show_game_over(score, high_score)
	
	

func _on_player_cleared_pipe() -> void:
	score += 1
	if score > high_score:
		high_score = score
	%UI.update_scores(score, high_score)


func _on_game_restart() -> void:
	%UI.restart_game()
	start()
