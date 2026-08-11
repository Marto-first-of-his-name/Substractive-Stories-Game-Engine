extends Node2D

@onready var file_dialog_import: FileDialog = $FileDialogImport
@onready var exit_button: Button = $ExitButton
@onready var file_upload_manager: FileUploadManager = $FileUploadManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Global.game_controller.is_game_local:
		exit_button.queue_free()
		file_upload_manager.files_loaded.connect(_on_project_files_loaded)
	file_upload_manager._create_asset_directory()

func _on_project_files_loaded(files: Array) -> void:
	if files.is_empty():
		return
	
	var data: PackedByteArray = files[0]["data"]
	
	var temporary_path := "user://import.glfr"
	
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	
	if file == null:
		print("Failed to create temporary import file")
		return
	
	file.store_buffer(data)
	file.close()
	
	Global.game_controller.start_project_editor(import_project(temporary_path))
	return 

func _on_create_new_button_pressed() -> void:
	Global.game_controller.start_project_editor(null)


func _on_import_glfr_button_pressed() -> void:
	if Global.game_controller.is_game_local:
		file_dialog_import.popup_centered()
	else:
		file_upload_manager.open_file_picker(".glfr",false)

func import_project(path: String) -> GameGLFR:
	var reader := ZIPReader.new()
	var error := reader.open(path)
	
	if error != OK:
		print("Failed to open GLFR project: ", error)
		return null

	var json_bytes := reader.read_file("project.json")
	reader.close()
	
	if json_bytes.is_empty():
		print("Project does not contain project.json")
		return null
	
	var json_text := json_bytes.get_string_from_utf8()
	var data :Dictionary = JSON.parse_string(json_text)
	
	if data==null:
		print("Failed to parse project.json")
		return
	
	print("succesfully imported project:")
	print(data)
	
	return GameGLFR.from_dict(data)


func _on_file_dialog_import_file_selected(path: String) -> void:
	Global.game_controller.start_project_editor(import_project(path))


func _on_exit_button_pressed() -> void:
	get_tree().quit(0)


func _on_try_template_button_pressed() -> void:
	Global.game_controller.start_project_editor(import_project("res://template.glfr"))
