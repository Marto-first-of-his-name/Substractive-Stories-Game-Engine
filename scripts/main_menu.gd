extends Node2D

@onready var file_dialog_import: FileDialog = $ImportGlfrButton/FileDialogImport
@onready var exit_button: Button = $ExitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Global.game_controller.is_game_local:
		exit_button.queue_free()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_create_new_button_pressed() -> void:
	Global.game_controller.start_project_editor(null)


func _on_import_glfr_button_pressed() -> void:
	if Global.game_controller.is_game_local:
		file_dialog_import.popup_centered()
	else:
		#web
		pass

func import_project(path: String) -> GameGLFR:
	var reader := ZIPReader.new()
	var error := reader.open(path)
	
	if error != OK:
		print("Failed to open GLFR project: ", error)
		return 

	var json_bytes := reader.read_file("project.json")
	reader.close()
	
	if json_bytes.is_empty():
		print("Project does not contain project.json")
		return
	
	var json_text := json_bytes.get_string_from_utf8()
	var data = JSON.parse_string(json_text)
	
	if data==null:
		print("Failed to parse project.json")
		return
	
	print("succesfully imported project:")
	print(data)
	
	return GameGLFR.from_dict(data)


func _on_file_dialog_file_selected(path: String) -> void:
	Global.game_controller.start_project_editor(import_project(path))


func _on_exit_button_pressed() -> void:
	get_tree().quit(0)
