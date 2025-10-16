class_name DragController
extends Node3D
"""
DragController
======================

This module defines the DragController class, which enables click-and-drag functionality
for CardCollection3D nodes.

Usage:
	- add drag controller instance to scene
	- add some CardCollection3D instances to scene as children of the drag controller
	- define drag behavior on collections by overridding drag methods
		(can_select_card, can_insert_card, can_reorder_card, can_remove_card)
"""


signal drag_started(card)
signal drag_stopped(card)
signal card_moved(card, from_collection, to_collection, from_index, to_index)


@export var max_drag_y_rotation_deg: int = 65
@export var max_drag_x_rotation_deg: int = 65

@export var card_drag_plane = Plane(Vector3(0, 0, 1), 1.5): # plane card is moved across on drag
	set(plane):
		card_drag_plane = plane

## The minimum distance the mouse needs to travel in viewport coordinates to consider the input a drag.
@export_range(0,100.0,1,"suffix:px")  var card_drag_threshold: float = 0.0:
	set(value):
		_card_drag_threshold_squared = value*value
		card_drag_threshold = value

var _camera: Camera3D # camera used for determining where mouse is on drag plane
var _dragging_card: Card3D # card that is being dragged
var _drag_from_collection: CardCollection3D # collection card being dragged from
var _dragging: bool = false
var _card_drag_threshold_squared: float = card_drag_threshold*card_drag_threshold
var _selection_start_mouse_position: Vector2
var _current_mouse_position: Vector2
var _hovered_collection: CardCollection3D # collection about to drop card into
var _hovered_collection_plane: Plane
var _hovered_collection_layout_direction: Vector3
var _card_collections: Array[CardCollection3D] = []

func _ready():
	var window = get_window()
	_camera = window.get_camera_3d()
	
	for child in get_children():
		if child is CardCollection3D:
			add_card_collection(child)

func add_card_collection(card_collection: CardCollection3D) -> void:
	_card_collections.append(card_collection)
	card_collection.card_selected.connect(_on_collection_card_selected.bind(card_collection))
	card_collection.mouse_enter_drop_zone.connect(_on_collection_mouse_enter_drop_zone.bind(card_collection))
	card_collection.mouse_exit_drop_zone.connect(_on_collection_mouse_exit_drop_zone.bind(card_collection))

func remove_card_collection(card_collection: CardCollection3D) -> void:
	if _card_collections.has(card_collection):
		_card_collections.erase(card_collection)
		card_collection.card_selected.disconnect(_on_collection_card_selected.bind(card_collection))
		card_collection.mouse_enter_drop_zone.disconnect(_on_collection_mouse_enter_drop_zone.bind(card_collection))
		card_collection.mouse_exit_drop_zone.disconnect(_on_collection_mouse_exit_drop_zone.bind(card_collection))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released() and event.button_index == 1:
			_on_collection_card_deselected()
	if event is InputEventMouseMotion:
		_current_mouse_position = get_viewport().get_mouse_position()
		if _dragging:
			_handle_drag_event()
		elif _dragging_card:
			if _selection_start_mouse_position.distance_squared_to(_current_mouse_position) > _card_drag_threshold_squared:
				_drag_card_start()


func _on_collection_card_selected(card: Card3D, collection: CardCollection3D):
	_selection_start_mouse_position = get_viewport().get_mouse_position()
	_drag_from_collection = collection
	_dragging_card = card

	for card_collection in _card_collections:
		card_collection.hover_disabled = true
	
func _on_collection_card_deselected():
	if _dragging:
		_stop_drag()
	else:
		_dragging_card = null
		_drag_from_collection = null
		for card_collection in _card_collections:
			card_collection.hover_disabled = false

func _on_collection_mouse_enter_drop_zone(collection: CardCollection3D):
	_set_hovered_collection(collection)


func _on_collection_mouse_exit_drop_zone(_collection: CardCollection3D):
	if _hovered_collection != _drag_from_collection:
		_hovered_collection.apply_card_layout()
	else:
		_hovered_collection.preview_card_remove(_dragging_card)

	_hovered_collection = null



## Sets the currently hovered card collection and updates its layout direction and interaction plane.
func _set_hovered_collection(collection: CardCollection3D):
	_hovered_collection = collection
	var layout_normal_local = collection.card_layout_strategy.get_layout_normal()
	_hovered_collection_layout_direction = (collection.global_transform.basis * layout_normal_local).normalized()
	_hovered_collection_plane = Plane(collection.global_transform.basis.z, collection.global_position)


func _return_card_to_collection(mouse_position: Vector2):
	_drag_from_collection.is_dragging_card = true
	if _drag_from_collection.can_reorder_card(_dragging_card):
		_set_hovered_collection(_drag_from_collection)
		var current_index = _drag_from_collection.card_indicies[_dragging_card]
		var new_index = _get_hovered_collection_index_at_mouse_pos(mouse_position)
		new_index = clamp(new_index, 0, _drag_from_collection.cards.size() - 1)

		if current_index != new_index:
			_drag_from_collection.move_card(_dragging_card,new_index)
			card_moved.emit(_dragging_card, _drag_from_collection, _drag_from_collection, current_index, new_index)

	_drag_from_collection.apply_card_layout()


