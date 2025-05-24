extends Node3D

var boids = []
var rand = RandomNumberGenerator.new()
#var thread:Thread
@export var boidCopy:MeshInstance3D
@export var numberOfBoids = 10
@export_category("Separation")
@export var separationRange = 0.0
@export var avoidFactor = 0.0

@export_category("Alignment")
@export var visibleRange = 0.0
@export var matchingFactor = 0.0

@export_category("Cohesion")
@export var centeringFactor = 0.0

@export_category("Turning and Speed")
@export var maxVelocity = 0.0
@export var minVelocity = 0.0
@export var turningFactor = 0.0

func _ready() -> void:
	
	for n in numberOfBoids:
		for m in numberOfBoids:
			var tempBoid = RigidBody3D.new()
			tempBoid.gravity_scale = 0.0
			tempBoid.add_child(boidCopy.duplicate())
			
			tempBoid.get_child(0).visible = true
			tempBoid.transform = Transform3D(Basis.IDENTITY, Vector3(float(n * 10), 0.0, float(m * 10)))
			var randVelX = rand.randf_range(-1.0, 1.0)
			var randVelZ = rand.randf_range(-1.0, 1.0)
			tempBoid.linear_velocity = Vector3(randVelX * maxVelocity, 0.0, randVelZ * maxVelocity)
		
			boids.append(tempBoid)
			self.add_child(tempBoid)
	
	
	
func _process(_delta: float) -> void:
	print(Engine.get_frames_per_second())
	
func boidCalcs(b:RigidBody3D) -> void:
	#Separation variables
		var closeX = 0.0
		var closeZ = 0.0
		
		#Aligning velocities variables
		var avgVelX = 0.0
		var avgVelZ = 0.0
		var neighbours = 0.0
		
		#Centering variables
		var avgPosX = 0.0
		var avgPosZ = 0.0
		
		var changedVelocity = Vector3(0.0,0.0,0.0)
		
		for c in boids:
			if b.global_position.distance_to(c.global_position) > visibleRange:
				continue
			elif b != c:
				#Used to separate boids when they get too close
				if b.global_position.distance_to(c.global_position) < separationRange: 
					closeX += b.global_position.x - c.global_position.x
					closeZ += b.global_position.z - c.global_position.z
				
				#Used to keep boids going same direction
				if b.global_position.distance_to(c.global_position) < visibleRange: 
					avgVelX += c.linear_velocity.x
					avgVelZ += c.linear_velocity.z
					avgPosX += c.global_position.x
					avgPosZ += c.global_position.z
					neighbours += 1.0
				
		changedVelocity += Vector3(closeX * avoidFactor, 0.0, closeZ * avoidFactor)
		
		if neighbours > 0.0:
			avgVelX = avgVelX/neighbours
			avgVelZ = avgVelZ/neighbours
			changedVelocity += Vector3((avgVelX - b.linear_velocity.x) * matchingFactor, 0.0, (avgVelZ - b.linear_velocity.z) * matchingFactor)
			
			avgPosX = avgPosX/neighbours
			avgPosZ = avgPosZ/neighbours
			changedVelocity += Vector3((avgPosZ - b.global_position.z) * centeringFactor, 0.0, (avgPosX- b.global_position.x) * centeringFactor)
		
		b.linear_velocity += changedVelocity
		
		var speed = sqrt((b.linear_velocity.x * b.linear_velocity.x) + (b.linear_velocity.z * b.linear_velocity.z))
		if speed > maxVelocity:
			b.linear_velocity.x = (b.linear_velocity.x/speed) * maxVelocity
			b.linear_velocity.z = (b.linear_velocity.z/speed) * minVelocity
		elif speed < minVelocity:
			b.linear_velocity.x = (b.linear_velocity.x/speed) * minVelocity
			b.linear_velocity.z = (b.linear_velocity.z/speed) * minVelocity
		
	
func _physics_process(_delta: float) -> void:
	for b in boids:
		if b.global_position.x < -50.0: b.linear_velocity.x += turningFactor 
		elif b.global_position.x > 50.0: b.linear_velocity.x -= turningFactor 
		elif b.global_position.z < -100.0: b.linear_velocity.z += turningFactor 
		elif b.global_position.z > 100.0: b.linear_velocity.z -= turningFactor 
		
		boidCalcs(b)
		
