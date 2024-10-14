class_name BattleCard3D
extends Card3D

@export var id: String = ""
@export var front_material_path: String:
	set(path):
		if path:
			var material = load(path)
		
			if material:
				$CardMesh/CardFrontMesh.set_surface_override_material(0, material)
		
@export var damage: int = 0:
	set(d):
		damage = d
		if damage > 0 and has_node("CardMesh/CardText"):
			$CardMesh/CardText.text = "Deal " + str(damage) + " damage"
		
@export var health: int = 0:
	set(h):
		health = h
		if has_node("CardMesh/CardText"):
			$CardMesh/CardText.font_size = 100
			$CardMesh/CardText.modulate = Color(1,0,0)
			$CardMesh/CardText.text = str(health)


func _to_string():
	return id
