extends Node2D

var scene_to_edit: Scene
var current_project: GameGLFR

@onready var game_name_line_edit: LineEdit = $GameNameLineEdit
@onready var files_upload_manager: FileUploadManager = $FilesUploadManager
@onready var file_dialog_upload: FileDialog = $FileDialogUpload
@onready var file_dialog_export: FileDialog = $FileDialogExport
@onready var edit_scene_picker: OptionButton = $EditScenePickerOptionButton
@onready var start_scene_picker: OptionButton = $StartScenePickerOptionButton
@onready var asset_container: HBoxContainer = $ScrollContainer/AssetContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	files_upload_manager.files_loaded.connect(_on_files_loaded)
	refresh_asset_list()

func display_project_to_edit() -> void:
	game_name_line_edit.text = current_project.game_name
	populate_scene_picker(edit_scene_picker)
	populate_scene_picker(start_scene_picker)
	var selected_idx := 0
	#set start scene
	if not current_project.get_scenes().is_empty():
		var idx := 1
		for s in current_project.get_scenes():
			if current_project.start_scene == s:
				selected_idx = idx
			idx += 1
	start_scene_picker.select(selected_idx)

func populate_scene_picker(scene_picker: OptionButton) -> void:
	if current_project:
		var scenes := current_project.get_scenes()
		for s in scenes:
			scene_picker.add_item(str(s.get_id(), "-", s.scene_name), s.id)

func _on_upload_button_pressed() -> void:
	if Global.game_controller.is_game_local:
		file_dialog_upload.popup_centered()
	else:
		files_upload_manager.open_file_picker("image/png,image/jpeg,image/gif,image/webp", true)

func _on_files_loaded(files: Array) -> void: #itch
	files_upload_manager.save_uploaded_files(files)
	refresh_asset_list()
	

func _on_file_dialog_upload_files_selected(paths: PackedStringArray) -> void:
	var files: Array = []

	for path in paths:
		var file := FileAccess.open(path, FileAccess.READ)

		if file == null:
			push_error("Could not open file: " + path)
			continue

		var data := file.get_buffer(file.get_length())
		file.close()

		files.append({
			"name": path.get_file(),
			"data": data
		})

	files_upload_manager.save_uploaded_files(files)
	refresh_asset_list()


func _on_create_scene_button_pressed() -> void:
	Global.game_controller.create_or_edit_scene(null)


func _on_edit_scene_button_pressed() -> void:
	if scene_to_edit:
		Global.game_controller.create_or_edit_scene(scene_to_edit)


func _on_edit_scene_picker_option_button_item_selected(index: int) -> void:
	var id := edit_scene_picker.get_item_id(index)
	scene_to_edit = Global.game_controller.get_scene_from_id(id)


func _on_start_scene_picker_option_button_item_selected(index: int) -> void:
	current_project.start_scene = Global.game_controller.get_scene_from_id(
	start_scene_picker.get_item_id(index)
	)


func _on_export_glfr_button_pressed() -> void:
	var filename := str(sanitize_filename(current_project.game_name),".glfr")
	if Global.game_controller.is_game_local:
		file_dialog_export.current_file = filename
		file_dialog_export.popup_centered()
	else:
		export_project_web(filename)
	

func export_project(path: String) -> bool:
	var json_text := JSON.stringify(current_project.to_dict(), "\t")
	var packer := ZIPPacker.new()
	var error := packer.open(path)
	
	if error != OK:
		print ("Failed to create project file: ", error)
		return false
	
	#add project data
	packer.start_file("project.json")
	packer.write_file(json_text.to_utf8_buffer())
	packer.close_file()
	
	#add all user assets
	var asset_dir := DirAccess.open("user://game_assets")
	
	if asset_dir:
		var files := asset_dir.get_files()

		for filename in files:
			var asset_path := "user://game_assets/" + filename

			var file := FileAccess.open(asset_path, FileAccess.READ)

			if file == null:
				print("Could not open asset: ", asset_path)
				continue

			var data := file.get_buffer(file.get_length())
			file.close()

			packer.start_file("game_assets/" + filename)
			packer.write_file(data)
			packer.close_file()

	
	packer.close()
	print("project exported succesfully")
	return true

func export_project_web(filename: String) -> void:
	var temporary_path := "user://temp_export.glfr"

	# Create the .glfr file
	if not export_project(temporary_path):
		return

	# Read it into memory
	var file := FileAccess.open(temporary_path, FileAccess.READ)

	if file == null:
		print("Failed to open exported project")
		return

	var data := file.get_buffer(file.get_length())
	file.close()

	# Give the file to the browser
	JavaScriptBridge.download_buffer(
		data,
		filename,
		"application/octet-stream"
	)

func sanitize_filename(game_name: String) -> String:
	var result := game_name.strip_edges()
	result = result.replace(" ", "_")

	# Replace anything that isn't a letter, number, space, _ or -
	var regex := RegEx.new()
	regex.compile("[^a-zA-Z0-9_\\-]")
	result = regex.sub(result, "", true)

	# Prevent an empty filename
	if result.is_empty():
		result = "untitled"

	return result

func _on_game_name_line_edit_text_changed(new_text: String) -> void:
	current_project.game_name = new_text


func _on_file_dialog_export_file_selected(path: String) -> void:
	export_project(path)


func _on_main_menu_button_pressed() -> void:
	Global.game_controller.return_to_main_menu()

func refresh_asset_list() -> void:
	for child in asset_container.get_children():
		child.queue_free()
	var assets := files_upload_manager.get_available_assets()

	for asset in assets:
		if asset["texture"] == null:
			var label := Label.new()
			var text_to_use :String = asset["name"]
			if text_to_use.length() > 9:
				text_to_use = text_to_use.left(7) + ".."
			label.text = text_to_use
			asset_container.add_child(label)
			continue

		var texture_rect := TextureRect.new()
		texture_rect.texture = asset["texture"]
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.custom_minimum_size = Vector2(60, 60)

		asset_container.add_child(texture_rect)


func _on_play_game_button_pressed() -> void:
	if current_project.start_scene:
		Global.game_controller.load_scene_template(current_project.start_scene.get_id())
