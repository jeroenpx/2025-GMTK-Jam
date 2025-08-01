class_name VideoOptionsMenu
extends Control

func _preselect_resolution(window : Window):
	%ResolutionControl.value = window.size

func _update_resolution_options_enabled(window : Window):
	if OS.has_feature("web"):
		%ResolutionControl.editable = false
		%ResolutionControl.tooltip_text = "Disabled for web"
	elif AppSettings.is_fullscreen(window):
		%ResolutionControl.editable = false
		%ResolutionControl.tooltip_text = "Disabled for fullscreen"
	else:
		%ResolutionControl.editable = true
		%ResolutionControl.tooltip_text = "Select a screen size"

func _update_fps_cap():
	%MaxFPSControl.value = AppSettings.get_max_fps();

func _update_vsync_mode():
	%VSyncModeControl.value = AppSettings.get_vsync();
	
func _update_show_fps():
	%ShowFPSControl.value = AppSettings.get_show_fps_counter();

func _update_anti_aliasing():
	%AntialiasingControl.value = AppSettings.get_anti_aliasing();

func _update_ui(window : Window):
	%FullscreenControl.value = Config.get_config(AppSettings.VIDEO_SECTION, AppSettings.FULLSCREEN_ENABLED, AppSettings.is_fullscreen(window));
	_preselect_resolution(window)
	_update_resolution_options_enabled(window)
	_update_fps_cap()
	_update_vsync_mode()
	_update_show_fps()
	_update_anti_aliasing()

func _ready():
	var window : Window = get_window()
	_update_ui(window)
	window.connect("size_changed", _preselect_resolution.bind(window))

func _on_fullscreen_control_setting_changed(value):
	Config.set_config(AppSettings.VIDEO_SECTION, AppSettings.FULLSCREEN_ENABLED, value);
	var window : Window = get_window()
	AppSettings.set_fullscreen_enabled(value, window)
	_update_resolution_options_enabled(window)

func _on_resolution_control_setting_changed(value):
	AppSettings.set_resolution(value, get_window())

func _on_max_fps_control_setting_changed(value):
	AppSettings.set_max_fps(value);

func _on_v_sync_mode_control_setting_changed(value: Variant) -> void:
	AppSettings.set_vsync(value);

func _on_show_fps_control_setting_changed(value: Variant) -> void:
	AppSettings.set_show_fps_counter(value);

func _on_antialiasing_control_setting_changed(value: Variant) -> void:
	AppSettings.set_anti_aliasing(value, get_window());
