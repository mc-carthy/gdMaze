extends Node2D

const N : int = 1
const E : int = 2
const S : int = 4
const W : int = 8

const CELL_WALLS = {
	Vector2(0, -1): N,
	Vector2(1, 0): E,
	Vector2(0, 1): S,
	Vector2(-1, 0): W,
}

const MAP_WIDTH : int = 25
const MAP_HEIGHT : int = 15
var tile_size : float

onready var Map : TileMap = $TileMap

func _ready():
	randomize()
	tile_size = Map.cell_size.x
	build_maze()

func build_maze():
	pass
