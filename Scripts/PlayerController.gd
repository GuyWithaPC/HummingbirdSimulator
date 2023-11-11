extends CharacterBody2D

@export var gravity = 100.0
@export var tilt_speed = 2.0

var throttle = gravity
var throttle_speed = gravity
var MAX_THROTTLE = gravity * 2

func _ready():
	$Sprite.play()

func adjust_throttle(amount: float):
	throttle = clamp(throttle + amount,0,MAX_THROTTLE)

func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Add the upwards acceleration
	velocity += Vector2.UP.rotated(rotation) * throttle * delta
	
	# Get the input direction and handle tilting/throttle
	var tilt_direction = Input.get_axis("left","right")
	var throttle_adjustment = Input.get_axis("down","up")
	adjust_throttle(throttle_adjustment * throttle_speed * delta)
	rotation += tilt_direction * tilt_speed * delta
	
	# Change the sprite speed depending on throttle
	$Sprite.speed_scale = (throttle / MAX_THROTTLE) * 20
	
	# Change the sprite direction depending on tilt
	if rotation <= 0:
		if $Sprite.flip_h:
			$Sprite.scale.x = move_toward($Sprite.scale.x, 0, delta*15)
			if $Sprite.scale.x < 0.1:
				$Sprite.flip_h = false
		else:
			$Sprite.scale.x = move_toward($Sprite.scale.x, 1, delta*15)
			$Sprite.flip_h = false
	else:
		if !$Sprite.flip_h:
			$Sprite.scale.x = move_toward($Sprite.scale.x, 0, delta*15)
			if $Sprite.scale.x < 0.1:
				$Sprite.flip_h = true
		else:
			$Sprite.scale.x = move_toward($Sprite.scale.x, 1, delta*15)
			$Sprite.flip_h = true

	move_and_slide()
