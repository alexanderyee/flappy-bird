class_name UI
extends Control


func update_score(score: int) -> void:
	%ScoreLabel.text = str(score)
