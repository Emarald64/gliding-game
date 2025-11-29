extends Area2D

func collected(player: Node2D) -> void:
	player.canGlide=true
	player.glideTime=0.0
	set_deferred("monitoring",false)
	hide()
	$RespawnTimer.start()


func respawn() -> void:
	monitoring=true
	show()
