extends Node2D

const N : int = 1
const E : int = 2
const S : int = 4
const W : int = 8

const CELL_WALLS = {
	Vector2(0, -2): N,
	Vector2(2, 0): E,
	Vector2(0, 2): S,
	Vector2(-2, 0): W,
}

const MAP_WIDTH : int = 48
const MAP_HEIGHT : int = 28
var tile_size : float
var map_seed : int = 0
var fraction_of_walls_to_remove : float = 0.2

onready var Map : TileMap = $TileMap
onready var Cam : Camera2D = $Camera2D

func _ready():
	Cam.make_current()
	Cam.zoom = Vector2(3, 3)
# warning-ignore:integer_division
# warning-ignore:integer_division
	Cam.position = Map.map_to_world(Vector2(MAP_WIDTH / 2, MAP_HEIGHT / 2))
	randomize()
	if !map_seed:
		map_seed = randi()
	seed(map_seed)
	tile_size = Map.cell_size.x
	build_maze()
	erase_walls()

func build_maze():
	var unvisited_cells = []
	var stack = []
	
	Map.clear()
	
	# Fill map with solid tiles (N|E|S|W == 15, using bitwise OR)
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			if x % 2 == 0 and y % 2 == 0:
				unvisited_cells.append(Vector2(x, y))
			Map.set_cellv(Vector2(x, y), N|E|S|W)
	var current_cell_location = Vector2(0, 0)
	unvisited_cells.erase(current_cell_location)
	
	# Run recursive backtracker
	while unvisited_cells:
		var unvisited_neighbours = get_unvisited_neighbours(current_cell_location, unvisited_cells)
		if unvisited_neighbours.size() > 0:
			var next_cell_location = unvisited_neighbours[randi() % unvisited_neighbours.size()]
			stack.append(current_cell_location)
			
			var direction = next_cell_location - current_cell_location
			var current_cell_walls = Map.get_cellv(current_cell_location) - CELL_WALLS[direction]
			var next_cell_walls = Map.get_cellv(next_cell_location) - CELL_WALLS[-direction]
			Map.set_cellv(current_cell_location, current_cell_walls)
			Map.set_cellv(next_cell_location, next_cell_walls)
			if direction.x != 0:
				Map.set_cellv(current_cell_location + direction / 2, 5)
			else:
				Map.set_cellv(current_cell_location + direction / 2, 10)
			current_cell_location = next_cell_location
			unvisited_cells.erase(current_cell_location)
		elif stack:
			current_cell_location = stack.pop_back()
		#yield(get_tree(), 'idle_frame')

func get_unvisited_neighbours(cell_location, unvisited_cells):
	var unvisited_neighbours = []
	for cardinal_direction in CELL_WALLS.keys():
		if cell_location + cardinal_direction in unvisited_cells:
			unvisited_neighbours.append(cell_location + cardinal_direction)
	return unvisited_neighbours

func erase_walls():
	for _i in range(int(MAP_WIDTH * MAP_HEIGHT * fraction_of_walls_to_remove)):
		var x = int(rand_range(1, (MAP_WIDTH - 1) / 2)) * 2
		var y = int(rand_range(1, (MAP_HEIGHT - 1) / 2)) * 2
		var cell = Vector2(x, y)
		var neighbour = CELL_WALLS.keys()[randi() % CELL_WALLS.size()]
		
		# Using bitwise and to verify if there is a wall between cell and neighbour
		if Map.get_cellv(cell) & CELL_WALLS[neighbour]:
			var cell_walls = Map.get_cellv(cell) - CELL_WALLS[neighbour]
			var neighbour_walls = Map.get_cellv(cell + neighbour) - CELL_WALLS[-neighbour]
			Map.set_cellv(cell, cell_walls)
			Map.set_cellv(cell + neighbour, neighbour_walls)
			if neighbour.x != 0:
				Map.set_cellv(cell + neighbour / 2, 5)
			else:
				Map.set_cellv(cell + neighbour / 2, 10)
		yield(get_tree(), 'idle_frame')
