extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const angleChangeFactor=1000
const StableGlideAngle=PI/6
const maxGlideSpeed=1500
const minGlideSpeed=75
const glideAccel=300
const glideDeccel=500

var glideSpeed:=0.0
var glideAngle:=0.0
#var glideRight:=true

var gliding=false
var canGlide=false

var facingRight:=true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if gliding:
			# Glide movement
			
			var maxAngleChange=delta * angleChangeFactor / glideSpeed
			
			var target_angle=StableGlideAngle+Input.get_axis("glide_up","glide_down")
			glideAngle=move_toward(glideAngle,target_angle,maxAngleChange)
			
			if glideAngle>StableGlideAngle:
				# Gliding down, Speed up
				$DebugGlideAngle.default_color=Color.WEB_GREEN
				glideSpeed=minf(maxGlideSpeed,glideSpeed+delta*glideAccel*(glideAngle-StableGlideAngle))
			else:
				# Gliding up, Slow down
				$DebugGlideAngle.default_color=Color.RED
				glideSpeed=maxf(minGlideSpeed,glideSpeed+delta*glideDeccel*(glideAngle-StableGlideAngle))
			velocity=Vector2.from_angle(glideAngle)*glideSpeed
			if not facingRight:
				velocity.x*=-1
			#Debug
			$DebugGlideSpeed.text=str(glideSpeed)
			var anglePoint=Vector2.from_angle(glideAngle)*100
			if not facingRight:
				anglePoint.x*=-1
			$DebugGlideAngle.set_point_position(1,anglePoint)
			print(glideAngle)
			
			if not Input.is_action_pressed('glide'):
				#End Glide
				gliding=false
				canGlide=false
		else:
			# Fall
			if Input.is_action_just_pressed("glide") and canGlide:
				gliding=true
				print(velocity.angle())
				glideSpeed=velocity.length()
				glideAngle=fmod(velocity.angle(),PI/2)
			velocity.y+=1000*delta
	else:
		gliding=false
		canGlide=true
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if not gliding:
		facingRight=direction>0
		velocity.x = direction * SPEED * (0.1 if gliding else 1.0)

	move_and_slide()
