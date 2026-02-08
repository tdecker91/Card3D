class_name BattleCard3D
extends Card3D

@export var id: String = ""

@export var front_material_path: String = "":
	set(value):
		front_material_path = value
		if is_inside_tree():
			_apply_front()

@export var damage: int = 0:
	set(value):
		damage = value
		if is_inside_tree():
			_apply_overlay()

@export var health: int = 0:
	set(value):
		health = value
		if is_inside_tree():
			_apply_overlay()

@onready var front_viewport: SubViewport = $FrontTextureViewport
@onready var front_root: Control = $FrontTextureViewport/FrontTextureRoot
@onready var front_background: TextureRect = $FrontTextureViewport/FrontTextureRoot/FrontTextureBackground
@onready var front_label: Label = $FrontTextureViewport/FrontTextureRoot/FrontTextureLabel
var _front_material_override := StandardMaterial3D.new()


func _ready() -> void:
	front_viewport.disable_3d = true
	front_viewport.transparent_bg = true
	front_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	front_background.stretch_mode = TextureRect.STRETCH_SCALE
	_front_material_override.albedo_texture = front_viewport.get_texture()
	$CardMesh/CardFrontMesh.set_surface_override_material(0, _front_material_override)
	_apply_front()
	_apply_overlay()


func _apply_front() -> void:
	if front_material_path == "":
		return
	var material = load(front_material_path)
	if material == null:
		return
	if material is StandardMaterial3D and material.albedo_texture != null:
		var texture = material.albedo_texture
		var size: Vector2i = texture.get_size()
		front_background.texture = texture
		front_viewport.size = Vector2i(int(size.x), int(size.y))
		front_root.size = size
		front_root.custom_minimum_size = size
		front_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		return
	$CardMesh/CardFrontMesh.set_surface_override_material(0, material)


func _apply_overlay() -> void:
	if health > 0:
		front_label.text = str(health)
		front_label.modulate = Color(1, 0, 0)
		front_label.add_theme_font_size_override("font_size", 100)
	elif damage > 0:
		front_label.text = "Deal %d\ndamage" % damage
		front_label.modulate = Color(0, 0, 0)
		front_label.add_theme_font_size_override("font_size", 60)
	else:
		front_label.text = ""
	front_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func _to_string():
	return id
