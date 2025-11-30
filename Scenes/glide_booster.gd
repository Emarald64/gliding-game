class_name GlideBooster extends Area2D

@export var boost:=1.5

const ParticleXSize=2
const ParticleYSizeFactor=10
const ParticleSpeedFactor=500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if has_node("CollisionShape2D"):
		var size=$CollisionShape2D.shape.size
		$GPUParticles2D.process_material=$GPUParticles2D.process_material.duplicate()
		$GPUParticles2D.process_material.emission_shape_offset.y=(size.y/2) - (boost*ParticleYSizeFactor/2)
		$GPUParticles2D.process_material.emission_box_extents.x=(size.x/2)-ParticleXSize
		$GPUParticles2D.process_material.initial_velocity_min=boost*ParticleSpeedFactor
		$GPUParticles2D.lifetime=(size.y-(boost*ParticleYSizeFactor))/(boost*ParticleSpeedFactor)
		
		$GPUParticles2D.amount=int(24*$GPUParticles2D.lifetime)
		
		$GPUParticles2D.process_material.scale_min=boost*ParticleYSizeFactor
		$GPUParticles2D.process_material.scale_curve.curve_x.set_point_value(0,ParticleXSize/boost/ParticleYSizeFactor)
		
		$GPUParticles2D.visibility_rect=Rect2(-size/2,size)
		
		var square = PackedVector2Array([Vector2(1,1),Vector2(-1,1),Vector2(-1,-1),(Vector2(1,-1))])
		$Polygon2D.polygon=square*Transform2D(0,size/2,0,Vector2.ZERO)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
