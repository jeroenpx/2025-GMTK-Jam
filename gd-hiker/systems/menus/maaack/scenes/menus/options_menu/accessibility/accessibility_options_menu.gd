class_name ControlsOptionsMenu
extends Control

func _make_language_dropdown():
	var options = ["auto"];
	var options_labels: Array[String] = ["LanguageAutomatic"];
	for locale in TranslationServer.get_loaded_locales():
		var label = TranslationServer.get_translation_object(locale).get_message("CurrentLanguageName");
		options.append(locale);
		options_labels.append(label);
	%LanguageControl.option_values = options;
	%LanguageControl.option_titles = options_labels;
	%LanguageControl.lock_titles = true;
	
	%LanguageControl.value = AppSettings.get_language();

func _update_ui():
	%FlipHorizControl.value = AppSettings.get_camera_flip_x();
	%FlipVerticControl.value = AppSettings.get_camera_flip_y();
	%ShowSubtitlesControl.value = AppSettings.get_show_subtitles();
	%ScreenShakeControl.value = AppSettings.get_screen_shake();
	%CameraSensitivityControl.value = AppSettings.get_camera_sensitivity();
	
	_make_language_dropdown();

func _ready():
	_update_ui()

func _on_flip_horiz_control_setting_changed(value: Variant) -> void:
	AppSettings.set_camera_flip_x(value);

func _on_flip_vertic_control_setting_changed(value: Variant) -> void:
	AppSettings.set_camera_flip_y(value);

func _on_show_subtitles_control_setting_changed(value: Variant) -> void:
	AppSettings.set_show_subtitles(value);

func _on_screen_shake_control_setting_changed(value: Variant) -> void:
	AppSettings.set_screen_shake(value);

func _on_camera_sensitivity_control_setting_changed(value: Variant) -> void:
	AppSettings.set_camera_sensitivity(value);

func _on_language_control_setting_changed(value: Variant) -> void:
	AppSettings.set_language(value);
