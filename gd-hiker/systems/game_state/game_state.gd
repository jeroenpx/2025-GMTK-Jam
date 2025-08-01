extends Node3D

enum State {
	RUNNING,
	CINEMATIC,
}

var state: State = State.RUNNING;
var running_cinematic: String = "";
var running_interaction: String = "";
var paused: bool = false;
var minimized: bool = false;
var in_dev_menu: bool = false;
var end_game_state: bool = false;

signal on_game_state_changed;
signal on_cinematic_ending;
signal on_cinematic_started;

func shouldAcceptCharacterInput() -> bool:
	return state == State.RUNNING and not paused and running_interaction == "" and not end_game_state;

func shouldRunPhysics() -> bool:
	return state == State.RUNNING and not paused and not end_game_state;

func isGameplayRunning() -> bool:
	return state == State.RUNNING and not paused and running_interaction == "" and not end_game_state;

func isGameplayRunningForInteraction(interaction) -> bool:
	return state == State.RUNNING and not paused and (running_interaction == "" or running_interaction == interaction) and not end_game_state;

# NOTE: isGamePaused should be checked as well to pause the cinematic
func isCinematicOngoing(name: String) -> bool:
	return state == State.CINEMATIC and running_cinematic == name;

func isInMainMenu() -> bool:
	return isCinematicOngoing("main_menu");
	
func isInLoading() -> bool:
	return isCinematicOngoing("loading");

func isInDevMenu() -> bool:
	return in_dev_menu;
	
func inEndGame() -> bool:
	return end_game_state;

# Should the world be at a complete standstill? (e.g. game paused or minimized)
func isWorldPaused() -> bool:
	return minimized or paused or in_dev_menu or end_game_state;

func isGamePaused() -> bool:
	return paused or in_dev_menu or end_game_state;

func isGameMinimized() -> bool:
	return minimized;


#
# CHANGE STATE
#
func enter_cinematic(name: String) -> void:
	if state == State.CINEMATIC and name == "":
		# Stop cinematics
		state = State.RUNNING;
		running_cinematic = "";
		on_game_state_changed.emit();
		on_cinematic_ending.emit();
		return;
	
	var previous_state = state;
	if state == State.RUNNING or state == State.CINEMATIC:
		# Start (next) cinematic
		
		# Change
		state = State.CINEMATIC;
		var cine_change = running_cinematic != name;
		if cine_change:
			on_cinematic_ending.emit();
			running_cinematic = name;
		
		# Emit
		if previous_state != state:
			on_game_state_changed.emit();
		if cine_change:
			on_cinematic_started.emit();

func enter_endgame_state() -> void:
	end_game_state = true;
	on_game_state_changed.emit();
	
func exit_endgame_state() -> void:
	end_game_state = false;
	on_game_state_changed.emit();

func enterInteraction(interaction: String) -> void:
	running_interaction = interaction;
	on_game_state_changed.emit();

func pauseGame() -> void:
	if isInMainMenu() or isInLoading():
		return;
	
	if !paused:
		paused = true;
		on_game_state_changed.emit();

func enterDevMenu() -> void:
	if OS.is_debug_build():
		if not in_dev_menu:
			paused = true;
			in_dev_menu = true;
			on_game_state_changed.emit();

func enterGameMinimized() -> void:
	minimized = true;
	on_game_state_changed.emit();

func exitGameMinimized() -> void:
	minimized = false;
	on_game_state_changed.emit();

func continueGame() -> void:
	if paused or in_dev_menu:
		paused = false;
		in_dev_menu = false;
		on_game_state_changed.emit();
