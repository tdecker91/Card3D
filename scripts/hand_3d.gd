# hand_3d.gd
# class for the players hand of cards
class_name Hand3D
extends CardCollection3D


func _ready():
	$DropZone.position.z = 1.6
	var dropzone_shape = ConvexPolygonShape3D.new()
	dropzone_shape.points = PackedVector3Array(
		[
			Vector3(-7,2,0),
			Vector3(-7,-2,0),
			Vector3(7,-2,0),
			Vector3(7,2,0)
		]
	)
	$DropZone/CollisionShape3D.shape = dropzone_shape;
