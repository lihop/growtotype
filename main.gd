extends Node

var score := 0

var cur_level_misses := 0


func _ready():
	get_tree().paused = true

	$LightningBolt.visible = false
	$LightningBolt.position = Vector2(-100, -100)
	$LightningBolt.goal_point = Vector2(-100, -100)

	Game.connect("scored", self, "_on_scored")
	Game.connect("mode_changed", self, "_on_mode_changed")
	Game.connect("growth_rate_changed", self, "_on_growth_rate_changed")

	Game.max_score = get_tree().get_nodes_in_group("plant").size()


func _on_Words_word_typed(word: String):
	var plants = get_tree().get_nodes_in_group("plant")
	var unplanted = get_tree().get_nodes_in_group("unplanted")
	var planted = get_tree().get_nodes_in_group("planted")
	var harvestable = get_tree().get_nodes_in_group("harvestable")

	for _i in word.length() * Game.growth_rate:
		var plant: Plant
		var i = randi() % 100

		if i >= 98 and not harvestable.empty():
			plant = harvestable[randi() % harvestable.size()]
		elif i >= 85 and not planted.empty():
			plant = planted[randi() % planted.size()]
		elif not unplanted.empty():
			plant = unplanted[randi() % unplanted.size()]
		elif not planted.empty():
			plant = planted[randi() % planted.size()]
		elif not harvestable.empty():
			plant = harvestable[randi() % harvestable.size()]
		else:
			Game.mode = Game.Modes.OVER

		if plant.stage == Plant.Stage.HARVESTABLE:
			var produce = plant.harvest()
			add_child(produce)
			produce.position = plant.position
			produce.target_position = $WordsLayer/Score.get_global_transform_with_canvas().origin
		else:
			plant.grow()

	plants = get_tree().get_nodes_in_group("plants")
	var harvested = get_tree().get_nodes_in_group("harvested")

	if plants.size() > 0 and plants.size() == harvested.size():
		Game.mode = Game.Modes.OVER


func _on_Area2D_area_entered(area):
	Game.score += 1
	area.get_parent().queue_free()


func _on_scored(new_score):
	$Coin.play()
	$WordsLayer/Score.text = "SCORE %d" % new_score


func _on_mode_changed(new_mode):
	match new_mode:
		Game.Modes.OVER:
			$WordsLayer/Words.queue_free()
			$WordsLayer/Congratulations.visible = true

		Game.Modes.CALM, _:
			$CalmMusic.play()
			$WordsLayer/ColorRect.visible = false


func _unhandled_input(event):
	$WordsLayer/Words/LineEdit.grab_focus()


func _on_Words_word_missed():
	Game.on_word_missed()
	var visible_plants = get_tree().get_nodes_in_group("visible_plants")

	if visible_plants.empty():
		return

	var plant: Node2D = visible_plants[randi() % visible_plants.size()]

	$LightningBolt.visible = true
	$LightningBolt.global_position.x = plant.global_position.x
	$LightningBolt.goal_point = plant.global_position
	var ashes = preload("res://entities/ashes.tscn").instance()
	plant.get_parent().add_child(ashes)
	ashes.position = plant.position
	if not plant.is_in_group("harvested"):
		Game.max_score -= 1
	plant.queue_free()
	$WhipCrack.play()
	yield(get_tree().create_timer(0.5), "timeout")
	$LightningBolt.visible = false
	$LightningBolt.global_position = Vector2(-100, -100)
	$LightningBolt.goal_point = Vector2(-100, -100)


func _on_PlayButton_pressed():
	get_tree().paused = false
	$WordsLayer/Words.visible = true
	$MenuLayer/PlayButton.queue_free()
