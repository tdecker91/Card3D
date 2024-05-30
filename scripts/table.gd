extends Node3D

var suits = ["club", "diamond", "heart", "spade"]
var values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]

var si = 0
var vi = 0

@onready var hand: CardCollection3D = $DragController/Hand
@onready var pile: CardCollection3D = $DragController/TableCards



func _input(event):
	if event.is_action_pressed("ui_down"):
		add_card()
	elif event.is_action_pressed("ui_up"):
		remove_card()
	elif event.is_action_pressed("ui_left"):
		clear_cards()
	elif event.is_action_pressed("ui_right"):
		if pile.card_layout_strategy is PileCardLayout and hand.card_layout_strategy is LineCardLayout:
			var layout := LineCardLayout.new()
			pile.card_layout_strategy = layout
		elif hand.card_layout_strategy is LineCardLayout:
			hand.card_layout_strategy = FanCardLayout.new()
		elif pile.card_layout_strategy is LineCardLayout:
			pile.card_layout_strategy = PileCardLayout.new()
		elif hand.card_layout_strategy is FanCardLayout:
			hand.card_layout_strategy = LineCardLayout.new()


func add_card():
	var card_scene = load("res://scenes/card_3d.tscn")
	var card_instance: Card3D = card_scene.instantiate()
	
	var suit = suits[si]
	var value = values[vi]
	
	vi += 1
	
	if vi == 13:
		vi = 0
		si += 1
		
	if si == 4:
		si = 0
	
	card_instance.value = value
	card_instance.suit = suit
	hand.add_card(card_instance)


func remove_card():
	if hand.cards.size() == 0:
		return
		
	var random_card_index = randi() % hand.cards.size()
	var card_to_remove = hand.cards[random_card_index]
	
	play_card(card_to_remove)


func play_card(card):
	var card_index = hand.card_indicies[card]
	var card_global_position = hand.cards[card_index].global_position
	var c = hand.remove_card(card_index)
	
	pile.add_card(c)
	c.remove_hovered()
	c.global_position = card_global_position


func clear_cards():
	var hand_cards = hand.remove_all()
	var pile_cards = pile.remove_all()
	
	for c in hand_cards:
		c.queue_free()
		
	for c in pile_cards:
		c.queue_free()
