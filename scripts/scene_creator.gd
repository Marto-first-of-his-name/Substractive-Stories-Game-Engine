extends Node2D

var scene: Scene
var new_sentence_id: int = 0
var available_scenes: Array[Scene]

@onready var scene_name_text_edit: TextEdit = $SceneNameTextEdit
@onready var scene_id_label: Label = $SceneIDLabel
@onready var select_default_image_button: SelectFileButton = $SelectDefaultImageButton
@onready var default_image_label: Label = $defaultImageLabel
@onready var default_sentence_text: TextEdit = $DefaultSentenceText
@onready var add_correct_sentence_button: Button = $AddCorrectSentenceButton
@onready var correct_sentences_container: VBoxContainer = $ScrollContainer/MarginContainer/CorrectSentencesContainer
@onready var max_word_count_spin_box: SpinBox = $MaxWordCountSpinBox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	available_scenes = Global.game_controller.get_current_project().get_scenes()

func make_new_scene(next_available_scene_id: int) -> void:
	scene = Scene.new()
	scene.id = next_available_scene_id
	scene_id_label.text = str("S-",scene.id)
	scene.scene_name = str("Scene ",scene.id)
	scene_name_text_edit.text = scene.scene_name

func display_scene_to_edit() -> void:
	scene_id_label.text = str("S-",scene.id)
	scene_name_text_edit.text = scene.scene_name
	if scene.default_image_path:
		default_image_label.text = scene.default_image_path.get_file()
	else:
		default_image_label.text = "No default image selected"
	default_sentence_text.text = scene.default_sentence
	max_word_count_spin_box.value = scene.max_word_count
	for cs in scene.correct_sentences:
		create_correct_sentence(cs, true)
		
	print("loaded scene")



func create_correct_sentence(cs: CorrectSentence, is_recreation: bool) -> void:
	var new_correct_sentence : CorrectSentence
	if not is_recreation:
		new_correct_sentence = CorrectSentence.new()
		scene.correct_sentences.append(new_correct_sentence)
	
	#new Hbox
	var new_h_box := HBoxContainer.new()
	correct_sentences_container.add_child(new_h_box)
	
	#id
	var id_label := Label.new()
	id_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	if is_recreation:
		id_label.text = str(cs.id)
		new_sentence_id = cs.id + 1
	else:
		id_label.text = str(new_sentence_id)
		new_correct_sentence.id = new_sentence_id
		new_sentence_id += 1
	new_h_box.add_child(id_label)
	
	#new vbox for three texts
	var new_v_box_texts := VBoxContainer.new()
	new_h_box.add_child(new_v_box_texts)
	
	#add text box Correct Sentence
	var new_correct_sentence_text := TextEdit.new()
	new_correct_sentence_text.scroll_fit_content_height = true
	new_correct_sentence_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	new_correct_sentence_text.custom_minimum_size = Vector2(600, 0)
	new_correct_sentence_text.placeholder_text = "Write correct sentence*"
	if is_recreation:
		new_correct_sentence_text.text = cs.sentence
		new_correct_sentence_text.text_changed.connect(_on_correct_sentence_text_changed.bind(cs, new_correct_sentence_text))
	else:
		new_correct_sentence_text.text_changed.connect(_on_correct_sentence_text_changed.bind(new_correct_sentence, new_correct_sentence_text))
	new_v_box_texts.add_child(new_correct_sentence_text)
	
	#add text box Follow Up Sentence
	var new_correct_sentence_follow_up := TextEdit.new()
	new_correct_sentence_follow_up.scroll_fit_content_height = true
	new_correct_sentence_follow_up.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	new_correct_sentence_follow_up.custom_minimum_size = Vector2(600, 0)
	new_correct_sentence_follow_up.placeholder_text = "Write follow up sentence"
	if is_recreation:
		new_correct_sentence_follow_up.text = cs.follow_up_sentence
		new_correct_sentence_follow_up.text_changed.connect(_on_follow_up_sentence_text_changed.bind(cs, new_correct_sentence_follow_up))
	else:
		new_correct_sentence_follow_up.text_changed.connect(_on_follow_up_sentence_text_changed.bind(new_correct_sentence, new_correct_sentence_follow_up))
	new_v_box_texts.add_child(new_correct_sentence_follow_up)
	
	#add text box karma judgement
	var new_karma_sentence := TextEdit.new()
	new_karma_sentence.scroll_fit_content_height = true
	new_karma_sentence.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	new_karma_sentence.custom_minimum_size = Vector2(600, 0)
	new_karma_sentence.placeholder_text = "Write karma judgement"
	if is_recreation:
		new_karma_sentence.text = cs.karma_judgement
		new_karma_sentence.text_changed.connect(_on_karma_sentence_text_changed.bind(cs, new_karma_sentence))
	else:
		new_karma_sentence.text_changed.connect(_on_karma_sentence_text_changed.bind(new_correct_sentence, new_karma_sentence))
	new_v_box_texts.add_child(new_karma_sentence)
	
	#new vbox for image and hint and karma
	var new_v_box_image := VBoxContainer.new()
	new_h_box.add_child(new_v_box_image)
	
	#add selectImageButton and image label
	var select_image_button := SelectFileButton.new()
	var image_label := Label.new()
	
	select_image_button.button_text = "Select image"
	select_image_button.folder_to_read = "res://game_assets/images/"
	if is_recreation:
		select_image_button.fileSelected.connect(_on_correct_sentence_image_selected.bind(cs,image_label))
	else:
		select_image_button.fileSelected.connect(_on_correct_sentence_image_selected.bind(new_correct_sentence,image_label))
	new_v_box_image.add_child(select_image_button)
	
	image_label.add_theme_font_size_override("font_size",10)
	image_label.custom_minimum_size = Vector2(0,26)
	if is_recreation and cs.image_path:
		image_label.text = cs.image_path.get_file()
	else:
		image_label.text = "No Image selected"
	new_v_box_image.add_child(image_label)
	
	#add karma SpinBox and label
	var karma_label := Label.new()
	karma_label.add_theme_font_size_override("font_size",10)
	karma_label.text = "Karma"
	var karma_spinbox := SpinBox.new()
	karma_spinbox.min_value = -100000
	karma_spinbox.max_value = 100000
	if is_recreation:
		karma_spinbox.value = cs.karma
		karma_spinbox.value_changed.connect(_on_karma_spin_box_value_changed.bind(cs))
	else:
		karma_spinbox.value_changed.connect(_on_karma_spin_box_value_changed.bind(new_correct_sentence))
	new_v_box_image.add_child(karma_label)
	new_v_box_image.add_child(karma_spinbox)
	
	
	#add Select Next Scene OptionButton
	var select_next_option_button := OptionButton.new()
	select_next_option_button.add_item("Select next scene")
	#select_next_option_button.set_item_disabled(0, true)
	select_next_option_button.custom_minimum_size = Vector2(200,0)
	select_next_option_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	new_h_box.add_child(select_next_option_button)
	if is_recreation:
		select_next_option_button.item_selected.connect(_on_next_scene_select.bind(select_next_option_button,cs))
	else:
		select_next_option_button.item_selected.connect(_on_next_scene_select.bind(select_next_option_button,new_correct_sentence))
	
	var selected_idx := 0
	#populate select next scene list
	if not available_scenes.is_empty():
		var idx := 1
		for s in available_scenes:
			if is_recreation:
				if cs.next_scene_id == s.get_id():
					selected_idx = idx
			select_next_option_button.add_item(str(s.get_id(), "-", s.scene_name), s.get_id())
			idx += 1
	select_next_option_button.select(selected_idx)

	#add deleteSentenceButton
	var delete_sentence_button := Button.new()
	delete_sentence_button.text = "Delete entry"
	delete_sentence_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	if is_recreation:
		delete_sentence_button.pressed.connect(_on_delete_sentence_button_pressed.bind(cs, new_h_box))
	else:
		delete_sentence_button.pressed.connect(_on_delete_sentence_button_pressed.bind(new_correct_sentence, new_h_box))
	new_h_box.add_child(delete_sentence_button)


