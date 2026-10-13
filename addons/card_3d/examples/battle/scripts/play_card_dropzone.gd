class_name PlayCardDropzone
extends DragStrategy


@export var play_enabled: bool = true


func can_insert_card(
	_card: BattleCard3D,
	_to_collection: CardCollection3D, 
	_from_collection: CardCollection3D
	) -> bool:
	return play_enabled
