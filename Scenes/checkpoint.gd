class_name Checkpoint extends Area2D

var active:=false

func activate(player: Node2D) -> void:
	if not active:
		if player.checkpoint is Checkpoint:
			player.checkpoint.deactivate()
		player.checkpoint=self
		player.get_node("Camera2D").add_trauma(0.3)
		$AnimatedSprite2D.play("activate")
		active=true
	
func deactivate() -> void:
	$AnimatedSprite2D.play("default")
	active=false
