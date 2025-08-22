class_name PlayCardDropzone
extends DragStrategy


@export var play_enabled: bool = true


func can_insert_card(_card: BattleCard3D, _to_collection, _from_collection) -> bool:
	return play_enabled


func can_reorder_card(_card: BattleCard3D, _collection) -> bool:
	return false


func can_select_card(_card: BattleCard3D, _collection) -> bool:
	return false


func can_remove_card(_card: BattleCard3D, _collection) -> bool:
	return false
