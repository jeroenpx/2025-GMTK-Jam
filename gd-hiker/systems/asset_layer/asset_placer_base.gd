@tool
#icon: res://systems/asset_layer/icons/arrows-down-to-line-solid-full.svg
@icon("uid://c8t2kgb3p5ch2")
class_name AssetPlacerBase
extends Node3D

@export var seed: int;

@export_tool_button("Generate")
var _do_generate = _generate;

@export_tool_button("Randomize")
var _do_randomize = _randomize;

func _randomize():
	seed += 1;
	_generate();

func _generate():
	_generate_impl()

var rng = RandomNumberGenerator.new();

# 
# Abstract functions
#
func _calculate_bounds() -> Rect2:
	return Rect2(0, 0, 20, 20);

func _add_one(layer: AssetLayer, output: Array[Transform3D]) -> void:
	pass

func _gen_aabb(bounds: Rect2) -> AABB:
	return AABB(Vector3(bounds.position.x, 0, bounds.position.y), Vector3(bounds.size.x, 10, bounds.size.y))

#
# General Implementation
#

func _generate_impl():
	rng.seed = seed;
	for layer in get_children():
		if layer is AssetLayer:
			_generate_layer(layer);

func _generate_layer(layer: AssetLayer):
	if layer.lock_generation:
		return;
	
	var bounds = _calculate_bounds();
	var area = bounds.size.x * bounds.size.y;
	var amount = floori(area * layer.density) / layer.multi_meshes.size();
	
	for m in range(layer.multi_meshes.size()):
		var transforms: Array[Transform3D] = [];
		
		for i in range(floori(amount)):
			_add_one(layer, transforms);
		
		# Write it to the MultiMesh
		var aabb = _gen_aabb(bounds);
		layer.write(layer.multi_meshes[m], transforms, aabb);
