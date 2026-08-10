extends Node2D

var scene_to_edit: Scene

@onready var image_upload_manager: ImageUploadManager = $ImageUploadManager
@onready var uploaded_image: TextureRect = $uploadedImage
@onready var file_dialog: FileDialog = $FileDialog
@onready var edit_scene_picker: OptionButton = $EditScenePickerOptionButton

@export var is_game_local:bool = false #true if tool is to be ran locally, false if it's for itch

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	image_upload_manager.image_loaded.connect(_on_image_loaded)
	populate_scene_picker()



func populate_scene_picker() -> void:
	var scenes := Global.game_controller.scenes
	for s in scenes:
		edit_scene_picker.add_item(s.name, s.id)

func _on_button_pressed() -> void:
	if is_game_local:
		file_dialog.popup_centered()
	else:
		image_upload_manager.open_file_picker()

func _on_image_loaded(image: Image) -> void: #itch
	var texture := ImageTexture.create_from_image(image)
	uploaded_image.texture = texture
	print("image_loaded and shown")


func _on_file_dialog_file_selected(path: String) -> void: #local
	print("selected file: ", path)
	pass # Replace with function body.


func _on_create_scene_button_pressed() -> void:
	Global.game_controller.create_or_edit_scene(null)


func _on_edit_scene_button_pressed() -> void:
	if scene_to_edit:
		Global.game_controller.create_or_edit_scene(scene_to_edit)


func _on_edit_scene_picker_option_button_item_selected(index: int) -> void:
	var id := edit_scene_picker.get_item_id(index)
	scene_to_edit = Global.game_controller.get_scene_from_id(id)
