extends Sprite

var speed := 3
var target_position: Vector2 setget set_target_position


func _ready():
	set_physics_process(false)


func set_target_position(value):
	target_position = value
	set_physics_process(true)


func _physics_process(delta):
	if position.is_equal_approx(target_position):
		queue_free()
	else:
		position = lerp(position, target_position, speed * delta)