func _on_add_correct_sentence_button_pressed() -> void:
	create_correct_sentence(null, false)

func _on_next_scene_select(index:int, select_next_button:OptionButton, correct_sentence:CorrectSentence) -> void:
	var id := select_next_button.get_item_id(index)
	var s := Global.game_controller.get_scene_from_id(id)
	if s:
		correct_sentence.next_scene_id = s.get_id()
		print("next scene saved")
	

func _on_correct_sentence_text_changed(correct_sentence: CorrectSentence, new_correct_sentence_text_edit: TextEdit) -> void:
	correct_sentence.sentence = new_correct_sentence_text_edit.text
	print("correct_sentence is:", correct_sentence)
	print("text of correct sentence-", correct_sentence.id, " saved")

func _on_follow_up_sentence_text_changed(correct_sentence: CorrectSentence, new_correct_sentence_follow_up: TextEdit) -> void:
	correct_sentence.follow_up_sentence = new_correct_sentence_follow_up.text
	print("follow up text of correct sentence-", correct_sentence.id, " saved")

func _on_karma_sentence_text_changed(correct_sentence: CorrectSentence, new_karma_judgement: TextEdit) -> void:
	correct_sentence.karma_judgement = new_karma_judgement.text
	print("karma of sentence-", correct_sentence.id, " saved")

func _on_karma_spin_box_value_changed(value: float, correct_sentence: CorrectSentence) -> void:
	correct_sentence.karma = int(value)
	print("karma value saved: ", value)

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

func _on_max_word_count_spin_box_value_changed(value: float) -> void:
	scene.max_word_count = int(value)
	print("max word count saved: ", value)

func _on_scene_name_text_edit_text_changed() -> void:
	scene.scene_name = scene_name_text_edit.text
	print("Scene name saved")



func _on_save_and_exit_button_pressed() -> void:
	Global.game_controller.save_scene(scene)
	Global.game_controller.return_to_project_editor()
