extends PanelContainer

func show_scores(score: int, high_score: int) -> void:
	show()
	%Score.text = "Score: " + str(score)
	%HighScore.text = "High score: " + str(high_score)


func _on_restart_button_pressed() -> void:
	SignalBus.game_restarted.emit()
