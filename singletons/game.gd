extends Node

enum Modes {
	CALM,
	OVER,
}

const Levels = {
	1:
	{
		scroll_speed = 1,
		min_size = 3,
		max_size = 4,
		dispatch_frequency = 5,
		rights_needed = 3,
	},
	2: {scroll_speed = 1, min_size = 3, max_size = 6, dispatch_frequency = 4, rights_needed = 3},
	3: {scroll_speed = 1, min_size = 3, max_size = 6, dispatch_frequency = 3, rights_needed = 4},
	4: {scroll_speed = 0.9, min_size = 4, max_size = 9, dispatch_frequency = 3, rights_needed = 5},
	5: {scroll_speed = 0.9, min_size = 5, max_size = 10, dispatch_frequency = 2, rights_needed = 5},
	6: {scroll_speed = 0.8, min_size = 5, max_size = 12, dispatch_frequency = 3, rights_needed = 5},
	7: {scroll_speed = 0.8, min_size = 5, max_size = 15, dispatch_frequency = 2, rights_needed = 5},
	8:
	{
		scroll_speed = 0.7,
		min_size = 6,
		max_size = 17,
		dispatch_frequency = 3,
		rights_needed = 5,
	},
	9:
	{scroll_speed = 0.7, min_size = 10, max_size = 25, dispatch_frequency = 2, rights_needed = 5},
	10:
	{scroll_speed = 0.6, min_size = 10, max_size = 25, dispatch_frequency = 3, rights_needed = 5},
	11:
	{scroll_speed = 0.6, min_size = 12, max_size = 25, dispatch_frequency = 2, rights_needed = 5},
	12:
	{scroll_speed = 0.5, min_size = 15, max_size = 25, dispatch_frequency = 3, rights_needed = 5},
	13:
	{scroll_speed = 0.5, min_size = 18, max_size = 25, dispatch_frequency = 2, rights_needed = 5},
}

signal mode_changed(new_mode)
signal level_changed(new_level)
signal scored(new_score)
signal growth_rate_changed(new_growth_rate)

var max_score = 0
var score := 0 setget set_score
var level := 1 setget _set_level
var mode: int = Modes.CALM setget _set_mode
var growth_rate := 2 setget _set_growth_rate
var level_up_factor = 1

var highest_level = 3


func _set_mode(new_mode):
	mode = new_mode
	emit_signal("mode_changed", new_mode)


func _set_level(new_level):
	level = new_level
	if level == highest_level:
		self.growth_rate = 3
	emit_signal("level_changed", new_level)


func _set_growth_rate(new_growth_rate):
	return


func set_score(new_score):
	score = new_score
	#var plants = get_tree().get_nodes_in_group("plants")
	#var harvested = get_tree().get_nodes_in_group("harvested")
	#if harvested.size() > 0 and plants.size() == harvested.size():
	if score >= max_score:
		self.mode = Modes.OVER
	emit_signal("scored", new_score)


func _ready():
	get_tree().paused = true
	self.score = 0
	self.level = 1
	self.mode = Modes.CALM


func on_word_missed():
	self.growth_rate = 1
	highest_level = level

	for word in get_tree().get_nodes_in_group("words"):
		word.queue_free()

	self.level = ceil((level / 3) * 2)
	level_up_factor = level_up_factor * 1.05