func _drop_card_to_another_collection(mouse_position: Vector2):
	if not _hovered_collection.can_insert_card(_dragging_card, _drag_from_collection):
		return

	var card_index = _drag_from_collection.card_indicies[_dragging_card]
	var card_global_position = _drag_from_collection.cards[card_index].global_position
	var c = _drag_from_collection.remove_card(card_index)

	_hovered_collection.is_dragging_card = true
	if _hovered_collection.can_reorder_card(c):
		var index = _get_hovered_collection_index_at_mouse_pos(mouse_position)
		_hovered_collection.insert_card(c, index)
		card_moved.emit(_dragging_card, _drag_from_collection, _hovered_collection, card_index, index)
	else:
		_hovered_collection.append_card(c)
		card_moved.emit(
			_dragging_card,
			_drag_from_collection,
			_hovered_collection,
			card_index,
			_hovered_collection.cards.size() - 1
		)
	
	c.remove_hovered()
	c.global_position = card_global_position


func _drag_card_start():
	_dragging = true
	_dragging_card.disable_collision()
	_dragging_card.remove_hovered()
	_drag_from_collection.enable_drop_zone()

	for collection in _card_collections:
		if collection.can_insert_card(_dragging_card, _drag_from_collection):
			collection.enable_drop_zone()

		collection.hover_disabled = true

	drag_started.emit(_dragging_card)


func _stop_drag():
	var can_insert: bool = true

	if _hovered_collection != null:
		can_insert = _hovered_collection.can_insert_card(_dragging_card, _drag_from_collection) and _drag_from_collection.can_remove_card(_dragging_card)

	if not can_insert:
		_return_card_to_collection(_current_mouse_position)
	elif _hovered_collection == null or _hovered_collection == _drag_from_collection:
		_return_card_to_collection(_current_mouse_position)
	elif _hovered_collection != null and _hovered_collection != _drag_from_collection:
		_drop_card_to_another_collection(_current_mouse_position)

	_drag_from_collection.disable_drop_zone()
	_dragging_card.enable_collision()

	var card = _dragging_card
	var from_collection = _drag_from_collection
	var to_collection = _hovered_collection

	_dragging = false
	_dragging_card = null
	_drag_from_collection = null

	for collection in _card_collections:
		collection.disable_drop_zone()
		collection.hover_disabled = false

	drag_stopped.emit(card)

func _handle_drag_event():
	var position_3d = card_drag_plane.intersects_ray(_camera.project_ray_origin(_current_mouse_position), _camera.project_ray_normal(_current_mouse_position))
	var card_position = _dragging_card.global_position

	var x_distance = position_3d.x - card_position.x
	var y_distance = position_3d.y - card_position.y

	# add rotation to make dragging cards pretty
	# rotate around y axis for horizontal rotation
	var y_degrees: float = x_distance * 25
	y_degrees = clamp(y_degrees, -max_drag_y_rotation_deg, max_drag_y_rotation_deg)

	# rotate around x axis for vertial rotation
	var x_degrees: float = -y_distance * 25
	x_degrees = clamp(x_degrees, -max_drag_x_rotation_deg, max_drag_x_rotation_deg)
	var z_degrees: float = 0

	# put degrees in Vector3
	var target_rotation = Vector3(
		deg_to_rad(x_degrees),
		deg_to_rad(y_degrees),
		deg_to_rad(z_degrees)
	)

	# set rotation
	_dragging_card.dragging_rotation(target_rotation)

	# set card position to under mouse
	_dragging_card.global_position.x = position_3d.x
	_dragging_card.global_position.y = position_3d.y
	_dragging_card.global_position.z = position_3d.z

	if _hovered_collection != null and position_3d != null and _hovered_collection.can_reorder_card(_dragging_card):
		var index = _get_hovered_collection_index_at_mouse_pos(_current_mouse_position)
		_hovered_collection.preview_card_drop(_dragging_card, index)



## Returns the index in the hovered collection where a card would be inserted based on the mouse position.
func _get_hovered_collection_index_at_mouse_pos(mouse_pos: Vector2):
	var collection_plane_intersection: Vector3 = _hovered_collection_plane.intersects_ray(_camera.project_ray_origin(mouse_pos),_camera.project_ray_normal(mouse_pos))

	if collection_plane_intersection == null:
		return _hovered_collection.cards.size()

	var offset = collection_plane_intersection - _hovered_collection.global_position
	var distance_along_layout = offset.dot(_hovered_collection_layout_direction)
	return _hovered_collection.get_closest_card_index_along_vector(_hovered_collection_layout_direction, distance_along_layout)


func _get_drag_screen_point(world_position: Vector3):
	if world_position != null:
		return _camera.unproject_position(world_position)
	else:
		return null
