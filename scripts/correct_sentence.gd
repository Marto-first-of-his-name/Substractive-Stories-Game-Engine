extends Node
class_name CorrectSentence

var id: int
var sentence: String
var follow_up_sentence: String
var karma_judgement: String
var karma : int
var image_path: String
var next_scene_id: int

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
		"next_scene_id": next_scene_id
	}

static func from_dict(data: Dictionary) -> CorrectSentence:
	var cs := CorrectSentence.new()
	cs.id = data["id"]
	cs.sentence = data["sentence"]
	cs.follow_up_sentence = data["follow_up_sentence"]
	cs.karma_judgement = data["karma_judgement"]
	cs.karma = data["karma"]
	cs.image_path = data["image_path"]
	cs.next_scene_id = data["next_scene_id"]
	return cs
