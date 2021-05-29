class_name Plant
extends Node2D

enum Stage {
	UNPLANTED,
	PLANTED,
	HARVESTABLE,
	HARVESTED,
}

export (int) var growth_frames := 4
export (int) var harvest_frames := 3
export (Texture) var produce_texture
export (Rect2) var produce_rect
export (bool) var frames_reversed := true
export (String) var animation setget set_animation
export (int) var loop_frame := 0
export (int) var grown_frame

export (Stage) var initial_stage := Stage.UNPLANTED

export (bool) var show_produce

# Psuedo-buttons to preview growth animations.
export (bool) var reset := false setget set_reset
#export(bool) var grow := false setget set_grow

var planted := false
var grown := false setget set_grown
var harvestable := false setget set_harvestable

var stage: int setget set_stage

onready var growth: AnimatedSprite = $Growth
onready var produce: Sprite = $Produce
onready var max_frames = growth.frames.get_frame_count(growth.animation)


func set_animation(value):
	animation = value
	growth.animation = animation
	reset()


func set_growth_animation(value):
	pass
	#growth_animation = value
	$Grown.frames


func set_reset(_value):
	reset()


func set_grow(_value):
	grow()


func set_grown(value):
	grown = value


func set_harvestable(value):
	harvestable = value
	if harvestable:
		remove_from_group("growables")
		add_to_group("harvestables")
	else:
		remove_from_group("harvestables")
		add_to_group("growables")


func get_harvestable() -> bool:
	return growth.frame == growth.frames.get_frame_count(growth.animation) - 2


func set_stage(value):
	stage = value

	match stage:
		Stage.UNPLANTED:
			visible = false
			add_to_group("unplanted")
		Stage.PLANTED:
			remove_from_group("unplanted")
			visible = true
			produce.visible = false
			growth.frame = 0
			add_to_group("visible_plants")
			add_to_group("planted")
		Stage.HARVESTABLE:
			remove_from_group("planted")
			growth.frame = max_frames - 2
			add_to_group("harvestable")
		Stage.HARVESTED:
			remove_from_group("harvestable")
			growth.frame = max_frames
			add_to_group("harvested")


func reset():
	set_harvestable(false)
	set_grown(false)
	$AnimatedSprite.frame = 0


func grow():
	if stage < Stage.HARVESTABLE:
		match stage:
			Stage.UNPLANTED:
				set_stage(Stage.PLANTED)
			Stage.PLANTED:
				growth.frame += 1
				if growth.frame == max_frames - 2:
					set_stage(Stage.HARVESTABLE)


func harvest() -> Sprite:
	if stage != Stage.HARVESTABLE:
		return null

	growth.frame += 1
	produce.visible = true
	remove_child(produce)
	set_stage(Stage.HARVESTED)
	return produce


func _ready():
	set_stage(Stage.UNPLANTED)
