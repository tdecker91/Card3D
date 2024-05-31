class_name FaceCard3D
extends Card3D


@export var rank: FaceCards.Rank = FaceCards.Rank.TWO
@export var suit: FaceCards.Suit = FaceCards.Suit.DIAMOND
@export var front_material_path: String:
	set(path):
		if path:
			var material = load(path)
			
			if material:
				$CardMesh/CardFrontMesh.set_surface_override_material(0, material)
		
@export var back_material_path: String:
	set(path):
		if path:
			var material = load(path)
			
			if material:
				$CardMesh/CardBackMesh.set_surface_override_material(0, material)
