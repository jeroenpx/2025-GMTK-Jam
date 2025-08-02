@tool
@icon("res://systems/map/icons/tree-solid-full.svg")
class_name GenerateTreesAssetLayer
extends Node3D

@export var lock_generation = false;

@export_category("EDIT/SAVE")
@export_tool_button("EDIT")
var _do_edit_state = _edit_state;

@export_tool_button("SAVE")
var _do_save_state = _save_state;

@export_category("Links")
@export var multi_meshes: Array[MultiMeshInstance3D];
@export_category("Placement Options")
@export var no_plant_zones: Array[String] = [];

@export var density: float = 0.2;

@export var min_scale: float = 0.5;
@export var max_scale: float = 1.0;

@export var max_turn: float = 1.0;
@export var terrain_tilt: float = 0.5;

@export var max_tilt_angle: float = 30;

@export_category("Edit State")
@export var edit_node: Node3D;

func _edit_state():
	if not edit_node:
		var edit_root = Node3D.new();
		edit_node = edit_root;
		edit_root.name = "EDIT "+name;
		get_tree().edited_scene_root.add_child(edit_root);
		edit_root.owner = get_tree().edited_scene_root;
	
	for m in range(multi_meshes.size()):
		var multimesh: MultiMeshInstance3D = multi_meshes[m];
		
		for i in range(multimesh.multimesh.instance_count):
			var child = MeshInstance3D.new();
			edit_node.add_child(child);
			child.owner = get_tree().edited_scene_root;
			child.mesh = multimesh.multimesh.mesh;
			child.transform = multimesh.multimesh.get_instance_transform(i);
		
		multimesh.visible = false;

func _save_state():
	for m in range(multi_meshes.size()):
		var multimesh: MultiMeshInstance3D = multi_meshes[m];
		
		var transforms: Array[Transform3D];
		
		for child in edit_node.get_children():
			if child is MeshInstance3D and (child as MeshInstance3D).mesh == multimesh.multimesh.mesh:
				transforms.push_back((child as Node3D).transform);
		
		var new_multi = MultiMesh.new();
		new_multi.transform_format = MultiMesh.TRANSFORM_3D;
		new_multi.mesh = multimesh.multimesh.mesh;
		new_multi.instance_count = transforms.size();
		new_multi.visible_instance_count = transforms.size();
		new_multi.custom_aabb = multimesh.multimesh.custom_aabb;
		
		for i in range(transforms.size()):
			new_multi.set_instance_transform(i, transforms[i]);
	
		multimesh.multimesh = new_multi;
		multimesh.visible = true;
	
	edit_node.get_parent().remove_child(edit_node);
	edit_node.free();
	edit_node = null;
