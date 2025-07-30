@tool
extends Node

const _DEFAULT_DROP_ZONE_SHAPE_3D = preload(
	"res://addons/card_3d/shapes_3d/default_card_collection_3d_drop_zone_shape_3d.tres"
)

@export var _card_collection_3d: CardCollection3D
@export var _drop_zone_collision_shape_3d: CollisionShape3D
var _current_shape_3d: Shape3D
var _current_z_offset: float

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(true)
		_update_shape_3d()
		_update_z_offset()
	else:
		set_process(false)

func _process(_delta: float) -> void:
	if !_card_collection_3d or !_drop_zone_collision_shape_3d:
		return
	if _current_shape_3d != _card_collection_3d.dropzone_collision_shape:
		_update_shape_3d()
	if _current_z_offset != _card_collection_3d.dropzone_z_offset:
		_update_z_offset()

func _update_shape_3d() -> void:
	if _card_collection_3d.dropzone_collision_shape:
		_current_shape_3d = _card_collection_3d.dropzone_collision_shape
	else:
		_current_shape_3d = _DEFAULT_DROP_ZONE_SHAPE_3D
	_drop_zone_collision_shape_3d.shape = _current_shape_3d

func _update_z_offset() -> void:
	_current_z_offset = _card_collection_3d.dropzone_z_offset
	_drop_zone_collision_shape_3d.position.z = _current_z_offset
