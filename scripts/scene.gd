extends Node
class_name Scene

var scene_name: String #the name of this scene
var previous_scene: Scene #the scene that led here (needs to be given to this scene by the previous one)

var default_sentence: String
var correct_sentences: Array[String]
var next_scenes: Array[Scene]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func go_to_next_scene():
	pass
