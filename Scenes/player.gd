extends CharacterBody2D


const MaxWalkSpeed = 400
const WalkAccel=2000

#Gliding
const angleChangeFactor=50
const StableGlideAngle=PI/12
const maxGlideSpeed=1000
const minGlideSpeed=150
const glideAccel=700
const glideDecel=500
const HalfAngleRange=PI/5
const GlideBoostAngleChangeFactor=-StableGlideAngle
const GlideSpriteScale=Vector2(1.5,0.75)
const StableGlideTime=3.0

const maxJumpTime:=0.125
const JUMP_ACCEL:=-3000.0
const JUMP_VELOCITY = -300.0

const FallAccel:=1000.0
const MaxFallSpeed:=1500.0

const TrailLength=20

var hasjumped:=false
var jumpTime:=0.0
var coyoteStarted:=false

@onready var baseSpriteScale=$Sprite2D.scale.x

var glideSpeed:=0.0
var glideAngle:=0.0
var glideTime:=0.0

var gliding=false
var canGlide=false
var facingRight:=true

var deathCount:=0

@onready var checkpoint:Node2D=get_node('../StartPoint')

func _physics_process(delta: float) -> void:
	#print(delta)
	if not is_on_floor():
		if gliding:
			if $LockGliding.is_stopped():
				glideTime+=delta
				
				# Glide movement
				var maxAngleChange=delta * angleChangeFactor / sqrt(glideSpeed)
				
				var boost=getGlideBoostAmmount()
				if boost!=0:print("boost:"+str(boost))
				
				var currentStableAngle=(boost*GlideBoostAngleChangeFactor)+StableGlideAngle+maxf((glideTime-StableGlideTime)*PI/12,0)
				var target_angle=clampf(currentStableAngle+(Input.get_axis("glide_up","glide_down")*HalfAngleRange),-PI/2,PI/2)
				if target_angle<currentStableAngle and is_equal_approx(glideSpeed,minGlideSpeed) and boost<1:
					target_angle=min(currentStableAngle,PI/2)
				glideAngle=move_toward(glideAngle,target_angle,maxAngleChange)
				
				if (glideAngle>currentStableAngle+(boost*GlideBoostAngleChangeFactor))==(boost<=1):
					# Gliding down, Speed up
					$DebugGlideAngle.default_color=Color.WEB_GREEN
					glideSpeed=minf(maxGlideSpeed,glideSpeed+delta*glideAccel*(glideAngle-currentStableAngle)*(1-boost))
				else:
					# Gliding up, Slow down
					$DebugGlideAngle.default_color=Color.RED
					glideSpeed=maxf(minGlideSpeed,glideSpeed+delta*glideDecel*(glideAngle-currentStableAngle)*(1-boost))
			
			velocity=Vector2.from_angle(glideAngle)*glideSpeed
			if not facingRight:
				velocity.x*=-1
			#Debug
			$DebugGlideSpeed.text=str(roundf(glideSpeed*100)/100)
			#var anglePoint=Vector2.from_angle(currentStableAngle)*100
			#if not facingRight:
				#anglePoint.x*=-1
			#$DebugGlideAngle.set_point_position(1,anglePoint)
			#print("glideAngle"+str(currentStableAngle))
			#print("stableAngle"+str(StableGlideAngle+(boost*GlideBoostAngleChangeFactor)))
			
			if not Input.is_action_pressed('glide') or is_on_wall():
				#End Glide
				stopGlide()
				#canGlide=false
		else:
			# Fall
			if Input.is_action_just_pressed("glide") and canGlide:
				#Start Glide
				$Sprite2D.scale*=GlideSpriteScale
				$CollisionShape2D.shape.size*=GlideSpriteScale
				gliding=true
				glideSpeed=velocity.length()
				glideAngle=clampf(absf(velocity.angle()+PI/2)-(PI/2),StableGlideAngle-HalfAngleRange,StableGlideAngle+HalfAngleRange)
				canGlide=false
				glideTime=0.0
			velocity.y=minf(velocity.y+((1000-(getGlideBoostAmmount()*200))*delta),MaxFallSpeed)
			if not coyoteStarted:
				$coyoteTimer.start()
				coyoteStarted=true
	else:
		# On ground
		if gliding:
			stopGlide()
		canGlide=true
		coyoteStarted=false
		hasjumped=false
	
	#Jump
	if ((Input.is_action_pressed("jump") and jumpTime<maxJumpTime) or (Input.is_action_just_pressed("jump") and (not $coyoteTimer.is_stopped() or is_on_floor()))):
		$coyoteTimer.stop()
		if not hasjumped:
			jumpTime=0.0
		var jump=(JUMP_VELOCITY if not hasjumped and Input.is_action_just_pressed("jump") else 0.0) + (delta*JUMP_ACCEL) if jumpTime+delta<maxJumpTime else (maxJumpTime-jumpTime)*JUMP_ACCEL
		print(jump)
		velocity.y=minf(velocity.y,0)+jump
		jumpTime+=delta

		hasjumped=true
	else:jumpTime=maxJumpTime
	
	if Input.is_action_just_pressed("respawn"):
		respawn()
	
	var direction := Input.get_axis("move_left", "move_right")
	if not gliding:
		if direction:
			$Sprite2D.scale.x=baseSpriteScale*signf(direction)
			facingRight=direction>0
			velocity.x = clampf(velocity.x+(direction*delta*WalkAccel*(1.0 if is_on_floor() else 0.5)*(2 if signf(velocity.x) != signf(direction) else 1)),-MaxWalkSpeed,MaxWalkSpeed)
		else:
			velocity.x=move_toward(velocity.x,0,WalkAccel*delta*(2 if is_on_floor() else 1))
	move_and_slide()
	
	if $Trail.get_point_count()>TrailLength:
		$Trail.remove_point(TrailLength)
	$Trail.add_point(global_position,0)

func respawn()->void:
	global_position=checkpoint.global_position
	velocity=Vector2.ZERO
	$Camera2D.add_trauma(0.3)
	resetTrail()
	deathCount+=1
	get_tree().call_group('refreshOnDeath','refresh')
	if gliding:stopGlide()

func stopGlide()->void:
	$Sprite2D.scale/=GlideSpriteScale
	$CollisionShape2D.shape.size/=GlideSpriteScale
	gliding=false
	
func getGlideBoostAmmount()->float:
	if $GlideBoostDetector.has_overlapping_areas():
		var booster=$GlideBoostDetector.get_overlapping_areas()[0]
		assert(booster is GlideBooster)
		return booster.boost
	return 0

func resetTrail()->void:
	$Trail.clear_points()
