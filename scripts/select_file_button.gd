@tool
extends Control
class_name SelectFileButton

@export var button_text: String = "button":
	set(value):
		button_text = value
		if button:
			button.text = value

@export var folder_to_read: String = "user://game_assets/"
@export var file_dialog_access: FileDialog.Access = FileDialog.ACCESS_USERDATA

var button: Button
var file_dialog: FileDialog

signal fileSelected(file_path: String)


func _ready() -> void:
	_create_button()
	_create_file_dialog()

	set_folder_to_read(folder_to_read)
	set_file_dialog_access(file_dialog_access)


func set_folder_to_read(path: String) -> void:
	folder_to_read = path
	
	if file_dialog:
		file_dialog.root_subfolder = folder_to_read


func set_file_dialog_access(type: FileDialog.Access) -> void:
	file_dialog_access = type
	
	if file_dialog:
		file_dialog.access = file_dialog_access


func _create_button() -> void:
	if button:
		return

	button = Button.new()
	button.text = button_text
	button.pressed.connect(_on_pressed)
	add_child(button)
	custom_minimum_size = button.size


func _create_file_dialog() -> void:
	if file_dialog:
		return

	file_dialog = FileDialog.new()

	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = file_dialog_access
	file_dialog.root_subfolder = folder_to_read

	file_dialog.file_selected.connect(_on_file_selected)

	add_child(file_dialog)


func _on_pressed() -> void:
	if file_dialog:
		file_dialog.popup_centered()


func _on_file_selected(file_path: String) -> void:
	fileSelected.emit(file_path)


func set_button_size_to_max() -> void:
	button.size = size
