@tool
class_name SoundEffectUi
extends AudioStreamPlayer

@export var samples:Array[AudioStream];
var rng = RandomNumberGenerator.new();
@export var active: bool = true;

@export var skip_last_sample: bool = false;

@export_category("Chance Randomizer")
@export var chance: float = 1.0;

@export_category("Pitch Randomizer")
@export var pitch_min: float = 1.0;
@export var pitch_max: float = 1.0;
@export var pitch_shift: float = 0.0;
@export_category("Volume Randomizer")
@export var volume_min: float = 0.0;
@export var volume_max: float = 0.0;
@export var volume_shift: float = 0.0;

var last_sample: int = 0;

@export_category("Debug")
@export var try: bool:
	set(value):
		if Engine.is_editor_hint():
			play_effect();

func play_effect() -> void:
	if active:
		if rng.randf() > chance:
			return;
		if samples.size() > 0:
			if last_sample == TYPE_NIL:
				last_sample = 0;
			var sampleidx = 0;
			if samples.size() > 1:
				var available_samples = samples.size();
				if skip_last_sample:
					available_samples-=1;
				sampleidx = rng.randi_range(0, available_samples-1);
				if skip_last_sample and sampleidx >= last_sample:
					sampleidx+=1;
			last_sample = sampleidx;
			var sample = samples[sampleidx];
			stream = sample;
			pitch_scale = pitch_shift + rng.randf_range(pitch_min, pitch_max);
			volume_db = volume_shift + rng.randf_range(volume_min, volume_max);
			play();
