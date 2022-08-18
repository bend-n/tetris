class_name Tetris
extends AspectRatioContainer

const ROWS = 20
const COLUMNS = 10

export(PoolColorArray) var colors

var current_shape: TetrisPiece
var matrix := Logic.create_matrix(ROWS, COLUMNS)
var bg_squares := []
var squares := []


func get_square(at: Vector2) -> Control:
	return squares[at.y * COLUMNS + at.x]


func init_squares():
	var bg := create_grid_container("background")
	add_child(bg)
	var fg := create_grid_container("foreground")
	add_child(fg)
	for _i in range(ROWS * COLUMNS):
		var bg_square := ReferenceRect.new()
		bg_square.editor_only = false
		bg_square.border_width = 1.5
		bg_square.border_color = Color.ghostwhite
		bg_square.name = "%d" % _i
		expand_control(bg_square)
		bg.add_child(bg_square)
		var fg_square = ColorRect.new()
		fg_square.color = Color.transparent
		fg_square.name = "%d" % _i
		expand_control(fg_square)
		fg.add_child(fg_square)
		squares.append(fg_square)


func create_grid_container(name: String) -> GridContainer:
	var g := GridContainer.new()
	g.columns = COLUMNS
	g.name = name
	g.add_constant_override("hseparation", 0)
	g.add_constant_override("vseparation", 0)
	g.set_anchors_and_margins_preset(PRESET_WIDE)
	return g


func expand_control(c: Control) -> void:
	c.size_flags_horizontal = SIZE_EXPAND_FILL
	c.size_flags_vertical = SIZE_EXPAND_FILL
	c.set_anchors_and_margins_preset(PRESET_WIDE)


func _ready() -> void:
	set_process(false)
	assert(len(colors) == Logic.shapes.size())  # 7
	ratio = float(COLUMNS) / float(ROWS)
	init_squares()
	start()


func start() -> void:
	set_process(true)
	# warning-ignore-all:integer_division
	current_shape = TetrisPiece.new(Vector2((COLUMNS / 2) - 2, 0))
	tick()


func draw_board(mat: Array = matrix.duplicate(true), shape: TetrisPiece = current_shape) -> void:
	shape.embed(mat)
	for y in range(ROWS):
		for x in range(COLUMNS):
			get_square(Vector2(x, y)).color = (
				colors[mat[y][x] - 1]
				if mat[y][x] > 0
				else Color.transparent
			)


func _input(event):
	if event is InputEventSwipe:
		match event.direction.round().normalized():
			Vector2.RIGHT:
				current_shape.move(Vector2.RIGHT, matrix)
			Vector2.LEFT:
				current_shape.move(Vector2.LEFT, matrix)
			Vector2.DOWN:
				current_shape.fall(matrix)
				tick(false)
			_:
				current_shape.rotate(matrix)
				tick(false)

	if event.is_action_pressed("ui_left", true):
		current_shape.move(Vector2.LEFT, matrix)
	elif event.is_action_pressed("ui_right", true):
		current_shape.move(Vector2.RIGHT, matrix)
	if event.is_action_pressed("ui_up"):
		current_shape.rotate(matrix, true)
	if event.is_action_pressed("ui_down"):
		current_shape.fall(matrix)
		tick(false)
	else:
		draw_board()


func tick(create_timer := true):
	if create_timer:
		var t := get_tree().create_timer(.25)
		t.connect("timeout", self, "tick")

	if not current_shape.move(Vector2(0, 1), matrix):  # invalid move: cant go down
		if current_shape.position.y == 0:
			get_tree().reload_current_scene()
		current_shape.embed(matrix)
		current_shape = TetrisPiece.new(Vector2(randi() % (COLUMNS - 4), 0))
		Logic.clear_lines(matrix)
		print(ascii(matrix))
	draw_board()


#warning-ignore:shadowed_variable
func ascii(matrix):
	var s = "+"
	for _x in range(COLUMNS):
		s += "-"
	s += "+"
	#warning-ignore:shadowed_variable
	for y in range(ROWS):
		s += "\n" + ("|" if y != ROWS - 1 else "+")
		for x in range(COLUMNS):
			if matrix[y][x] > 0:
				s += "ﱢ"
			else:
				s += "-"
		s += ("|" if y != ROWS - 1 else "+")
	return s
