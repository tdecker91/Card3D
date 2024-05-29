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


@export var card_move_tween_duration: float = 0.2
@export var card_layout_strategy: CardLayout = LineCardLayout.new():
	set(strategy):
		card_layout_strategy = strategy
		execute_card_strategy()


@onready var dropzone_collision: CollisionShape3D = $DropZone/CollisionShape3D


var cards: Array[Card3D] = []
var card_indicies = {}


# add a card to the hand and animate it to the correct position
# this will add card as child of this node
func add_card(card: Card3D):
	cards.append(card)
	card_indicies[card] = cards.size() - 1
	add_child(card)
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


func enable_drop_zone():
	dropzone_collision.disabled = false

func disable_drop_zone():
	dropzone_collision.disabled = true


func _on_drop_zone_mouse_entered():
	mouse_enter_drop_zone.emit()


func _on_drop_zone_mouse_exited():
	mouse_exit_drop_zone.emit()
