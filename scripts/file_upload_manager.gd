extends Node
class_name FileUploadManager

signal project_file_loaded(data: PackedByteArray)

var _file_callback: JavaScriptObject


func _ready() -> void:
	if OS.has_feature("web"):
		_file_callback = JavaScriptBridge.create_callback(_on_file_selected)


func open_file_picker() -> void:
	if not OS.has_feature("web"):
		push_warning("Project file import is only implemented for Web.")
		return

	var window := JavaScriptBridge.get_interface("window")
	window.godot_project_file_callback = _file_callback

	JavaScriptBridge.eval("""
		(() => {
			let input = document.getElementById("godot-project-file-import");

			if (!input) {
				input = document.createElement("input");
				input.type = "file";
				input.id = "godot-project-file-import";
				input.accept = ".glfr";

				input.addEventListener("change", async () => {
					const file = input.files[0];

					if (!file) {
						return;
					}

					const buffer = await file.arrayBuffer();

					if (window.godot_project_file_callback) {
						window.godot_project_file_callback(buffer);
					}

					input.value = "";
				});

				document.body.appendChild(input);
			}

			input.click();
		})();
	""")
	
func _on_file_selected(args: Array) -> void:
	if args.is_empty():
		return

	var js_buffer = args[0]

	if not JavaScriptBridge.is_js_buffer(js_buffer):
		push_error("Received data is not an ArrayBuffer.")
		return

	var data: PackedByteArray = \
		JavaScriptBridge.js_buffer_to_packed_byte_array(js_buffer)

	project_file_loaded.emit(data)
