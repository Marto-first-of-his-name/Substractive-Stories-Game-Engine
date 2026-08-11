extends Node
class_name Scene

var id: int
var scene_name: String
var default_image_path: String
var default_sentence: String
var correct_sentences: Array[CorrectSentence]
var max_word_count: int = 0

#var previous_scene: Scene #the scene that led here (needs to be given to this scene by the previous one)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func go_to_next_scene() -> void:
	pass

func get_id() -> int:
	return id

func to_dict() -> Dictionary:
	var sentences_data : Array[Dictionary]
	for cs in correct_sentences:
		sentences_data.append(cs.to_dict())
		
	return {
		"id": id,
		"scene_name": scene_name,
		"default_image_path": default_image_path,
		"default_sentence": default_sentence,
		"correct_sentences": sentences_data,
		"max_word_count": max_word_count,
	}
