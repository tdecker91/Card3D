"""
CardCollection3D
==========================

This module handles manages a collection of Card3D nodes.

Usage:
	- add card collection 3D instance to scene
	- update card layout behavior if desired (line, fan, pile)
	- update collision shape if desired
	- add Card3D nodes by calling the add or insert method
	- extend CardCollection3D in your own script and override drag behavior methods to alter 
		behaviour with your own game logic (can_select_card, can_insert_card, can_reorder_card, can_remove_card)
"""
class_name CardCollection3D
extends Node3D


signal mouse_enter_drop_zone()
signal mouse_exit_drop_zone()
signal card_selected(card)
signal card_clicked(card)
signal card_added(card)


@onready var dropzone_collision: CollisionShape3D = $DropZone/CollisionShape3D

@export var highlight_on_hover: bool = true
@export var card_move_tween_duration: float = .25
@export var card_swap_tween_duration: float = .25
@export var card_layout_strategy: CardLayout = LineCardLayout.new():
	set(strategy):
		card_layout_strategy = strategy
		apply_card_layout()
@export var dropzone_collision_shape: Shape3D = _default_collision_shape(): 
	set(v):
		if v != null:
			$DropZone/CollisionShape3D.shape = v
@export var dropzone_z_offset: float = 1.6:
	set(offset):
		$DropZone.position.z = offset


var cards: Array[Card3D] = []
var card_indicies = {}

var hover_disabled: bool = false # disable card hover animation (useful when dragging other cards around)
var _hovered_card: Card3D # card currently hovered
var _preview_drop_index: int = -1


# add a card to the hand and animate it to the correct position
# this will add card as child of this node
func append_card(card: Card3D):
	insert_card(card, cards.size())


func prepend_card(card: Card3D):
	insert_card(card, 0)


func insert_card(card: Card3D, index: int):
	card.card_3d_mouse_down.connect(_on_card_pressed.bind(card))
	card.card_3d_mouse_up.connect(_on_card_clicked.bind(card))
	card.card_3d_mouse_over.connect(_on_card_hover.bind(card))
	card.card_3d_mouse_exit.connect(_on_card_exit.bind(card))
		
	cards.insert(index, card)
	add_child(card)
	
	for i in range(index, cards.size()):
		card_indicies[cards[i]] = i
	
	apply_card_layout()
	card_added.emit(card)


# remove and return card from the end of the list
func pop_card() -> Card3D:
	return remove_card(cards.size() - 1)
	

# remove and return card from the beggining of the list
func shift_card() -> Card3D:
	return remove_card(0)


# remove card from this hand and return it.
# the caller is responsible for adding card elsewhere
# and/or calling queue_free on it
func remove_card(index: int) -> Card3D:
	var removed_card = cards[index]
	cards.remove_at(index)
	card_indicies.erase(removed_card)
	
	for i in range(index, cards.size()):
		card_indicies[cards[i]] = i
	
	remove_child(removed_card)
	apply_card_layout()
	
	removed_card.card_3d_mouse_down.disconnect(_on_card_pressed.bind(removed_card))
	removed_card.card_3d_mouse_up.disconnect(_on_card_clicked.bind(removed_card))
	removed_card.card_3d_mouse_over.disconnect(_on_card_hover.bind(removed_card))
	removed_card.card_3d_mouse_exit.disconnect(_on_card_exit.bind(removed_card))

	return removed_card


# remove and return all cards
func remove_all() -> Array[Card3D]:
	var cards_to_return = cards
	cards = []
	card_indicies = {}
	
	for c in cards_to_return:
		remove_child(c)
	
	return cards_to_return


func apply_card_layout():
	card_layout_strategy.update_card_positions(cards, card_move_tween_duration)


func preview_card_remove(dragging_card: Card3D):
	if card_indicies.has(dragging_card):
		var preview_cards: Array[Card3D] = []
		var card_index = card_indicies[dragging_card]
		preview_cards += cards.slice(0, card_index)
		preview_cards += cards.slice(card_index + 1, cards.size())
		
		card_layout_strategy.update_card_positions(preview_cards, card_swap_tween_duration)


func preview_card_drop(dragging_card: Card3D, index: int):
	if index == _preview_drop_index:
		return
	
	_preview_drop_index = index
	var preview_cards: Array[Card3D] = []
	
	if card_indicies.has(dragging_card):
		# dragging card in the current collection
		index = clamp(index, 0, cards.size() - 1)
		var current_index = card_indicies[dragging_card]
		preview_cards += cards.slice(0, current_index)
		preview_cards += cards.slice(current_index + 1, cards.size())
		preview_cards.insert(index, null)
	else:
		# dragging new card in from another collection
		preview_cards += cards.slice(0, index)
		preview_cards.append(null)
		preview_cards += cards.slice(index, cards.size())
	
	card_layout_strategy.update_card_positions(preview_cards, card_swap_tween_duration)


func enable_drop_zone():
	_preview_drop_index = -1
	dropzone_collision.disabled = false


func disable_drop_zone():
	_preview_drop_index = -1
	dropzone_collision.disabled = true


func on_drag_hover(dragging_card: Card3D, mouse_position: Vector2):
	var index_to_drop = get_card_index_at_point(mouse_position)
	preview_card_drop(dragging_card, max(index_to_drop, 0))


func get_card_index_at_point(mouse_position: Vector2):
	var camera = get_window().get_camera_3d()
	var index = cards.size()
	# iterate cards until finding screen position after mouse position
	#   this is the index where we will add card
	for card in cards:
		var card_index = card_indicies[card]
		var card_position = card_layout_strategy.calculate_card_position_by_index(cards.size(), card_index)
		var card_screen_position = camera.unproject_position(card_position)
		if mouse_position.x < card_screen_position.x:
			index = card_indicies[card]
			break
	
	return index


# when a mouse enters card collision
# set hover state, if applicable
func _on_card_hover(card: Card3D):
	if not hover_disabled and can_select_card(card):
		_hovered_card = card
		
		if highlight_on_hover:
			card.set_hovered()


func _on_card_exit(card: Card3D):
	if not hover_disabled and _hovered_card == card:
		card.remove_hovered()
		_hovered_card = null


func _on_card_pressed(card: Card3D):
	if can_select_card(card):
		card_selected.emit(card)
		

func _on_card_clicked(card: Card3D):
	card_clicked.emit(card)


func _on_drop_zone_mouse_entered():
	mouse_enter_drop_zone.emit()


func _on_drop_zone_mouse_exited():
	_preview_drop_index = -1
	mouse_exit_drop_zone.emit()
	

func _default_collision_shape() -> Shape3D:
	var shape = ConvexPolygonShape3D.new()
	shape.points = PackedVector3Array(
		[
			Vector3(-7,2,0),
			Vector3(-7,-2,0),
			Vector3(7,-2,0),
			Vector3(7,2,0)
		]
	)
	return shape


# whether or not a card can be selected
func can_select_card(_card) -> bool:
	return true


func can_remove_card(_card) -> bool:
	return true


func can_reorder_card(_card) -> bool:
	return true


# if the card can be inserted to the collection
func can_insert_card(_card, _from_collection) -> bool:
	return true
