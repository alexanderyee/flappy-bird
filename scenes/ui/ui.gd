class_name UI
extends Control


func update_scores(score: int, high_score: int) -> void:
	%ScoreLabel.text = str(score)
	%HighScoreLabel.text = "High score: " + str(high_score)

func restart_game() -> void:
	%ScoreLabel.text = "0"
	%GameOverPanel.hide()

func show_game_over(score: int, high_score: int) -> void:
	%GameOverPanel.show_scores(score, high_score)
