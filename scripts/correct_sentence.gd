extends Node
class_name CorrectSentence

var id: int
var sentence: String
var follow_up_sentence: String
var karma_judgement: String
var karma : int
var image_path: String
var next_scene: Scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func to_dict() -> Dictionary:
	return {
		"id": id,
		"sentence": sentence,
		"follow_up_sentence": follow_up_sentence,
		"karma_judgement": karma_judgement,
		"karma": karma,
		"image_path": image_path,
		"next_scene_id": next_scene.get_id() if next_scene != null else -1
	}
