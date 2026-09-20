extends CharacterBody2D

@onready var stat_monitor := get_node("Camera2D").get_node("Stat Monitor")
@onready var movement_noise := get_node("MovementNoise")

const SPEED := 150.0
const TURN_BOOST := 100.0
const JUMP := -300.0
const JUMP_EXTRA := -550.0
const WALL_SLIDE := 50.0
var jump_timer := 0.0;
var turn_boost_timer := 0.0
var turn_boost_on := false
var direction = 0.0
var jump_coyote_time = 0.0
var air_timeout = 0.0

func is_wall_sliding() -> bool:
	return is_on_wall_only() and \
	(sign(Input.get_axis("left", "right")) == -sign(get_wall_normal().x))

func _physics_process(delta: float) -> void:
	# Get movement direction
	direction = Input.get_axis("left", "right")
	# Timers
	air_timeout -= delta
	jump_timer -= delta
	jump_coyote_time -= delta
	turn_boost_timer -= delta
	
	# Add the gravity, or wall slide
	if is_wall_sliding():
		velocity.y = move_toward(velocity.y, WALL_SLIDE, 5.0)
	elif not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_wall_sliding() or is_on_floor():
		jump_coyote_time = 0.2

	# Wall jump
	if Input.is_action_just_pressed("jump") and is_wall_sliding():
		velocity.y = JUMP * 2/3
		velocity.x = -direction*SPEED
		air_timeout = 0.2
	# Other jumps
	elif Input.is_action_just_pressed("jump") and (is_on_floor() or jump_coyote_time > 0):
		# Boost jump
		if abs(velocity.x) >= SPEED*1.1:
			velocity.y = JUMP*1.2 # If speed is 10% more than max, jump 20% more
		# Basic jump
		else:
			velocity.y = JUMP
	
	if Input.is_action_pressed("jump") and jump_timer >= 0 and velocity.y < 0 and not is_wall_sliding():
		velocity.y += JUMP_EXTRA*delta 
	else:
		jump_timer = 1;
	
	# Basic horizontal movement
	if is_on_floor():
		# Turn boost
		if velocity.x * direction < -130.0 or (turn_boost_timer >= 0 and turn_boost_on):
			velocity.x = move_toward(velocity.x, direction * (SPEED + TURN_BOOST), SPEED/6.0)
			turn_boost_on = true;
		
		elif velocity.x * direction >= 0:
			if abs(velocity.x) < abs(SPEED):
				velocity.x = move_toward(velocity.x, direction * SPEED, SPEED/24.0)
			else:
				velocity.x = move_toward(velocity.x, direction * SPEED, SPEED/96.0)
			
			turn_boost_timer = 0.5;
			turn_boost_on = false;
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED/3.0)
			turn_boost_timer = 0.5;
			turn_boost_on = false;
	else:
		# Airborne physics
		if direction != 0 and velocity.x * direction <= SPEED and air_timeout <= 0.0:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED/6.0)
		turn_boost_timer = 0.5;
		turn_boost_on = false;
	
	# Finalise movement
	move_and_slide()
	stat_monitor.text = "H: " + str(velocity.x) + "\nV: " + str(-velocity.y) + "\nOn floor: " + str(is_on_floor()) + "\nWall sliding: " + str(is_wall_sliding())
	
	# Modify movement sfx
	var pitch_ratio = clamp(abs(velocity.length()) / SPEED, 0.0, 1.7)/1.7
	movement_noise.pitch_scale = lerp(0.7, 1.2, pitch_ratio)
	
	var volume_ratio = clamp(abs(velocity.length()) / SPEED, 0.0, 1.0)
	movement_noise.volume_linear = lerp(0.0, 0.5, volume_ratio)
	
	# Mute if in the air
	if not (is_on_floor() or is_wall_sliding()):
		movement_noise.volume_linear = 0.0
