class_name SceneTemplate extends Node2D

#data imported from scene
var scene: Scene
var max_word_count: int
var default_image: Texture2D
var default_sentence: String
var cs_images: Array[Texture2D]
var correct_sentences: Array[String]
var follow_ups: Array[String]
var karma_judgements: Array[String]
var karmas: Array[int]
var next_scene_ids: Array[int]

# data created here
var active_words: Array[bool]
var default_sentence_words: Array[String]
var correct_sentences_words: Array
var hovered_word := -1
var correct_sentence_id := -1

#nodes
var image_sprite2d: Sprite2D
var word_count_label: RichTextLabel
var sentence_label: RichTextLabel
var continue_button: Button
var exit_button: Button

static func create(scene_to_create: Scene) -> SceneTemplate:
	var instance := SceneTemplate.new()
	instance.scene = scene_to_create
	instance.get_data_from_scene(scene_to_create)
	return instance


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialise_nodes()
	default_sentence_words = split_sentence_in_words(default_sentence)
	for cs in correct_sentences:
		correct_sentences_words.append(split_sentence_in_words(cs))
	init_active_words()
	build_rich_sentence_from_words(default_sentence_words, true)
	update_word_count_label()
	set_image(default_image)


func initialise_nodes() -> void:
	
	#image
	image_sprite2d = Sprite2D.new()
	image_sprite2d.position = Vector2(576,324)
	add_child(image_sprite2d)
	
	#word count label
	word_count_label = RichTextLabel.new()
	word_count_label.bbcode_enabled = true
	word_count_label.fit_content = true
	word_count_label.set("theme_override_colors/default_color", Color(0.0, 0.0, 0.0, 1.0))
	word_count_label.custom_minimum_size = Vector2(800,0)
	word_count_label.position = Vector2(100,50)
	add_child(word_count_label)
	
	#sentence_label
	sentence_label = RichTextLabel.new()
	sentence_label.bbcode_enabled = true
	sentence_label.fit_content = false
	sentence_label.size = Vector2(1000,150)
	sentence_label.meta_underlined = false
	sentence_label.set("theme_override_font_sizes/normal_font_size", 32)
	sentence_label.set("theme_override_colors/default_color", Color(0.0, 0.0, 0.0, 1.0))
	sentence_label.custom_minimum_size = Vector2(1000,0)
	sentence_label.position = Vector2(100,85)
	sentence_label.meta_hover_started.connect(_on_sentencelabel_meta_hover_started)
	sentence_label.meta_hover_ended.connect(_on_sentencelabel_meta_hover_ended)
	sentence_label.meta_clicked.connect(_on_sentencelabel_meta_clicked)
	add_child(sentence_label)
	
	#continue button
	continue_button = Button.new()
	continue_button.text = "Continue"
	continue_button.disabled = true
	continue_button.position = Vector2(980, 570)
	continue_button.pressed.connect(_on_continue_button_pressed_first)
	add_child(continue_button)
	
	#exit button
	exit_button = Button.new()
	exit_button.text = "Return to editor"
	exit_button.position = Vector2(994, 11)
	exit_button.pressed.connect(_on_exit_button_pressed)
	add_child(exit_button)

func set_image(texture: Texture2D) -> void:
	image_sprite2d.texture = texture

func split_sentence_in_words(sentence_full: String) -> Array[String]:
	var array :Array[String] = []
	for s in sentence_full.split(" ", false):
		array.append(s)
	return array

func init_active_words() -> void:
	for i in default_sentence_words.size():
		active_words.append(true)

func build_rich_sentence_from_words(words_array: Array[String], is_reactive: bool) -> void:
	var text := ""
	var idx := 0
	for word in words_array:
		if is_reactive:
			text += str("[url=", idx, "]")
		if not active_words[idx]:
			text += "[color=DIM_GRAY][s color=DIM_GRAY]"
		if hovered_word == idx and is_reactive:
			if active_words[idx]:
				text += "[s]"
			else:
				text += "[u color=BLACK]"
		
		text += word
		
		if hovered_word == idx and is_reactive:
			if active_words[idx]:
				text += "[/s]"
			else:
				text += "[/u]"
		if not active_words[idx]:
			text += "[/s][/color]"
		if is_reactive:
			text += "[/url]"
		text += " "
		idx += 1
	sentence_label.text = text


