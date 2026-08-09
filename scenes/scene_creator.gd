extends Node2D

var image: Image = null
var default_sentence: String = "This is the default sentence"
var correct_sentences: Array[String]

var new_text_edit_position = 0

@onready var choose_image_button: Button = $ChooseImageButton
@onready var default_sentence_text: TextEdit = $DefaultSentenceText
@onready var add_correct_sentence_button: Button = $CorrectSentencesContainer/AddCorrectSentenceButton
@onready var correct_sentences_container: VBoxContainer = $CorrectSentencesContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_add_correct_sentence_button_pressed() -> void:
	var new_h_box = HBoxContainer.new()
	correct_sentences_container.add_child(new_h_box)
	var new_text_edit = TextEdit.new()
	new_h_box.add_child(new_text_edit)
	new_text_edit.scroll_fit_content_height = true
	new_text_edit.scroll_fit_content_width = true
	new_text_edit.placeholder_text = "Write correct sentence"
	new_text_edit.text_changed.connect(_on_default_sentence_text_text_changed)
	var new_image_button = AddImageButton.new() #maybe replace this button with a node specifically made for importing images
	new_h_box.add_child(new_image_button)

func _on_default_sentence_text_text_changed() -> void:
	default_sentence = default_sentence_text.text
	pass # Replace with function body.
