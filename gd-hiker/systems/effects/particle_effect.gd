@tool
class_name ParticleEffect
extends CPUParticles3D

var pool: Array[CPUParticles3D]
var last_used_pool: Array[int]
@export var max_pool: int = 4;

func _ready() -> void:
	if !Engine.is_editor_hint():
		pool.push_back(self);
		last_used_pool.push_back(0);

func play_effect() -> void:
	if Engine.is_editor_hint():
		if self.emitting:
			self.restart();
		else:
			self.emitting = true;
		return;
	var i = 0;
	for item in pool:
		if item.emitting == false:
			item.emitting = true;
			last_used_pool[i] = Time.get_ticks_msec();
			return;
		i+=1;
	
	if pool.size() > max_pool:
		var mint = Time.get_ticks_msec()+1;
		var first_used_pool = -1;
		var j = 0;
		for t in last_used_pool:
			if t < mint:
				mint = t;
				first_used_pool = j;
			j+=1;
		pool[first_used_pool].restart();
		last_used_pool[first_used_pool] = Time.get_ticks_msec();
	else:
		var dup = self.duplicate();
		self.add_child(dup);
		(dup as ParticleEffect).transform = Transform3D.IDENTITY;
		pool.push_back(dup);
		dup.emitting = true;
		last_used_pool.push_back(Time.get_ticks_msec());
	
