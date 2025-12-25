class CustomMesh:
	var mesh: Mesh
	var pos: Vector3 = Vector3.ZERO
	var rot: Vector3 = Vector3.ZERO

	func create_from(_mesh: Mesh, _pos: Vector3 = Vector3.ZERO, _rot: Vector3 = Vector3.ZERO):
		self.mesh = _mesh
		self.pos = _pos
		self.rot = _rot
		return self


static func merge_multiple_meshes(meshes_to_merge: Array, InstanceRotation : Vector3) -> ArrayMesh:
	var array_mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for mesh_instance in meshes_to_merge:
		if mesh_instance is CustomMesh and mesh_instance.mesh:
			var bas = Basis(Quaternion.from_euler(
				mesh_instance.rot + Vector3(
					deg_to_rad(InstanceRotation.x),
					deg_to_rad(InstanceRotation.y),
					deg_to_rad(InstanceRotation.z)
				)
			))
			var transform: Transform3D = Transform3D(bas, mesh_instance.pos)
			for i in range(mesh_instance.mesh.get_surface_count()):
				surface_tool.append_from(mesh_instance.mesh, i, transform)

	surface_tool.commit(array_mesh)
	return array_mesh


static func create_inst(SourceMesh : Mesh,
					Points_Callable : Callable,
					InstanceRotation := Vector3.ZERO,
					InstanceRotationAxis := Vector3.UP,
					atan_rot : bool = true,
					material := StandardMaterial3D.new(),
					...args) -> MeshInstance3D:
	if not SourceMesh:
		push_error("SourceMesh is not assigned!")
		return null

	var points = Points_Callable.callv(args)
	var meshes: Array[CustomMesh] = []

	for point in points:
		var rotation_angle = atan2(-point.z, point.x)
		var rot = InstanceRotationAxis * rotation_angle if atan_rot else InstanceRotationAxis
		var mesh = CustomMesh.new().create_from(SourceMesh, point, rot)
		meshes.append(mesh)

	var mesh_inst = MeshInstance3D.new()
	mesh_inst.mesh = merge_multiple_meshes(meshes, InstanceRotation)
	if material:
		mesh_inst.material_override = material
	return mesh_inst






static func clear_children(node : Node):
	for i in node.get_children():
		if i is MeshInstance3D:
			i.queue_free()
