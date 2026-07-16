class_name ScoreManager
extends Node

const SAVE_FILE_PATH = "user://score.save"
var high_score := 0

func _ready() -> void:
	# load prev high score
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		high_score = json.data["score"]
		
	save_file.close()

func save_high_score() -> void:
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	var high_score_data = {"score" : high_score}
	var json_string = JSON.stringify(high_score_data)
	save_file.store_line(json_string)
	save_file.close()
