class_name GameGLFR extends Node


var game_name: String
var scenes: Array[Scene]
var next_available_scene_id := 1
var start_scene: Scene


func get_scenes() -> Array[Scene]:
	return scenes

func add_scene(scene: Scene) -> void:
	scenes.append(scene)

func delete_scene(scene: Scene) -> bool:
	if scene in scenes:
		scenes.erase(scene)
		return true
	else:
		return false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
