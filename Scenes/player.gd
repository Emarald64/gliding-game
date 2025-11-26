extends CharacterBody2D


const MaxWalkSpeed = 400
const WalkAccel=2000
const JUMP_VELOCITY = -600.0

#Gliding
const angleChangeFactor=500
const StableGlideAngle=PI/12
const maxGlideSpeed=1000
const minGlideSpeed=75
const glideAccel=500
const glideDecel=700
const HalfAngleRange=0.5

const GlideSpriteScale=Vector2(1.5,0.75)

@onready var baseSpriteScale=$Sprite2D.scale.x

var glideSpeed:=0.0
var glideAngle:=0.0

var gliding=false
var canGlide=false
var facingRight:=true

@onready var checkpoint:Node2D=get_node('../StartPoint')

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if gliding:
			# Glide movement
			var maxAngleChange=delta * angleChangeFactor / glideSpeed
			
			var target_angle=StableGlideAngle+(Input.get_axis("glide_up","glide_down")*HalfAngleRange)
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
			$DebugGlideSpeed.text=str(roundf(glideSpeed*100)/100)
			var anglePoint=Vector2.from_angle(glideAngle)*100
			if not facingRight:
				anglePoint.x*=-1
			$DebugGlideAngle.set_point_position(1,anglePoint)
			#print(glideAngle)
			
			if not Input.is_action_pressed('glide'):
				#End Glide
				stopGlide()
				canGlide=false
		else:
			# Fall
			if Input.is_action_just_pressed("glide") and canGlide:
				#Start Glide
				$Sprite2D.scale*=GlideSpriteScale
				$CollisionShape2D.shape.size*=GlideSpriteScale
				gliding=true
				glideSpeed=velocity.length()
				glideAngle=clampf(fmod(velocity.angle(),PI/2),StableGlideAngle-HalfAngleRange,StableGlideAngle+HalfAngleRange)
			velocity.y+=1000*delta
	else:
		# On ground
		if gliding:
			stopGlide()
		canGlide=true
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("respawn"):
		respawn()
	
	var direction := Input.get_axis("move_left", "move_right")
	if not gliding:
		if direction:
			$Sprite2D.scale.x=baseSpriteScale*signf(direction)
			facingRight=direction>0
			velocity.x = clampf(velocity.x+(direction*delta*WalkAccel*(0.1 if gliding else 1.0)*(2 if signf(velocity.x) != signf(direction) else 1)),-MaxWalkSpeed,MaxWalkSpeed)
		else:
			velocity.x=move_toward(velocity.x,0,WalkAccel*delta*2)
	move_and_slide()

func respawn()->void:
	global_position=checkpoint.global_position
	velocity=Vector2.ZERO
	if gliding:stopGlide()

func stopGlide()->void:
	$Sprite2D.scale/=GlideSpriteScale
	$CollisionShape2D.shape.size/=GlideSpriteScale
	gliding=false
