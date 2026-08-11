extends Node
class_name FileUploadManager

signal files_loaded(files: Array)

var _file_callback: JavaScriptObject


func _ready() -> void:
	if OS.has_feature("web"):
		_file_callback = JavaScriptBridge.create_callback(_on_files_selected)


func open_file_picker(
	accepted_file_types: String,
	multiple_files: bool
) -> void:
	if not OS.has_feature("web"):
		push_warning("File upload is only implemented for Web.")
		return

	var window := JavaScriptBridge.get_interface("window")
	window.godot_file_upload_callback = _file_callback

	var multiple := "true" if multiple_files else "false"

	JavaScriptBridge.eval("""
		(() => {
			let input = document.getElementById("godot-file-upload");

			if (!input) {
				input = document.createElement("input");
				input.type = "file";
				input.id = "godot-file-upload";

				input.addEventListener("change", async () => {
					const files = input.files;

					if (!files || files.length === 0) {
						return;
					}

					for (let i = 0; i < files.length; i++) {
						const file = files[i];
						const buffer = await file.arrayBuffer();

						if (window.godot_file_upload_callback) {
							window.godot_file_upload_callback(
								file.name,
								buffer,
								i === files.length - 1
							);
						}
					}

					input.value = "";
				});

				document.body.appendChild(input);
			}

			input.accept = "%s";
			input.multiple = %s;
			input.click();
		})();
	""" % [accepted_file_types, multiple])

func _on_files_selected(args: Array) -> void:
	if args.size() < 3:
		push_error("Invalid file upload callback.")
		return

	var filename: String = args[0]
	var js_buffer = args[1]
	var is_last: bool = args[2]

	if not JavaScriptBridge.is_js_buffer(js_buffer):
		push_error("Received file data is not an ArrayBuffer.")
		return

	var data := JavaScriptBridge.js_buffer_to_packed_byte_array(js_buffer)

	if data.is_empty():
		push_error("Received empty file: " + filename)
		return

	var files: Array = [{
		"name": filename,
		"data": data
	}]

	save_uploaded_files(files)

	files_loaded.emit(files)

const ASSET_FOLDER := "user://game_assets"


func save_uploaded_files(files: Array) -> void:
	var dir := DirAccess.open("user://")

	if dir == null:
		push_error("Could not open user directory")
		return

	var error := dir.make_dir_recursive("game_assets")

	if error != OK and error != ERR_ALREADY_EXISTS:
		push_error("Could not create asset directory")
		return

	@warning_ignore("untyped_declaration")
	for file in files:
		var filename: String = file["name"]
		var data: PackedByteArray = file["data"]

		var path := get_unique_file_path(filename)

		var output := FileAccess.open(path, FileAccess.WRITE)

		if output == null:
			push_error("Could not save file: " + path)
			continue

		output.store_buffer(data)
		output.close()

		print("Saved uploaded file: ", path)

func get_unique_file_path(filename: String) -> String:
	var path := ASSET_FOLDER.path_join(filename)

	if not FileAccess.file_exists(path):
		return path

	var extension := filename.get_extension()
	var basename := filename.get_basename()
	var counter := 1

	while true:
		var new_filename: String

		if extension.is_empty():
			new_filename = "%s_%d" % [basename, counter]
		else:
			new_filename = "%s_%d.%s" % [
				basename,
				counter,
				extension
			]

		path = ASSET_FOLDER.path_join(new_filename)

		if not FileAccess.file_exists(path):
			return path

		counter += 1
	return path

func _create_asset_directory() -> void:
	var dir := DirAccess.open("user://")

	if dir == null:
		push_error("Could not open user://")
		return

	var error := dir.make_dir_recursive("game_assets")

	if error != OK and error != ERR_ALREADY_EXISTS:
		push_error("Could not create game_assets: " + str(error))
