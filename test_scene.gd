extends Node2D
@onready var wordcountlabel: RichTextLabel = $wordcountlabel

@onready var sentence_label: RichTextLabel = $sentencelabel
@onready var continue_button: Button = $ContinueButton
var sentence := "Once upon a time, there was a hero named Gallafrey."
var default_sentence_words: Array[String]
var active_words: Array[bool]
var correct_sentence_words:= [["Once", "there", "was", "a", "Gallafrey."],["Once", "there", "was", "a", "hero", "named", "Gallafrey."],["there", "was", "a", "hero"]]
var hovered_word := -1
var next_scene_id := -1

#already there
var max_word_count:= 8
var default_image:= ImageTexture.create_from_image(Image.load_from_file("res://Gallafrey.png"))
var default_sentence: String
var cs_images:= [ImageTexture.create_from_image(Image.load_from_file("res://Gallafrey.png")),null,ImageTexture.create_from_image(Image.load_from_file("res://icon.svg"))]
var correct_sentences: Array[String]
var follow_ups := ["It was literally just a guy.", null, "But the hero had amnesiaaaa"]
var karma_judgements:= ["you made glfr an npc", "you are a hero","you gave glfr amnesia"]
var karmas := [0, +30, -30]
var next_scene_ids:= [1,null, 3]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_sentence_words = split_sentence_in_words(sentence)
	init_active_words()
	build_rich_sentence_from_words(default_sentence_words)
	update_word_count_label()


func init_active_words() -> void:
	for i in default_sentence_words.size():
		active_words.append(true)


func split_sentence_in_words(sentence_full: String) -> Array[String]:
	var array :Array[String] = []
	for s in sentence_full.split(" ", false):
		array.append(s)
	return array

#use is_current_sentence_correct first to check
#returns 0 if the next scene is judgment and -1 if the current sentence isn't actually correct 
func current_sentence_is_what_next_scene_id() -> int:
	var current_sentence_in_words := make_current_sentence_words()
	
	var idx := 0
	for csw: Array in correct_sentence_words:
		if current_sentence_in_words == csw:
			return next_scene_ids[idx] if not next_scene_ids[idx] == null else 0
		idx += 1
	return -1

func is_current_sentence_correct() -> bool:
	var current_sentence_in_words := make_current_sentence_words()
	
	for csw: Array in correct_sentence_words:
		if current_sentence_in_words == csw:
			return true
	return false

func make_current_sentence_words() -> Array[String]:
	var current_sentence_in_words : Array[String]
	var idx := 0
	for active in active_words:
		if active:
			current_sentence_in_words.append(default_sentence_words[idx])
		idx += 1
	return current_sentence_in_words

func get_active_word_count() -> int:
	var result := 0
	for active in active_words:
		if active:
			result += 1
	return result

func check_scene_complete() -> bool:
	if not is_current_sentence_correct() or get_active_word_count() > max_word_count :
		continue_button.disabled = true
		return false
		
	next_scene_id = current_sentence_is_what_next_scene_id()
	if next_scene_id >= 0:
		continue_button.disabled = false
	return true

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
	
	wordcountlabel.text = text

func build_rich_sentence_from_words(words_array: Array[String]) -> void:
	var text := ""
	var idx := 0
	for word in words_array:
		text += str("[url=", idx, "]")
		if not active_words[idx]:
			text += "[color=DIM_GRAY][s color=DIM_GRAY]"
		if hovered_word == idx:
			if active_words[idx]:
				text += "[s]"
			else:
				text += "[u color=BLACK]"
		
		text += word
		
		if hovered_word == idx:
			if active_words[idx]:
				text += "[/s]"
			else:
				text += "[/u]"
		if not active_words[idx]:
			text += "[/s][/color]"
		text += "[/url] "
		idx += 1
	sentence_label.text = text
	

func _on_sentencelabel_mouse_entered() -> void:
	pass # Replace with function body.


func _on_sentencelabel_meta_clicked(meta: Variant) -> void:
	print("mouse clicked: ", meta)
	#flip active
	active_words[int(meta)] = not active_words[int(meta)]
	build_rich_sentence_from_words(default_sentence_words)
	update_word_count_label()
	check_scene_complete()


func _on_sentencelabel_meta_hover_started(meta: Variant) -> void:
	sentence_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hovered_word = int(meta)
	build_rich_sentence_from_words(default_sentence_words)


func _on_sentencelabel_meta_hover_ended(meta: Variant) -> void:
	sentence_label.mouse_default_cursor_shape = Control.CURSOR_ARROW
	if hovered_word == int(meta):
		hovered_word = -1
	build_rich_sentence_from_words(default_sentence_words)
	


func _on_continue_button_pressed() -> void:
	if next_scene_id < 0:
		print("error, next scene id is < 0")
		return
	if next_scene_id == 0:
		print("go to judgement")
		return
	if next_scene_id > 0:
		Global.game_controller.load_scene_template(next_scene_id)
