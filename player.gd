extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -300.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction != 0 and velocity.x * direction >= 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED/12.0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/3.0)

	move_and_slide()
