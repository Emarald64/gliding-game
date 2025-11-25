extends CharacterBody2D


const MaxWalkSpeed = 400
const WalkAccel=1000
const JUMP_VELOCITY = -600.0

#Gliding
const angleChangeFactor=500
const StableGlideAngle=PI/12
const maxGlideSpeed=1000
const minGlideSpeed=75
const glideAccel=700
const glideDecel=700

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
			if target_angle<StableGlideAngle and is_equal_approx(glideSpeed,minGlideSpeed):
				target_angle=StableGlideAngle
			glideAngle=move_toward(glideAngle,target_angle,maxAngleChange)
			
			if glideAngle>StableGlideAngle:
				# Gliding down, Speed up
				$DebugGlideAngle.default_color=Color.WEB_GREEN
				glideSpeed=minf(maxGlideSpeed,glideSpeed+delta*glideAccel*(glideAngle-StableGlideAngle))
			else:
				# Gliding up, Slow down
				$DebugGlideAngle.default_color=Color.RED
				glideSpeed=maxf(minGlideSpeed,glideSpeed+delta*glideDecel*(glideAngle-StableGlideAngle))
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
	if direction:
		velocity.x = clampf(velocity.x+(direction*delta*WalkAccel*(0.1 if gliding else 1.0)),-MaxWalkSpeed,MaxWalkSpeed)
	elif not gliding:
		velocity.x=move_toward(velocity.x,0,WalkAccel*delta)
	move_and_slide()
