extends Node2D

@export var springCount:=3
@export var strength:=750
@export var glideLockTime:=.5

const springWidth=66

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(springCount):
		var spring = preload('res://Scenes/spring.tscn').instantiate()
		spring.position.x=springWidth*(i-(springCount/2.0))
		spring.strength=strength
		spring.glideLockTime=glideLockTime
		add_child(spring)
