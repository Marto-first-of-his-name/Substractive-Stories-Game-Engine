class_name GameGLFR extends Node


var game_name: String
var scenes: Array[Scene]
var next_available_scene_id := 1
var start_scene: Scene

func to_dict() -> Dictionary:
	var scenes_data: Array[Dictionary]
	for s in scenes:
		scenes_data.append(s.to_dict())
	
	return {
		"game_name": game_name,
		"scenes": scenes_data,
		"next_available_scene_id": next_available_scene_id,
		"start_scene_id": start_scene.get_id() if start_scene != null else -1
	}

static func from_dict(data: Dictionary) -> GameGLFR:
	var project := GameGLFR.new()
	
	project.game_name = data["game_name"]
	project.next_available_scene_id = data["next_available_scene_id"]
	for scene_data:Dictionary in data["scenes"]:
		project.scenes.append(Scene.from_dict(scene_data))
		
	var start_scene_id := int(data["start_scene_id"])
	for scene in project.scenes:
		if scene.id == start_scene_id:
			project.start_scene = scene
			break
	
	return project

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
