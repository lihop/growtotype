extends Control

const WordScene = preload("res://entities/word/word.tscn")

const WORDS_FILE := "res://assets/words/words.txt"

signal word_typed(word)
signal word_missed

export (int) var scroll_speed := 1 setget set_scroll_speed
export (int) var min_size := 5
export (int) var max_size := 9
export (int) var dispatch_frequency := 2

var words := PoolStringArray()
var _len_offset := {}  # Map between word lengths and index of the first word with the given length.

onready var next_dispatch = dispatch_frequency
onready var timer = $Timer
onready var line_edit = $LineEdit

var _prev_text: String

var wrongs := 0
var rights := 0
var current_level := 1

var rights_needed
var wrongs_needed = 10


func set_scroll_speed(value):
	scroll_speed = value
	timer.wait_time = scroll_speed if scroll_speed > 0 else 1


func _ready():
	Game.connect("mode_changed", self, "_on_mode_changed")
	Game.connect("level_changed", self, "set_level")

	connect("word_missed", Game, "_on_word_missed")
	randomize()

	# Load all words from file. One word per line.
	var file := File.new()
	file.open(WORDS_FILE, File.READ)

	var line: String = file.get_line()

	while line != "":
		var length = line.length()
		var index = words.size()

		words.append(line.to_upper())

		if not _len_offset.has(length):
			_len_offset[length] = index

		line = file.get_line()

	set_level(current_level)

	$LineEdit.grab_focus()
	_dispatch_word()


func _input(event):
	if event.is_action_pressed("clear_text"):
		$LineEdit.text = ""
		_on_LineEdit_text_changed("")


func _on_Timer_timeout():
	for word in get_tree().get_nodes_in_group("words"):
		word.rect_position.y += 32

	next_dispatch -= 1
	if next_dispatch == 0:
		_dispatch_word()
		next_dispatch = dispatch_frequency


func _on_LineEdit_text_changed(new_text):
	new_text = new_text.to_upper()

	var matches = false

	var words = get_tree().get_nodes_in_group("words")
	for word in words:
		if word is RichTextLabel:
			if word.text.begins_with(new_text):
				matches = true
				# FIXME: Bug when replacing e.g. MOM -> MO (should only replace start MOM -> MOM).
				word.bbcode_text = (
					"[color=maroon]%s[/color]%s"
					% [new_text, word.text.substr(new_text.length())]
				)
				if word.text == new_text:
					line_edit.text = ""
					emit_signal("word_typed", word.text)
					word.queue_free()
					$LeafCrumple.play()
					rights += 1
					if rights >= ceil(rights_needed * Game.level_up_factor):
						Game.level = min(Game.Levels.size(), current_level + 1)
						if words.size() <= 1:
							_dispatch_word()
			else:
				word.bbcode_text = word.text

	if (
		not matches
		and (
			new_text.length() == 1
			or (_prev_text != "" and new_text.length() >= _prev_text.length())
		)
	):
		# TODO: Some feedback sound.
		line_edit.text = _prev_text
		line_edit.caret_position = line_edit.text.length()

		for word in get_tree().get_nodes_in_group("words"):
			if word is RichTextLabel:
				if word.text.begins_with(_prev_text.to_upper()):
					word.bbcode_text = (
						"[color=maroon]%s[/color]%s"
						% [_prev_text.to_upper(), word.text.substr(_prev_text.length())]
					)

	_prev_text = $LineEdit.text


func _dispatch_word():
	var current_words = get_tree().get_nodes_in_group("words")

	var new_word: String

	while true:
		var i = max(0, ((randi() % _len_offset[max_size]) + _len_offset[min_size]) - 1)
		if words.size() - 1 < i:
			continue
		var candidate = words[i]
		for word in current_words:
			if candidate.begins_with(word.text):
				continue
		new_word = candidate
		break

	var word = WordScene.instance()
	word.word = new_word

	add_child(word)


func _on_Area2D_area_entered(area):
	area.get_parent().get_parent().queue_free()
	$LineEdit.clear()
	current_level = ceil((current_level / 3) * 2)
	emit_signal("word_missed")
	$LineEdit.grab_focus()


func set_level(level: int):
	current_level = clamp(level, 1, 13)
	var spec = Game.Levels[current_level]
	set_scroll_speed(spec.scroll_speed)
	min_size = spec.min_size
	max_size = spec.max_size
	dispatch_frequency = spec.dispatch_frequency
	rights = 0
	wrongs = 0
	rights_needed = spec.rights_needed


func _on_mode_changed(_new_mode):
	$LineEdit.clear()
	$LineEdit.grab_focus()
