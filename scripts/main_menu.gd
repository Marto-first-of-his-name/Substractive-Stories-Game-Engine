extends Node2D

@onready var file_dialog: FileDialog = $ImportGlfrButton/FileDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_create_new_button_pressed() -> void:
	Global.game_controller.start_project_editor(null)


func _on_import_glfr_button_pressed() -> void:
	#code here to use file dialog to select project
	file_dialog.popup_centered()

func import_project(path: String) -> GameGLFR:
	return 

func _on_file_dialog_file_selected(path: String) -> void:
	Global.game_controller.start_project_editor(import_project(path))
