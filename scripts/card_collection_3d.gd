# card_collection.gd
#
# class for managing a collection of cards
#   - adding cards
#   - removing cards
#   - positioning card nodes
#   - adding animations
class_name CardCollection3D
extends Node3D


signal mouse_enter_drop_zone()
signal mouse_exit_drop_zone()
signal card_selected(card)


@export var reorderable: bool = false
@export var insertable: bool = false
@export var removable: bool = false
@export var card_move_tween_duration: float = 0.2
@export var card_swap_tween_duration: float = 0.12
@export var card_layout_strategy: CardLayout = LineCardLayout.new():
	set(strategy):
		card_layout_strategy = strategy
		execute_card_strategy()


@onready var dropzone_collision: CollisionShape3D = $DropZone/CollisionShape3D


var draggable: bool:
	get:
		return reorderable or removable

var cards: Array[Card3D] = []
var card_indicies = {}
var selection_disabled: bool = false

var _hovered_card: Card3D # card currently hovered

# add a card to the hand and animate it to the correct position
# this will add card as child of this node
func add_card(card: Card3D):
	if draggable:
		card.card_pressed.connect(_on_card_pressed.bind(card))
		card.mouse_over_card.connect(_on_card_hover.bind(card))
		card.mouse_exit_card.connect(_on_card_exit.bind(card))
		
	cards.append(card)
	card_indicies[card] = cards.size() - 1
	add_child(card)
	execute_card_strategy()


func insert_card(card: Card3D, index: int):
	if draggable:
		card.card_pressed.connect(_on_card_pressed.bind(card))
		card.mouse_over_card.connect(_on_card_hover.bind(card))
		card.mouse_exit_card.connect(_on_card_exit.bind(card))
		
	cards.insert(index, card)
	add_child(card)
	
	for i in range(index, cards.size()):
		card_indicies[cards[i]] = i
		
	execute_card_strategy()


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
	execute_card_strategy()
	
	if draggable:
		removed_card.card_pressed.disconnect(_on_card_pressed.bind(removed_card))
		removed_card.mouse_over_card.disconnect(_on_card_hover.bind(removed_card))
		removed_card.mouse_exit_card.disconnect(_on_card_exit.bind(removed_card))
	
	return removed_card


# remove and return all cards
func remove_all() -> Array[Card3D]:
	var cards_to_return = cards
	cards = []
	card_indicies = {}
	
	for c in cards_to_return:
		remove_child(c)
	
	return cards_to_return


func execute_card_strategy():
	card_layout_strategy.update_card_positions(cards, card_move_tween_duration)


func preview_card_drop(dragging_card: Card3D, index: int):
	var preview_cards: Array[Card3D] = []
	
	if card_indicies.has(dragging_card):
		# dragging card in the current collection
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
	dropzone_collision.disabled = false


func disable_drop_zone():
	dropzone_collision.disabled = true


func on_drag_hover(dragging_card: Card3D, mouse_position: Vector2):
	var index_to_drop = get_card_index_at_point(mouse_position)
	
	preview_card_drop(dragging_card, max(index_to_drop, 0))


func get_card_index_at_point(position: Vector2):
	var camera = get_window().get_camera_3d()
	var index = cards.size()
	# iterate cards until finding screen position after mouse position
	#   this is the index where we will add card
	for card in cards:
		var card_index = card_indicies[card]
		var card_position = card_layout_strategy.calculate_card_position_by_index(cards.size(), card_index)
		var card_screen_position = camera.unproject_position(card_position)
		if position.x < card_screen_position.x:
			index = card_indicies[card]
			break
	
	return index


func _on_card_hover(card: Card3D):
	if not selection_disabled:
		_hovered_card = card
		card.set_hovered()


func _on_card_exit(card: Card3D):
	if not selection_disabled and _hovered_card == card:
		card.remove_hovered()
		_hovered_card = null


func _on_card_pressed(card: Card3D):
	card_selected.emit(card)


func _on_drop_zone_mouse_entered():
	mouse_enter_drop_zone.emit()


func _on_drop_zone_mouse_exited():
	mouse_exit_drop_zone.emit()
