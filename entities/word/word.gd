extends Node2D

const MARGIN = 32
const NUDGE_AMOUNT = 16

var word: String
var width: int
var min_left: int
var max_right: int
var direction = MARGIN_LEFT if randi() % 2 == 0 else MARGIN_RIGHT
var text setget set_text
var bbcode_text setget set_bbcode_text


func set_text(value):
	$RichTextLabel.text = value


func set_bbcode_text(value):
	$RichTextLabel.bbcode_text = value


func _ready():
	$RichTextLabel.text = word
	$RichTextLabel.bbcode_text = word
	var size = $RichTextLabel.get_font("normal_font").get_string_size(word)
	min_left = MARGIN
	max_right = get_tree().root.size.x - MARGIN - size.x - 128  # Don't overlap score.
	position.x = randi() % max_right + min_left
	$RichTextLabel.rect_size = size * Vector2(32, 32)
