# drag_controller.gd
# class for enabling click and drag of Card3D nodes
class_name DragController
extends Node3D


signal drag_started(card)
signal drag_stopped()


# plane card is moved across on drag
var card_drag_plane = Plane(Vector3(0, 0, 1), 1.5):
	set(plane):
		card_drag_plane = plane

# camera used for determining where mouse is on drag plane
var _camera: Camera3D

# card that is being dragged
var _dragging_card: Card3D

var _dragging: bool = false


func _ready():
	var window = get_window()
	_camera = window.get_camera_3d()


func _input(event):
	if event is InputEventMouseButton:
		if _dragging and event.button_index == 1 and !event.pressed:
			_stop_drag()
	elif event is InputEventMouseMotion:
		if _dragging:
			pass
			#_handle_drag_event(event)


func _stop_drag():
	_dragging = false
	#var card_index = card_indicies[selected_card]
	#var hand_position = card_layout_strategy.calculate_card_position_by_index(cards.size(), card_index)
	#card_layout_strategy.update_card_position(selected_card, cards.size(), card_index, card_swap_tween_duration)
	#selected_card = null
	#drag_left_position = null
	#drag_right_position = null
	drag_stopped.emit()


func drag_card_start(card: Card3D):
	_dragging = true
	_dragging_card = card
	drag_started.emit(card)