func update_word_count_label() -> void:
	var text := "Word count: "
	if get_active_word_count() > max_word_count:
		text += "[color=RED]"
	text += str(get_active_word_count())
	if get_active_word_count() > max_word_count:
		text += "[/color]"
	text += "/"
	text += str(max_word_count)
	text += " words"
	
	word_count_label.text = text


func get_active_word_count() -> int:
	var result := 0
	for active in active_words:
		if active:
			result += 1
	return result

func get_texture_from_path(path: String) -> Texture2D:
	var image := Image.load_from_file(path)
	if image:
		return ImageTexture.create_from_image(image)
	return null

func get_data_from_scene(scene_with_data:Scene) -> void:
	max_word_count = scene_with_data.max_word_count
	default_image = get_texture_from_path(scene_with_data.default_image_path)
	default_sentence = scene_with_data.default_sentence
	for cs in scene_with_data.correct_sentences:
		correct_sentences.append(cs.sentence)
		cs_images.append(get_texture_from_path(cs.image_path))
		follow_ups.append(cs.follow_up_sentence)
		karma_judgements.append(cs.karma_judgement)
		karmas.append(cs.karma)
		next_scene_ids.append(cs.next_scene_id)


func _on_sentencelabel_meta_clicked(meta: Variant) -> void:
	print("mouse clicked: ", meta)
	#flip active
	active_words[int(meta)] = not active_words[int(meta)]
	build_rich_sentence_from_words(default_sentence_words, true)
	update_word_count_label()
	check_scene_complete()


func make_current_sentence_words() -> Array[String]:
	var current_sentence_in_words : Array[String]
	var idx := 0
	for active in active_words:
		if active:
			current_sentence_in_words.append(default_sentence_words[idx])
		idx += 1
	return current_sentence_in_words

func is_current_sentence_correct() -> bool:
	var current_sentence_in_words := make_current_sentence_words()
	
	for csw: Array in correct_sentences_words:
		if current_sentence_in_words == csw:
			return true
	return false


func current_sentence_is_what_correct_sentence_id() -> int:
	#returns >= 0 if the current sentence is correct 
	#and -1 if the current sentence isn't actually correct 
	var current_sentence_in_words := make_current_sentence_words()
	
	var idx := 0
	for csw: Array in correct_sentences_words:
		if current_sentence_in_words == csw:
			return idx
		idx += 1
	return -1

func check_scene_complete() -> bool:
	if not is_current_sentence_correct() or get_active_word_count() > max_word_count :
		continue_button.disabled = true
		set_image(default_image)
		return false
		
	correct_sentence_id = current_sentence_is_what_correct_sentence_id()
	if cs_images[correct_sentence_id]:
		set_image(cs_images[correct_sentence_id])
	else:
		set_image(default_image)
	continue_button.disabled = false
	return true

func _on_sentencelabel_meta_hover_started(meta: Variant) -> void:
	sentence_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hovered_word = int(meta)
	build_rich_sentence_from_words(default_sentence_words, true)

func _on_sentencelabel_meta_hover_ended(meta: Variant) -> void:
	sentence_label.mouse_default_cursor_shape = Control.CURSOR_ARROW
	if hovered_word == int(meta):
		hovered_word = -1
	build_rich_sentence_from_words(default_sentence_words, true)

func _on_continue_button_pressed_first() -> void:
	if correct_sentence_id < 0:
		print("error, correct_sentence_id is < 0")
		return
	var follow_up: String = follow_ups[correct_sentence_id] if follow_ups[correct_sentence_id]!=null else ""
	show_follow_up_text_and_go_next(follow_up)

func _on_continue_button_pressed_again() -> void:
	continue_button.disabled = true
	var next_scene_id : int = next_scene_ids[correct_sentence_id]
	if next_scene_id == 0:
		print("go to judgement")
		return
	if next_scene_id > 0:
		Global.game_controller.load_scene_template(next_scene_id)

func show_follow_up_text_and_go_next(text: String) -> void:
	build_rich_sentence_from_words(default_sentence_words, false)
	sentence_label.append_text(text)
	continue_button.pressed.disconnect(_on_continue_button_pressed_first)
	continue_button.pressed.connect(_on_continue_button_pressed_again)

func _on_exit_button_pressed() -> void:
	Global.game_controller.return_to_project_editor()
