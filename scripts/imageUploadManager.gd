extends Node
class_name ImageUploadManager

signal image_loaded(image: Image)

const SAVE_PATH := "user://uploaded_image.png"

var _file_callback: JavaScriptObject


func _ready() -> void:
	# The JavaScriptBridge only exists in Web exports.
	if OS.has_feature("web"):
		_file_callback = JavaScriptBridge.create_callback(_on_file_selected)

	# Try to restore an image from a previous session.
	load_saved_image()


func open_file_picker() -> void:
	if not OS.has_feature("web"):
		push_warning("Image upload is only implemented for Web.")
		return

	# Create the browser file input and trigger it.
	JavaScriptBridge.eval("""
        (() => {
			let input = document.getElementById("godot-image-upload");

            if (!input) {
				input = document.createElement("input");
				input.type = "file";
				input.id = "godot-image-upload";
				input.accept = "image/png,image/jpeg";

				input.addEventListener("change", async () => {
                    const file = input.files[0];

                    if (!file) {
                        return;
                    }

                    const buffer = await file.arrayBuffer();

                    if (window.godot_image_upload_callback) {
                        window.godot_image_upload_callback(buffer);
                    }

					input.value = "";
                });

                document.body.appendChild(input);
            }

            input.click();
        })();
	""")

	# Store the callback where JavaScript can access it.
	var window := JavaScriptBridge.get_interface("window")
	window.godot_image_upload_callback = _file_callback


func _on_file_selected(args: Array) -> void:
	if args.is_empty():
		return

	var js_buffer = args[0]

	if not JavaScriptBridge.is_js_buffer(js_buffer):
		push_error("Received data is not an ArrayBuffer.")
		return

	var data: PackedByteArray = \
		JavaScriptBridge.js_buffer_to_packed_byte_array(js_buffer)

	_process_image_data(data)


func _process_image_data(data: PackedByteArray) -> void:
	var image := Image.new()

	var error := image.load_png_from_buffer(data)

	if error != OK:
		error = image.load_jpg_from_buffer(data)

	if error != OK:
		push_error("Could not load selected image.")
		return

	# Save the image so it survives restarting the game.
	error = image.save_png(SAVE_PATH)

	if error != OK:
		push_error("Could not save uploaded image.")
		return

	# Notify whoever is interested.
	image_loaded.emit(image)


func load_saved_image() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var image := Image.load_from_file(SAVE_PATH)

	if image == null:
		push_error("Could not load saved image.")
		return

	image_loaded.emit(image)
