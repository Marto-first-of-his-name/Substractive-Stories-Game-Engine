extends Node2D

@onready var image_upload_manager: ImageUploadManager = $ImageUploadManager
@onready var uploaded_image: TextureRect = $uploadedImage
@onready var file_dialog: FileDialog = $FileDialog

@export var is_game_local = false #true if tool is to be ran locally, false if it's for itch

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	image_upload_manager.image_loaded.connect(_on_image_loaded)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
	get_tree().change_scene_to_file("res://scenes/scene_creator.tscn")
