class_name SuitDiscard
extends DragStrategy

func can_insert_card(card: FaceCard3D, to_collection: CardCollection3D, from_collection: CardCollection3D) -> bool:
	if from_collection.card_indicies.has(card) and from_collection.card_indicies[card] < from_collection.cards.size() - 1:
		return false

	var to_cards = to_collection.cards
	if to_cards.size() == 0:
		return card.rank == FaceCards.Rank.ACE

	var last_card = to_cards[to_cards.size() - 1]
	var is_next_rank = (card.rank == last_card.rank + 1) or (last_card.rank == FaceCards.Rank.ACE and card.rank == FaceCards.Rank.TWO)
	var is_same_suit = last_card.suit == card.suit

	return is_next_rank and is_same_suit
