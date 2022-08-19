extends Resource
class_name TetrisPiece

var shape_type: int
var shape: Array
var position: Vector2
var stopped := false


func _init(pos: Vector2, _s: Array) -> void:
	position = pos
	shape_type = Logic.piece_indexs[_s]
	var s := [0, 0, 0, 0]
	s.append_array(_s)

	for y in range(4):
		shape.append([])
		for x in range(4):
			var i: int = y * 4 + x
			if len(s) > i and s[i] > 0:
				shape[y].append(1)
			else:
				shape[y].append(0)


# 90 deg
func _rotate_cw() -> void:
	var new_shape = shape.duplicate(true)
	new_shape[0][0] = shape[3][0]
	new_shape[0][1] = shape[2][0]
	new_shape[0][2] = shape[1][0]
	new_shape[0][3] = shape[0][0]
	new_shape[1][3] = shape[0][1]
	new_shape[2][3] = shape[0][2]
	new_shape[3][3] = shape[0][3]
	new_shape[3][2] = shape[1][3]
	new_shape[3][1] = shape[2][3]
	new_shape[3][0] = shape[3][3]
	new_shape[2][0] = shape[3][2]
	new_shape[1][0] = shape[3][1]

	new_shape[1][1] = shape[2][1]
	new_shape[1][2] = shape[1][1]
	new_shape[2][2] = shape[1][2]
	new_shape[2][1] = shape[2][2]
	shape = new_shape


func embed(matrix: Array) -> Array:
	for y in range(4):
		for x in range(4):
			if shape[y][x] > 0:
				matrix[y + position.y][x + position.x] = 1 + shape_type
	return matrix


func move(direction: Vector2, matrix: Array) -> bool:
	if Logic.valid_move(matrix, self, direction):
		position += direction
		return true
	return false


func rotate(matrix: Array, cw := true):
	var s = shape.duplicate(true)
	if cw:
		_rotate_cw()
	else:
		for _i in range(3):
			_rotate_cw()
	if !Logic.valid_move(matrix, self):
		shape = s
		return false
	return true


func fall(matrix: Array) -> void:
	while move(Vector2.DOWN, matrix):
		continue
