class_name GlideBooster extends Area2D

@export var boost:=1.5

const ParticleXSize=2
const ParticleYSizeFactor=10
const ParticleSpeedFactor=500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GPUParticles2D.process_material.emission_shape_offset.y=$CollisionShape2D.shape.size.y/2
	$GPUParticles2D.process_material.emission_box_extents.x=$CollisionShape2D.shape.size.x/2
	$GPUParticles2D.process_material.initial_velocity_min=boost*ParticleSpeedFactor
	$GPUParticles2D.lifetime=$CollisionShape2D.shape.size.y/(boost*ParticleSpeedFactor)
	
	$GPUParticles2D.process_material.scale_min=boost*ParticleYSizeFactor
	$GPUParticles2D.process_material.scale_curve.curve_x.set_point_value(0,ParticleXSize/boost/ParticleYSizeFactor)
	
	$GPUParticles2D.visibility_rect=Rect2(-$CollisionShape2D.shape.size/2,$CollisionShape2D.shape.size)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
