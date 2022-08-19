tool
class_name Tetris
extends MarginContainer

const ROWS = 20
const COLUMNS = 10

export(PoolColorArray) var colors
export(PoolColorArray) var transcolors
export(Color) var grid_color
export(Color) var bg_color

var current_shape: TetrisPiece
var matrix := Logic.create_matrix(ROWS, COLUMNS)
var bg_squares := []
var squares := []
var nxt_p_squares := []

var bag := Logic.piece_bag.duplicate(true)
onready var next_shape: Array = bag.pop_at(randi() % len(bag))


func random_shape() -> Array:
	var n = next_shape
	next_shape = bag.pop_at(randi() % len(bag))
	if bag.empty():
		bag = Logic.piece_bag.duplicate(true)
	draw_nxt_p_shape()
	return n


func draw_nxt_p_shape():
	var clr = colors[Logic.piece_indexs[next_shape]]
	var n = [0, 0, 0, 0]
	n.append_array(next_shape.duplicate())
	for i in range(4 * 4):
		nxt_p_squares[i].color = Color.transparent
		if i > len(n) - 1 or n[i] == 0:
			continue
		nxt_p_squares[i].color = clr


func get_square(at: Vector2) -> Control:
	return squares[at.y * COLUMNS + at.x]


func init_squares(on: Control):
	var aspect = AspectRatioContainer.new()
	aspect.alignment_vertical = aspect.ALIGN_BEGIN
	aspect.ratio = float(COLUMNS) / float(ROWS)
	aspect.name = "aspect"
	expand_control(aspect)
	on.add_child(aspect)
	var sqs := create_grid_container("squares")
	aspect.add_child(sqs)
	print_tree_pretty()
	for _i in range(ROWS * COLUMNS):
		squares.append(create_square(sqs, "%d" % _i))


func create_square(to: GridContainer, name: String, bg := true) -> ColorRect:
	var fg_square := ColorRect.new()
	fg_square.color = Color.transparent
	fg_square.name = name
	fg_square.rect_min_size = Vector2(10, 10)
	expand_control(fg_square)
	to.add_child(fg_square)
	if bg:
		var bg_square := ReferenceRect.new()
		bg_square.editor_only = false
		bg_square.border_width = 1.5
		bg_square.border_color = grid_color
		bg_square.name = name
		bg_square.show_behind_parent = true
		expand_control(bg_square)
		fg_square.add_child(bg_square)
	return fg_square


func create_grid_container(name: String, cols := COLUMNS, expand := true) -> GridContainer:
	var g := GridContainer.new()
	g.columns = cols
	g.name = name
	g.add_constant_override("vseparation", 0)
	g.add_constant_override("hseparation", 0)
	if expand:
		expand_control(g)
	return g


func expand_control(c: Control) -> void:
	c.size_flags_horizontal = SIZE_EXPAND_FILL
	c.size_flags_vertical = SIZE_EXPAND_FILL
	c.set_anchors_and_margins_preset(PRESET_WIDE)


func init_bg() -> void:
	var c := ColorRect.new()
	c.name = "bg"
	expand_control(c)
	c.color = bg_color
	add_child(c)


func init_next_preview(on: Control):
	var aspect := AspectRatioContainer.new()
	aspect.alignment_vertical = aspect.ALIGN_BEGIN
	aspect.name = "aspect"
	aspect.set_anchors_and_margins_preset(PRESET_WIDE)
	on.add_child(aspect)
	var next = create_grid_container("next-block-preview", 4, false)
	aspect.add_child(next)
	for _i in range(4 * 4):
		nxt_p_squares.append(create_square(next, "%d" % _i, false))

	var square = ReferenceRect.new()
	square.name = "next-block-outline"
	square.border_width = 1.5
	square.border_color = grid_color
	square.editor_only = false
	expand_control(square)
	aspect.add_child(square)


func _ready() -> void:
	set_process(false)
	init_bg()
	var h = HBoxContainer.new()
	h.add_constant_override("hseparation", 5)
	h.name = "hbox"
	add_child(h)
	init_squares(h)
	init_next_preview(h)
	if not Engine.editor_hint:
		start()


func start() -> void:
	set_process(true)
	# warning-ignore-all:integer_division
	current_shape = TetrisPiece.new(Vector2((COLUMNS / 2) - 2, 0), random_shape())
	tick()


func draw_board() -> void:
	var mat := matrix.duplicate(true)
	current_shape.embed(mat)
	var set_squares = draw_preview()
	for y in range(ROWS):
		for x in range(COLUMNS):
			if mat[y][x] > 0:
				get_square(Vector2(x, y)).color = colors[mat[y][x] - 1]
			elif set_squares.find(Vector2(x, y)) == -1:
				get_square(Vector2(x, y)).color = Color.transparent


func draw_preview(shape: TetrisPiece = current_shape) -> PoolVector2Array:
	var p = shape.position
	shape.fall(matrix)
	var set_squares: PoolVector2Array = []
	for y in range(4):
		for x in range(4):
			if Logic.get_index_or_null(shape.shape, y, x) > 0:
				set_squares.append(Vector2(x, y) + shape.position)
				get_square(Vector2(x, y) + shape.position).color = transcolors[shape.shape_type]
	shape.position = p
	return set_squares


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
		if current_shape.stopped:
			print(ascii(matrix))
			current_shape.embed(matrix)
			current_shape = TetrisPiece.new(Vector2(randi() % (COLUMNS - 4), 0), random_shape())
			Logic.clear_lines(matrix)
		else:
			current_shape.stopped = true
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
