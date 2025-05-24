extends MeshInstance3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var m = self.mesh
	
	var st = SurfaceTool.new()
	st.create_from(m,0)
	var arr = st.commit()
	
	var tool = MeshDataTool.new()
	if arr.get_surface_count() > 0:
		tool.create_from_surface(arr, 0)

#		for i in range(tool.get_vertex_count()):
#			var vertex = tool.get_vertex(i)
#			#print("Vertex ", i, ": ", vertex)

		tool.clear()
	else:
		print("Mesh has no surfaces.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
