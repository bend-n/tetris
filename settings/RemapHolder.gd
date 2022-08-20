extends VBoxContainer

const remappable = ["left", "right", "down", "rotate_cw", "rotate_anti_cw"]


func _ready():
	for remap in remappable:
		var l := RemapButton.new()
		l.action = remap
		l._name = " %s " % remap.replace("_", " ").replace("cw", "clockwise")
		l.icon_size = Vector2(20, 20)
		l.popup = preload("./KeySelector.tscn")
		add_child(l)
