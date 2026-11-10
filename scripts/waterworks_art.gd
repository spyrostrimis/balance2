extends RefCounted
## Original waterworks accepted for interim use; no collision or footprint changes.
const Art = preload("res://scripts/shapes.gd")

static func structures(parent: Node3D) -> void:
	var cistern := preload("res://assets/waterworks_study/cistern.glb").instantiate()
	cistern.name = "WaterworksCandidateCistern"
	cistern.position = Vector3(-17, 0, -10)
	parent.add_child(cistern)
	var water := ShaderMaterial.new()
	water.shader = preload("res://shaders/basin_water.gdshader")
	Art.cylinder(cistern, Vector3(0, .185, 0), 1.58, 1.58, .02, water, 64)
	for side in [-1, 1]:
		var aqueduct: Node3D = load("res://assets/waterworks_study/aqueduct_%02d.glb" % (0 if side < 0 else 1)).instantiate()
		aqueduct.name = "WaterworksCandidateAqueduct"
		aqueduct.position = Vector3(side * 9.5, 0, -12)
		if side < 0: aqueduct.rotation.y = PI
		parent.add_child(aqueduct)

static func conduits(parent: Node3D) -> void:
	for i in range(5):
		var path := "res://assets/waterworks_study/conduit_broken.glb" if i in [2, 4] else "res://assets/waterworks_study/conduit.glb"
		var pipe: Node3D = load(path).instantiate()
		pipe.name = "WaterworksCandidateConduit"
		pipe.position = Vector3(-20.7, 0, 7.5 + i * 1.25)
		pipe.rotation.y = -PI / 2
		parent.add_child(pipe)
