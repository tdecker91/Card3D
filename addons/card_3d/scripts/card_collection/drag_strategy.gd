class_name DragStrategy
extends Resource
"""
DragStrategy
======================

This module defines an interface that describes how cards can drag from different collections.
It can be configured either by:
	1. Setting the drag strategy on your collection to a new DragStrategy resource via the Inspector
		(Add Resource → DragStrategy) and configuring the default boolean values.
	2. Creating a custom script that extends DragStrategy and overriding the hooks
		(can_select_card, can_remove_card, can_reorder_card, can_insert_card)
		to implement checks based on the card and collection.
"""


@export_group("Default Behavior")
@export var can_select: bool = true
@export var can_remove: bool = true
@export var can_reorder: bool = true
@export var can_insert: bool = true


func can_select_card(_card, _to_collection: CardCollection3D) -> bool:
	return can_select


func can_remove_card(_card, _to_collection: CardCollection3D) -> bool:
	return can_remove


func can_reorder_card(_card, _to_collection: CardCollection3D) -> bool:
	return can_reorder


func can_insert_card(
	_card,
	_to_collection: CardCollection3D,
	_from_collection: CardCollection3D
	) -> bool:
	return can_insert
