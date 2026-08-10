class_name GameController extends Node2D

var current_gui: Node
var scenes: Array[Scene]
var next_available_scene_id := 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller = self
	return_to_main_menu()



func create_or_edit_scene(scene: Scene) -> void:
	var scene_creator := preload("res://scenes/scene_creator.tscn")
	free_current_gui()
	current_gui = scene_creator.instantiate()
	add_child(current_gui)
	if scene:
		current_gui.scene = scene
		current_gui.display_scene_to_edit()
	else:
		current_gui.make_new_scene(next_available_scene_id)
		next_available_scene_id += 1

func return_to_main_menu() -> void:
	var main_menu := preload("res://scenes/main.tscn")
	free_current_gui()
	current_gui = main_menu.instantiate()
	add_child(current_gui)


func free_current_gui() -> void:
	if current_gui:
		current_gui.queue_free()

func save_scene(scene:Scene) -> void:
	for s in scenes:
		if s.id == scene.id:
			replace_scene(s, scene)
			return
	# if the scene is new:
	scenes.append(scene)


func replace_scene(scene_old: Scene, scene_new: Scene) -> void:
	scene_old.scene_name = scene_new.scene_name
	scene_old.default_image_path = scene_new.default_image_path
	scene_old.default_sentence = scene_new.default_sentence
	scene_old.correct_sentences = scene_new.correct_sentences
	scene_old.max_word_count = scene_new.max_word_count

func get_scene_from_id(id:int) -> Scene:
	if id == 0:
		print("error: id 0 should not be used for scenes as it is reserved for placeholders")
		return
	for s in scenes:
		if s.id == id:
			return s
	return null
