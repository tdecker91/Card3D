# card_pile_3d.gd
# class for managing cards played on the table
class_name CardPile3D
extends CardCollection3D


func _ready():
	self.card_layout_strategy = PileCardLayout.new()
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
