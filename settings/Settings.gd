extends Control


func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		visible = get_tree().paused


func unpause():
	get_tree().paused = false
	visible = false
