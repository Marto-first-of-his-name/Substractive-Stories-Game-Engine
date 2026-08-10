extends Node2D

var scene: Scene
var new_sentence_id: int = 0
var available_scenes: Array[Scene]

@onready var scene_id_label: Label = $SceneIDLabel
@onready var select_default_image_button: SelectFileButton = $SelectDefaultImageButton
@onready var default_image_label: Label = $defaultImageLabel
@onready var default_sentence_text: TextEdit = $DefaultSentenceText
@onready var add_correct_sentence_button: Button = $CorrectSentencesContainer/AddCorrectSentenceButton
@onready var correct_sentences_container: VBoxContainer = $CorrectSentencesContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene = Scene.new()


func _on_add_correct_sentence_button_pressed() -> void:
	var new_correct_sentence := CorrectSentence.new()
	
	#new Hbox
	var new_h_box := HBoxContainer.new()
	correct_sentences_container.add_child(new_h_box)
	
	#id
	var id_label := Label.new()
	id_label.text = str(new_sentence_id)
	id_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	new_correct_sentence.id = new_sentence_id
	new_sentence_id += 1
	scene.correct_sentences.append(new_correct_sentence)
	new_h_box.add_child(id_label)
	
	
	#new vbox for both texts
	var new_v_box_texts := VBoxContainer.new()
	new_h_box.add_child(new_v_box_texts)
	
	#add text box Correct Sentence
	var new_correct_sentence_text := TextEdit.new()
	new_correct_sentence_text.scroll_fit_content_height = true
	new_correct_sentence_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	new_correct_sentence_text.custom_minimum_size = Vector2(800, 0)
	new_correct_sentence_text.placeholder_text = "Write correct sentence"
	new_correct_sentence_text.text_changed.connect(_on_correct_sentence_text_changed.bind(new_correct_sentence, new_correct_sentence_text.text))
	new_v_box_texts.add_child(new_correct_sentence_text)
	
	#add text box Follow Up Sentence
	var new_correct_sentence_follow_up := TextEdit.new()
	new_correct_sentence_follow_up.scroll_fit_content_height = true
	new_correct_sentence_follow_up.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	new_correct_sentence_follow_up.custom_minimum_size = Vector2(800, 0)
	new_correct_sentence_follow_up.placeholder_text = "Write follow up sentence"
	new_correct_sentence_follow_up.text_changed.connect(_on_follow_up_sentence_text_changed.bind(new_correct_sentence, new_correct_sentence_follow_up.text))
	new_v_box_texts.add_child(new_correct_sentence_follow_up)
	
	
	#new vbox for image and hint
	var new_v_box_image := VBoxContainer.new()
	new_h_box.add_child(new_v_box_image)
	
	#add selectImageButton and image label
	var select_image_button := SelectFileButton.new()
	var image_label := Label.new()
	
	select_image_button.button_text = "Select image"
	select_image_button.folder_to_read = "res://game_assets/images/"
	select_image_button.fileSelected.connect(_on_correct_sentence_image_selected.bind(new_correct_sentence,image_label))
	new_v_box_image.add_child(select_image_button)
	
	image_label.add_theme_font_size_override("font_size",10)
	image_label.text = "No Image selected"
	new_v_box_image.add_child(image_label)
	
	#add Select Next Scene OptionButton
	var select_next_option_button := OptionButton.new()
	select_next_option_button.add_item("Select an option")
	select_next_option_button.set_item_disabled(0, true)
	select_next_option_button.select(0)
	select_next_option_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_h_box.add_child(select_next_option_button)
	
	#populate select next scene list
	if not available_scenes.is_empty():
		var idx_id = 1
		for s in available_scenes:
			select_next_option_button.add_item(str(s.id) + s.name)
			select_next_option_button.set_item_id(idx_id, s.id)
	
	#add deleteSentenceButton
	var delete_sentence_button := Button.new()
	delete_sentence_button.text = "Delete entry"
	delete_sentence_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	delete_sentence_button.pressed.connect(_on_delete_sentence_button_pressed.bind(new_correct_sentence, new_h_box))
	new_h_box.add_child(delete_sentence_button)

func _on_correct_sentence_text_changed(correct_sentence: CorrectSentence, new_text:String) -> void:
	correct_sentence.sentence = new_text
	print("text of correct sentence-", correct_sentence.id, " saved")

func _on_follow_up_sentence_text_changed(correct_sentence: CorrectSentence, new_text:String) -> void:
	correct_sentence.follow_up_sentence = new_text
	print("follow up text of correct sentence-", correct_sentence.id, " saved")

func _on_correct_sentence_image_selected(image_path: String, correct_sentence:CorrectSentence, image_label: Label) -> void:
	correct_sentence.image_path = image_path
	image_label.text = image_path.get_file()
	print("path to correct sentence-", correct_sentence.id, " image saved")


func _on_default_sentence_text_text_changed() -> void:
	scene.default_sentence = default_sentence_text.text
	print("default sentence saved")

func _on_default_image_selected(image_path: String) -> void:
	scene.default_image_path = image_path
	default_image_label.text = image_path.get_file()
	print("path to default image saved")

func _on_delete_sentence_button_pressed(correct_sentence: CorrectSentence, h_box: HBoxContainer) -> void:
	scene.correct_sentences.erase(correct_sentence)
	h_box.queue_free()
