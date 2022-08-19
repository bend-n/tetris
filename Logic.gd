extends Reference
class_name Logic

const i := [ 0, 0, 0, 0,
             1, 1, 1, 1 ]
const j := [ 0, 1, 1, 1,
			 0, 0, 0, 1 ]
const l := [ 1, 1, 1, 0,
             1 ]
const o := [ 0, 1, 1, 0,
             0, 1, 1 ]
const s := [ 0, 1, 1, 0,
             1, 1 ]
const t := [ 0, 1, 0, 0,
             1, 1, 1 ]
const z := [ 1, 1, 0, 0,
             0, 1, 1 ]

const piece_bag := [i, i, i, i, j, j, j, j, l, l, l, l, o, o, o, o, s, s, s, s, t, t, t, t, z, z, z, z]
const piece_indexs := {i: 0, j: 1, l: 2, o: 3, s: 4, t: 5, z: 6}


static func create_matrix(rows: int, columns: int) -> Array:
	var matrix = []
	for y in range(rows):
		matrix.append([])
		for _x in range(columns):
			matrix[y].append(0)

	return matrix


static func valid_move(matrix: Array, piece, offset := Vector2()) -> bool:
	offset += piece.position
	for y in range(4):
		for x in range(4):
			if get_index_or_null(piece.shape, y, x) > 0:
				#warning-ignore-all:narrowing_conversion
				if (
					get_index_or_null(matrix, y + offset.y, x + offset.x) == null
					or get_index_or_null(matrix, y + offset.y, x + offset.x) > 0
					or x + offset.x < 0
					or y + offset.y >= len(matrix)
					or x + offset.x >= len(matrix[y])
				):
					return false
	return true


static func clear_lines(matrix: Array) -> void:
	var y = len(matrix)
	while y > 0:
		y -= 1
		if matrix[y].min() > 0:
			for yy in range(y, 1, -1):
				matrix[yy] = matrix[yy - 1]
			y += 1


static func get_index_or_null(arr: Array, y: int, x: int) -> int:
	return arr[y][x] if y < len(arr) and x < len(arr[y]) else null


static func print_matrix(mat: Array):
	for i in mat:
		print(i)
