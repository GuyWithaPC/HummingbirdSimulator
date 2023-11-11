extends CharacterBody2D

@export var gravity = 500.0
@export var tilt_speed = 2.0

var begin_audio = preload("res://Audio/begin.ogg")
var succ = preload("res://Audio/slurp.ogg")
var bad_boom = preload("res://Prefabs/BadBoom.tscn")

var throttle = gravity
var throttle_speed = gravity
var MAX_THROTTLE = gravity * 2

var timer = 3.0

var nectar = 2.0

var look_out = false

var loser = false

func _ready():
	$Audio.stream = begin_audio
	$Audio.play()

func adjust_throttle(amount: float):
	throttle = clamp(throttle + amount,0,MAX_THROTTLE)

func _process(delta: float):
	if loser:
		return
	$Camera/GUI/ProgressBar.value = nectar
	for area in $Beak.get_overlapping_areas():
		if !area.is_in_group("Flowers"):
			continue
		nectar = clamp(nectar + area.get_nectar(delta),0,3)
	if (timer <= 0):
		nectar -= (throttle / MAX_THROTTLE) * (delta / 5)
		if nectar < 1 and !look_out:
			look_out = true
			$LookOut.play()
		if nectar > 1:
			look_out = false
		if nectar < 0:
			var boom = bad_boom.instantiate()
			get_parent().add_child(boom)
			boom.position = self.position
			self.hide()
			loser = true

func _physics_process(delta: float):
	if loser:
		return
	if (timer > 0):
		timer -= delta
		return
	else:
		$Sprite.play()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Add the upwards acceleration
	velocity += Vector2.UP.rotated($Sprite.rotation) * throttle * delta
	
	# Get the input direction and handle tilting/throttle
	var tilt_direction = Input.get_axis("left","right")
	var throttle_adjustment = Input.get_axis("down","up")
	adjust_throttle(throttle_adjustment * throttle_speed * delta)
	$Sprite.rotation += tilt_direction * tilt_speed * delta
	
	# Change the sprite speed depending on throttle
	$Sprite.speed_scale = (throttle / MAX_THROTTLE) * 20
	
	# Change the sprite direction depending on tilt
	if $Sprite.rotation <= 0:
		if $Sprite.flip_h:
			$Sprite.scale.x = move_toward($Sprite.scale.x, 0, delta*10)
			$Beak.position.x = move_toward($Beak.position.x, 0, delta*50)
			if $Sprite.scale.x < 0.1:
				$Sprite.flip_h = false
		else:
			$Sprite.scale.x = move_toward($Sprite.scale.x, 1, delta*10)
			$Beak.position.x = move_toward($Beak.position.x, -12, delta*50)
			$Sprite.flip_h = false
	else:
		if !$Sprite.flip_h:
			$Sprite.scale.x = move_toward($Sprite.scale.x, 0, delta*10)
			$Beak.position.x = move_toward($Beak.position.x, 0, delta*50)
			if $Sprite.scale.x < 0.1:
				$Sprite.flip_h = true
		else:
			$Sprite.scale.x = move_toward($Sprite.scale.x, 1, delta*10)
			$Beak.position.x = move_toward($Beak.position.x, 12, delta*50)
			$Sprite.flip_h = true

	move_and_slide()
