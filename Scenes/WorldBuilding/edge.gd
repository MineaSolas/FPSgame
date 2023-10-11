@tool
extends MeshInstance3D

func update_scale():
	var scale = sum_scaleables(get_parent(), Vector3(1,1,1))
	var basic_vector = position
	
	if position.x != 0: basic_vector.x /= abs(position.x)
	else: self.scale = Vector3(1/scale.z, 1/scale.y, 1)
	
	if position.y != 0: basic_vector.y /= abs(position.y)
	else: self.scale = Vector3(1/scale.x, 1/scale.z, 1)
	
	if position.z != 0: basic_vector.z /= abs(position.z)
	else: self.scale = Vector3(1/scale.x, 1/scale.y, 1)
	
	self.position = basic_vector*0.5 - basic_vector*0.0499 / scale
	self.mesh = self.mesh.duplicate()
	self.mesh.size = Vector3(0.1, 0.1, 1.0 + 0.0001/scale.z)

func sum_scaleables(parent, scaletmp):
	if(parent.has_method("get_scale")):
		scaletmp *= parent.get_scale()
	if parent.get_parent() == null || parent.get_parent() is SubViewport:
		return scaletmp
	return sum_scaleables(parent.get_parent(), scaletmp)
