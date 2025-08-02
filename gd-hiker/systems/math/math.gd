class_name Math

# Get the time needed to accelerate to a certain speed
# Note: acceleration is expected to be the CORRECTED value that corresponds to distance traveled in one second of acceleration
static func time_for_accelerated_to_speed(acceleration: float, resulting_speed: float) -> float:
	return resulting_speed/(2*acceleration)

# Get the time needed to travel a certain distance
# Note: acceleration is expected to be the CORRECTED value that corresponds to distance traveled in one second of acceleration
static func time_for_accelerated_to_distance(acceleration: float, speed: float, resulting_distance: float) -> float:
	assert(acceleration > 0)# cannot be 0 in this formula
	assert(speed >= 0)
	assert(resulting_distance >=0)
	return (speed + sqrt(speed*speed+4*acceleration*resulting_distance))/(2*acceleration)

static func speed_after_time(acceleration: float, time: float) -> float:
	return 2 * acceleration * time

static func distance_after_time(acceleration: float, time: float) -> float:
	return acceleration * time * time


#
# Helper functions
#
static func between(a: float, min: float, max: float) -> bool:
	return a < max and a > min

# Calculate the correction to apply to the acceleration to make 
# it move exactly the same distance after 1 second
static func acceleration_correction(delta: float) -> float:
	var distance: float = 0;
	var speed: float = 0;
	var fps: int = roundi(1.0/delta)
	for i in range(0, fps):
		speed += delta
		distance += speed * delta
	return 1.0 / distance

# Add delta to input in either direction
static func clamp_shift(input: float, duration: float, delta: float, increment: bool) -> float:
	if increment:
		input += 1/duration * delta;
		if input > 1:
			input = 1;
	else: 
		input -= 1/duration * delta;
		if input < 0:
			input = 0;
	return input;
