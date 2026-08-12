class_name GameController extends Node2D

var current_gui: Node
var current_project: GameGLFR
var is_game_local:bool = true #true if tool is to be ran locally, false if it's for itch

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller = self
	return_to_main_menu()

func get_current_project() -> GameGLFR:
	return current_project


func create_or_edit_scene(scene: Scene) -> void:
	var scene_creator := preload("res://scenes/scene_creator.tscn")
	free_current_gui()
	current_gui = scene_creator.instantiate()
	add_child(current_gui)
	if scene:
		current_gui.scene = scene
		current_gui.display_scene_to_edit()
	else:
		current_gui.make_new_scene(current_project.next_available_scene_id)
		current_project.next_available_scene_id += 1

func return_to_main_menu() -> void:
	var main_menu := preload("res://scenes/main_menu.tscn")
	current_project = null
	free_current_gui()
	current_gui = main_menu.instantiate()
	add_child(current_gui)
	
func return_to_project_editor() -> void:
	var project_editor := preload("res://scenes/project_editor.tscn")
	free_current_gui()
	current_gui = project_editor.instantiate()
	add_child(current_gui)
	if current_project:
		current_gui.current_project = current_project
		current_gui.display_project_to_edit()

func start_project_editor(project: GameGLFR) -> void:
	var project_editor := preload("res://scenes/project_editor.tscn")
	free_current_gui()
	current_gui = project_editor.instantiate()
	add_child(current_gui)
	if project:
		current_project = project
		current_gui.current_project = current_project
		current_gui.display_project_to_edit()
	else:
		current_project = GameGLFR.new()
		current_gui.current_project = current_project

func free_current_gui() -> void:
	if current_gui:
		current_gui.queue_free()

func save_scene(scene:Scene) -> void:
	for s in current_project.get_scenes():
		if s.id == scene.id:
			replace_scene(s, scene)
			return
	# if the scene is new:
	current_project.add_scene(scene)

func load_scene_template(scene_id: int) -> void:
	var scene_template := SceneTemplate.create(get_scene_from_id(scene_id))
	free_current_gui()
	current_gui = scene_template
	add_child(current_gui)


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
	for s in current_project.get_scenes():
		if s.id == id:
			return s
	return null
