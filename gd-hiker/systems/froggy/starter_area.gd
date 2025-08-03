extends Node

signal on_enter_car;
signal on_exit_car;


func _on_froggy_inside_car_act() -> void:
	on_enter_car.emit();


func _on_froggy_exit_car_act() -> void:
	on_exit_car.emit();
