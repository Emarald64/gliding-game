extends Area2D

@export var strength:=1000.0
@export var glideLockTime:=.5

func _on_body_entered(player: Node2D) -> void:
	$AnimatedSprite2D.play()
	if player.gliding:
		#glide spring
		if global_rotation!=0 and global_rotation!=PI:
			player.facingRight=signf(global_rotation)==1
		player.glideAngle=clampf(absf(global_rotation)-(PI/2),-PI/3,PI/3)
		player.glideSpeed=strength
	else:
		player.hasjumped=true
		player.coyoteStarted=true
		player.canGlide=true
		player.get_node("coyoteTimer").stop()
		player.velocity=Vector2(sin(global_rotation)*strength+(player.velocity.x),-cos(global_rotation)*strength)
	player.get_node('LockGliding').wait_time=glideLockTime
	player.get_node('LockGliding').start()
