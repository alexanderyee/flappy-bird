extends Node

var score := 0
var parallaxes: Array[Parallax2D]
var parallax_speeds: Array[float]
var bird_spawn_pos: Vector2
var seconds_since_game_over := 0.0  # used to block player input right after dying
var curr_state: GameState
var states: Dictionary[String, GameState] = {}

@onready var da_bird: Player = $"da bird"
@onready var pipes: Pipes = $Pipes
@onready var parallax_2d_sky: Parallax2D = $World/Parallax2DSky
@onready var parallax_2d_clouds: Parallax2D = $World/Parallax2DClouds
@onready var parallax_2d_trees: Parallax2D = $World/Parallax2DTrees
@onready var pipe_spawner: Node2D = $PipeSpawner
@onready var sfx_player: AudioStreamPlayer2D = %SFXPlayer
@onready var score_manager: ScoreManager = $ScoreManager



func _ready() -> void:
	SignalBus.player_collided.connect(_on_player_collided)
	SignalBus.player_cleared_pipe.connect(_on_player_cleared_pipe)
	SignalBus.game_restarted.connect(_on_game_restart)
	parallaxes = [parallax_2d_sky, parallax_2d_clouds, parallax_2d_trees]
	for p in parallaxes:
		parallax_speeds.append(p.autoscroll.x)
	bird_spawn_pos = da_bird.position
	
	for child in %States.get_children():
		assert(child is GameState)
		states[child.name.to_lower()] = child
		child.transitioned.connect(_on_state_transitioned)
		_on_state_transitioned(states["newrunstate"])
	
	%UI.update_scores(score, score_manager.high_score)


func _process(delta: float) -> void:
	if Input.is_action_pressed("jump"):
		if %GameOverPanel.visible and seconds_since_game_over >= 0.5:
			_on_game_restart()

	if %GameOverPanel.visible:
		seconds_since_game_over += delta


func start() -> void:
	for i in parallaxes.size():
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
	%UI.show_game_over(score, score_manager.high_score)


	if score >= score_manager.high_score:
		score_manager.save_high_score()


func _on_player_cleared_pipe() -> void:
	score += 1
	if score > score_manager.high_score:
		score_manager.high_score = score
	%UI.update_scores(score, score_manager.high_score)
	%SFXPlayer.play_point_scored()


func _on_game_restart() -> void:
	%UI.restart_game()
	start()
	seconds_since_game_over = 0.0


func _on_state_transitioned(new_game_state: GameState) -> void:
	if curr_state != null:
		curr_state.exit()
	
	new_game_state.enter()
	curr_state = new_game_state
	
