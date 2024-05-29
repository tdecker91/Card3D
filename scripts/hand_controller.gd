extends Node3D

var suits = ["club", "diamond", "heart", "spade"]
var values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]

var si = 0
var vi = 0

@onready var camera = $"../Camera3D"
@onready var hand: Hand3D = $"Hand3D"
@onready var pile: CardPile3D = $CardPile3D

var dragging_card: Card3D
var dropping_collection: CardCollection3D

func _ready():
	#hand = Hand3D.new()
	#hand.position.y = -12
	#hand.card_layout_strategy = FanCardLayout.new()
	var layout := LineCardLayout.new()
	layout.max_width = 20
	pile.card_layout_strategy = layout
	hand.card_layout_strategy = FanCardLayout.new()
	hand.camera = camera
	#add_child(hand)
	pile.mouse_enter_drop_zone.connect(mouse_enter_pile_drop_zone.bind())
	pile.mouse_exit_drop_zone.connect(mouse_exit_pile_drop_zone.bind())

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
			layout.max_width = 18
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


func clear_cards():
	var hand_cards = hand.remove_all()
	var pile_cards = pile.remove_all()
	
	for c in hand_cards:
		c.queue_free()
		
	for c in pile_cards:
		c.queue_free()


func play_card(card):
	var card_index = hand.card_indicies[card]
	var global_position = hand.cards[card_index].global_position
	var c = hand.remove_card(card_index)
	
	pile.add_card(c)
	c.remove_hovered()
	c.global_position = global_position

func mouse_enter_pile_drop_zone():
	print("hand controller mouse enter drop zone")
	dropping_collection = pile


func mouse_exit_pile_drop_zone():
	print("hand controller mouse exit drop zone")
	dropping_collection = null


func _on_hand_3d_drag_started(card):
	dragging_card = card
	#hand.enable_drop_zone()
	pile.enable_drop_zone()


func _on_hand_3d_drag_stopped():
	pile.disable_drop_zone()
	
	if dropping_collection != null:
		play_card(dragging_card)
		
	dragging_card = null
