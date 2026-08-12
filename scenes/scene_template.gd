class_name SceneTemplate extends Node2D

#data
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

#nodes
var image_sprite2d: Sprite2D
var word_count_label: RichTextLabel
var sentence_label: RichTextLabel

static func create(scene: Scene) -> SceneTemplate:
	var instance := SceneTemplate.new()
	instance.scene = scene
	instance.get_data_from_scene(scene)
	return instance


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	"res://Gallafrey.png"

	pass # Replace with function body.


func initialise_nodes() -> void:
	
	#sprite 2D
	sprite2d = Sprite2D.new()


func get_texture_from_path(path: String) -> Texture2D:
	var image := Image.load_from_file(path)
	if image:
		return ImageTexture.create_from_image(image)
	return null

func get_data_from_scene(scene:Scene) -> void:
	max_word_count = scene.max_word_count
	default_image = get_texture_from_path(scene.default_image_path)
	default_sentence = scene.default_sentence
	for cs in scene.correct_sentences:
		correct_sentences.append(cs.sentence)
		cs_images.append(get_texture_from_path(cs.image_path))
		follow_ups.append(cs.follow_up_sentence)
		karma_judgements.append(cs.karma_judgement)
		karmas.append(cs.karma)
		next_scene_ids.append(cs.next_scene_id)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
