class_name GlideBooster extends Area2D

@export var boost:=1.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CPUParticles2D.position.y=$CollisionShape2D.shape.size.y/2
	$CPUParticles2D.emission_rect_extents.x=$CollisionShape2D.shape.size.x/2
	$CPUParticles2D.initial_velocity_min=boost*500
	$CPUParticles2D.lifetime=$CollisionShape2D.shape.size.y/(boost*500)
	
	$CPUParticles2D.scale_amount_min=boost*10
	$CPUParticles2D.scale_curve_x.set_point_value(0,0.2/boost)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
