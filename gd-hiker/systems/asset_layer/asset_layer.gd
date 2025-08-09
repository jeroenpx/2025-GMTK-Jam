@tool
#icon: res://systems/asset_layer/icons/tree-solid-full.svg
@icon("uid://caasxh4psnxd")
class_name AssetLayer
extends Node3D

@export var lock_generation = false;

@export_category("EDIT/SAVE")
@export_tool_button("EDIT")
var _do_edit_state = _edit_state;

@export_tool_button("SAVE")
var _do_save_state = _save_state;

@export_category("Links")
@export var multi_meshes: Array[MultiMeshInstance3D];

@export_category("External Placement Options")
@export var no_plant_zones: Array[String] = [];
@export var density: float = 0.2;

@export_category("Standard Placement Options")
@export var min_scale: float = 0.5;
@export var max_scale: float = 1.0;

@export var max_turn: float = 360.0;
@export var terrain_tilt: float = 0.5;

@export var max_tilt_angle: float = 30;

@export_category("Edit State")
@export var edit_node: Node3D;

# Get a new Transform placement for an asset
# Two steps: 
# 1. collect randoms
# 2. apply them to the position + normal
func placement(rng: RandomNumberGenerator) -> Callable:
	var scalerand = rng.randf_range(self.min_scale, self.max_scale);
	var turnrng = rng.randf()*deg_to_rad(self.max_turn)*2.0-1.0;
	var tiltrng = rng.randf()*deg_to_rad(self.max_tilt_angle);
	var tiltdir = rng.randf()*PI*2;
	
	return func (point: Vector3, normal: Vector3) -> Transform3D:
		# Make the tilt transform
		var tilt = Basis(Quaternion(Vector3(0, 1, 0), tiltdir) * Quaternion(Vector3(1, 0, 0), tiltrng) * Quaternion(Vector3(0, 1, 0), -tiltdir));
		# Make the transform
		return Transform3D(tilt * Basis(lerp(Vector3(0,1,0), normal, self.terrain_tilt).normalized(), turnrng).scaled(Vector3(1,1,1)*scalerand), point);

# Write a list of transforms to a MultiMeshInstance3D
# Also works in the Editor
func write(mminst: MultiMeshInstance3D, transforms: Array[Transform3D], aabb: AABB) -> void:
	var new_multi = MultiMesh.new();
	new_multi.transform_format = MultiMesh.TRANSFORM_3D;
	new_multi.mesh = mminst.multimesh.mesh;
	new_multi.instance_count = transforms.size();
	new_multi.visible_instance_count = transforms.size();
	new_multi.custom_aabb = mminst.multimesh.custom_aabb;
	
	for i in range(transforms.size()):
		new_multi.set_instance_transform(i, transforms[i]);

	mminst.multimesh = new_multi;
	mminst.visible = true;

#
# EDITOR HELPER FUNCTIONS (toggle editing of this layer)
#

# Editor Only - enter edit state
func _edit_state():
	if not edit_node:
		var edit_root = Node3D.new();
		edit_node = edit_root;
		edit_root.name = "EDIT "+name;
		get_tree().edited_scene_root.add_child(edit_root);
		edit_root.owner = get_tree().edited_scene_root;
	
	for m in range(multi_meshes.size()):
		var mminst: MultiMeshInstance3D = multi_meshes[m];
		
		for i in range(mminst.multimesh.instance_count):
			var child = MeshInstance3D.new();
			edit_node.add_child(child);
			child.owner = get_tree().edited_scene_root;
			child.mesh = mminst.multimesh.mesh;
			child.transform = mminst.multimesh.get_instance_transform(i);
		
		mminst.visible = false;

# Editor Only - exit edit state
func _save_state():
	for m in range(multi_meshes.size()):
		var mminst: MultiMeshInstance3D = multi_meshes[m];
		
		var transforms: Array[Transform3D];
		
		for child in edit_node.get_children():
			if child is MeshInstance3D and (child as MeshInstance3D).mesh == mminst.multimesh.mesh:
				transforms.push_back((child as Node3D).transform);
		
		write(mminst, transforms, mminst.multimesh.custom_aabb);
		mminst.visible = true;
	
	edit_node.get_parent().remove_child(edit_node);
	edit_node.free();
	edit_node = null;
