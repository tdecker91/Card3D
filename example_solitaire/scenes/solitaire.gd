"""
Solitaire
======================

Not a perfect implemenation of solitaire. But just an example of implementing a game using
the Card3D asset
"""
extends Node3D


var card_database = FaceCards.new()


@onready var deck_collection: CardCollection3D = $Deck
@onready var draw_collection: CardCollection3D = $DragController/Draw
@onready var column1: CardCollection3D = $DragController/Column1
@onready var column2: CardCollection3D = $DragController/Column2
@onready var column3: CardCollection3D = $DragController/Column3
@onready var column4: CardCollection3D = $DragController/Column4
@onready var column5: CardCollection3D = $DragController/Column5
@onready var column6: CardCollection3D = $DragController/Column6
@onready var column7: CardCollection3D = $DragController/Column7


# Called when the node enters the scene tree for the first time.
func _ready():
	var card_deck: Array[FaceCard3D] = []

	for suit in FaceCards.Suit:
		for rank in FaceCards.Rank:
			card_deck.push_back(instantiate_face_card(FaceCards.Rank[rank], FaceCards.Suit[suit]))

	card_deck.shuffle()

	var columns: Array[CardCollection3D] = [column1, column2, column3, column4, column5, column6, column7]
	var j = 1
	
	for column in columns:
		for num in range(j):
			var card = card_deck.pop_front()
			if num != j - 1:
				card.face_down = true
			column.append_card(card)

	j += 1

	for card in card_deck:
		deck_collection.append_card(card)
	
	$DragController/Column1.card_clicked.connect(_on_card_clicked.bind($DragController/Column1))
	$DragController/Column2.card_clicked.connect(_on_card_clicked.bind($DragController/Column2))
	$DragController/Column3.card_clicked.connect(_on_card_clicked.bind($DragController/Column3))
	$DragController/Column4.card_clicked.connect(_on_card_clicked.bind($DragController/Column4))
	$DragController/Column5.card_clicked.connect(_on_card_clicked.bind($DragController/Column5))
	$DragController/Column6.card_clicked.connect(_on_card_clicked.bind($DragController/Column6))
	$DragController/Column7.card_clicked.connect(_on_card_clicked.bind($DragController/Column7))

func instantiate_face_card(rank, suit) -> FaceCard3D:
	var scene = load("res://example/face_card_3d.tscn")
	var face_card_3d: FaceCard3D = scene.instantiate()

	var card_data: Dictionary = card_database.get_card_data(rank, suit)
	face_card_3d.data = card_data

	return face_card_3d


func _on_deck_card_selected(_card):
	var cards = deck_collection.cards
	var card_global_position = cards[cards.size() - 1].global_position
	var drawn_card = deck_collection.remove_card(cards.size() - 1)
	draw_collection.append_card(drawn_card)
	drawn_card.global_position = card_global_position

	if cards.size() == 0:
		#await(get_tree().create_timer(.1), "timeout")
		var timer = get_tree().create_timer(.1)
		await timer.timeout
		$EmptyDeck.visible = true


func _on_card_clicked(card: FaceCard3D, column: CardCollection3D):
	if column.card_indicies.has(card):
		var card_index = column.card_indicies[card]
		if card_index == column.cards.size() - 1 and card.face_down:
			card.face_down = false


func _on_empty_deck_on_click():
	$EmptyDeck.visible = false
	var cards = draw_collection.remove_all()
	for card in cards:
		deck_collection.append_card(card)


func _on_drag_controller_card_moved(_card: FaceCard3D, from_collection: CardCollection3D, to_collection: CardCollection3D, from_index, _to_index):
	if from_collection == to_collection:
		return
	
	if not from_collection is CardColumn or not to_collection is CardColumn:
		return

	while from_collection.cards.size() > from_index: 
		var new_position = from_collection.cards[from_index].global_position
		var card = from_collection.remove_card(from_index)
		to_collection.append_card(card)
		card.global_position = new_position
