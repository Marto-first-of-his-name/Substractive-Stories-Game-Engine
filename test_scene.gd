extends Node2D

@onready var sentence_label: RichTextLabel = $sentencelabel
var sentence := "Once upon a time, there was a hero named Gallafrey."
var default_sentence_words: Array[String]
var active_words: Array[bool]
var correct_sentence_words:= [["Once", "there", "was", "a", "Gallafrey"],["there", "was", "a", "hero"]]
var hovered_word := -1

#DO THISSSSSSSSSSSSSSS
#try to make correct sentences to active words like structure


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_sentence_words = split_sentence_in_words(sentence)
	init_active_words()
	build_rich_sentence_from_words(default_sentence_words)

func init_active_words() -> void:
	for i in default_sentence_words.size():
		active_words.append(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func split_sentence_in_words(sentence: String) -> Array[String]:
	var array :Array[String] = []
	for s in sentence.split(" ", false):
		array.append(s)
	return array

func build_rich_sentence_from_words(words_array) -> void:
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


func _on_sentencelabel_meta_hover_started(meta: Variant) -> void:
	sentence_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hovered_word = int(meta)
	build_rich_sentence_from_words(default_sentence_words)


func _on_sentencelabel_meta_hover_ended(meta: Variant) -> void:
	sentence_label.mouse_default_cursor_shape = Control.CURSOR_ARROW
	hovered_word = -1
	build_rich_sentence_from_words(default_sentence_words)
	
