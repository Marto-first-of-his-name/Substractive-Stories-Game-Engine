extends Node2D

@onready var karma_rich_label: RichTextLabel = $karmaRichLabel
@onready var final_karma_label: Label = $FinalKarmaLabel
@onready var restart_button: Button = $RestartButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func show_karma_text(karmas: Array[int], karma_judgements: Array[String]) -> void:
	var text := "[ul bullet=]"
	
	for idx in karmas.size():
		if karmas[idx] == null or karma_judgements[idx] == null:
			continue
		if idx != 0:
			text += "[br]"
		text += "["
		if karmas[idx] > 0:
			text += "+"
		text += str(karmas[idx], "] ", karma_judgements[idx])
		pass
	
	text += "[/ul]"
	karma_rich_label.text = text

func update_total_karma(karmas: Array[int]) -> void:
	var total_karma := 0
	for karma in karmas:
		if karma:
			total_karma += karma
	var karma_text := "Final Karma: "
	if total_karma > 0:
		karma_text += "+"
	karma_text += str(total_karma)
	final_karma_label.text =karma_text


func _on_restart_button_pressed() -> void:
	Global.game_controller.start_game()
