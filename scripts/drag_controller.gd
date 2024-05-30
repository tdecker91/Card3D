# drag_controller.gd
# class for enabling click and drag of Card3D nodes
class_name DragController
extends Node3D


signal drag_started(card)
signal drag_stopped()


@export var card_collections: Array[CardCollection3D] = []
@export var max_drag_y_rotation_deg: int = 65
@export var max_drag_x_rotation_deg: int = 65


var card_drag_plane = Plane(Vector3(0, 0, 1), 1.5): # plane card is moved across on drag
	set(plane):
		card_drag_plane = plane

var _camera: Camera3D # camera used for determining where mouse is on drag plane
var _dragging_card: Card3D # card that is being dragged
var _drag_from_collection: CardCollection3D # collection card being dragged from
var _dragging: bool = false
var _hovered_collection: CardCollection3D # collection about to drop card into
var _drag_left_position = null
var _drag_right_position = null


func _ready():
	var window = get_window()
	_camera = window.get_camera_3d()
	
	for collection in card_collections:
		collection.card_selected.connect(_on_collection_card_selected.bind(collection))
		collection.mouse_enter_drop_zone.connect(_on_collection_mouse_enter_drop_zone.bind(collection))
		collection.mouse_exit_drop_zone.connect(_on_collection_mouse_exit_drop_zone.bind(collection))


func _input(event):
	if event is InputEventMouseButton:
		if _dragging and event.button_index == 1 and !event.pressed:
			_stop_drag()
	elif event is InputEventMouseMotion:
		if _dragging:
			_handle_drag_event(event)


func _on_collection_card_selected(card: Card3D, collection: CardCollection3D):
	_drag_card_start(card, collection)


func _on_collection_mouse_enter_drop_zone(collection: CardCollection3D):
	_hovered_collection = collection
	if _dragging_card != null:
		pass
		#_set_drag_boundaries(_dragging_card)


func _on_collection_mouse_exit_drop_zone(_collection: CardCollection3D):
	_hovered_collection = null


func _stop_drag():
	if _hovered_collection == null or _hovered_collection == _drag_from_collection:
		return_card_to_collection()
	elif _hovered_collection != null and _hovered_collection != _drag_from_collection:
		drop_card_to_another_collection()
		
	#_drag_from_collection.execute_card_strategy()
	_dragging = false
	_dragging_card = null
	_drag_from_collection = null
	
	for collection in card_collections:
		if collection.droppable:
			collection.disable_drop_zone()
			
		if collection.draggable:
			collection.selection_disabled = false
	
	#var card_index = card_indicies[selected_card]
	#var hand_position = card_layout_strategy.calculate_card_position_by_index(cards.size(), card_index)
	#card_layout_strategy.update_card_position(selected_card, cards.size(), card_index, card_swap_tween_duration)
	#selected_card = null
	#drag_left_position = null
	#drag_right_position = null
	drag_stopped.emit()


func return_card_to_collection():
	_drag_from_collection.execute_card_strategy()


func drop_card_to_another_collection():
	var card_index = _drag_from_collection.card_indicies[_dragging_card]
	var global_position = _drag_from_collection.cards[card_index].global_position
	var c = _drag_from_collection.remove_card(card_index)
	
	_hovered_collection.add_card(c)
	c.remove_hovered()
	c.global_position = global_position


func _drag_card_start(card: Card3D, drag_from_collection: CardCollection3D):
	_dragging = true
	_drag_from_collection = drag_from_collection
	_dragging_card = card
	
	for collection in card_collections:
		if collection.droppable:
			collection.enable_drop_zone()
			
		if collection.draggable:
			collection.selection_disabled = true
	
	drag_started.emit(card)


func _set_drag_boundaries(card):
	var cards = _hovered_collection.cards
	var card_layout = _hovered_collection.card_layout_strategy
	if cards.size() == 1:
		return
		
	var index = _hovered_collection.card_indicies[card]
	
	if index > 0:
		_drag_left_position = card_layout.calculate_card_position_by_index(cards.size(), index - 1)
	else:
		_drag_left_position = null
		
	if index < cards.size() - 1:
		_drag_right_position = card_layout.calculate_card_position_by_index(cards.size(), index + 1)
	else:
		_drag_right_position = null


func _handle_drag_event(event: InputEventMouseMotion):
	var m: Vector2 = get_viewport().get_mouse_position()
	var position3D = card_drag_plane.intersects_ray(_camera.project_ray_origin(m),_camera.project_ray_normal(m))
	var card_position = _dragging_card.global_position
	
	var x_distance = position3D.x - card_position.x
	var y_distance = position3D.y - card_position.y
	
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
	_dragging_card.global_position.x = position3D.x
	_dragging_card.global_position.y = position3D.y
	_dragging_card.global_position.z = position3D.z
	
	if _hovered_collection != null:
		pass
		#_handle_card_reorder(position3D)


func _handle_card_reorder(drag_position: Vector3):
	var drag_screen_point = _get_drag_screen_point(drag_position)
	var swapped = true
	
	while swapped:
		var left_screen_point = _get_drag_screen_point(_drag_left_position)
		var right_screen_point = _get_drag_screen_point(_drag_right_position)
		
		if left_screen_point != null and drag_screen_point.x < left_screen_point.x:
			_handle_swap_left()
		elif _drag_right_position != null and drag_screen_point.x > right_screen_point.x:
			_handle_swap_right()
		else:
			swapped = false


func _get_drag_screen_point(position):
	if position != null:
		return _camera.unproject_position(position)
	else:
		return null


func _handle_swap_left():
	var index = _hovered_collection.card_indicies[_dragging_card]
	var left_index = index - 1
	var left_card = _hovered_collection.cards[left_index]
	
	_hovered_collection.cards[left_index] = _dragging_card
	_hovered_collection.cards[index] = left_card
	_hovered_collection.card_indicies[left_card] = index
	_hovered_collection.card_indicies[_dragging_card] = left_index

	_set_drag_boundaries(_dragging_card)
	_hovered_collection.card_layout_strategy.update_card_position(left_card, _hovered_collection.cards.size(), index, .12)


func _handle_swap_right():
	var index = _hovered_collection.card_indicies[_dragging_card]
	var right_index = index + 1
	var right_card = _hovered_collection.cards[right_index]
	
	_hovered_collection.cards[right_index] = _dragging_card
	_hovered_collection.cards[index] = right_card
	_hovered_collection.card_indicies[right_card] = index
	_hovered_collection.card_indicies[_dragging_card] = right_index
	
	_set_drag_boundaries(_dragging_card)
	_hovered_collection.card_layout_strategy.update_card_position(right_card, _hovered_collection.cards.size(), index, .12)
