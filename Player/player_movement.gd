class_name Player extends CharacterBody2D

# Object References
@export var map: Map

# Parameters
@export var max_speed: float = 64.0
@export var do_lerp_smoothing: bool = false
@export var lerp_factor: float = 5.0

var _input_dir: Vector2
var _target_cell: Vector2i
var _target_pos: Vector2
var _prev_direction: Vector2i
var _speed: float
var move_count: int = 1
const MOVES_PER_TURN = 3
const MIN_DIST = 0.001
const DEADZONE = 0.5
var game_active: bool = true

# Signal for player movement
signal player_moved(direction: Vector2i)
signal player_moved_to(cell: Cell)
	# UI Manager: update_current_cell()

# Called when the node enters the scene tree for the first time
func _ready():
	_target_pos = position
	_target_cell = map.pos_to_cell_coord(_target_pos)
	
	player_moved.connect(handle_turns)

func _process(delta):
	set_input_direction()
	update_move()

func set_input_direction():
	_input_dir = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized()

func update_move():
	if not game_active:
		return
	
	if is_moving():
		_speed = lerp(_speed, max_speed, lerp_factor * get_process_delta_time()) if do_lerp_smoothing else max_speed
		position = position.move_toward(_target_pos, _speed * get_process_delta_time())
	else:
		_speed = lerp(_speed, 0.0, lerp_factor * get_process_delta_time()) if do_lerp_smoothing else 0.0
		handle_grid_inputs()

func handle_grid_inputs():
	var direction = Vector2i.ZERO
	if abs(_input_dir.x) > DEADZONE:
		direction += Vector2i.RIGHT * int(sign(_input_dir.x))
	if abs(_input_dir.y) > DEADZONE:
		direction += Vector2i.DOWN * int(sign(_input_dir.y))
	
	if direction.length() > 1.0:
		# Prioritize the axis
		direction *= Vector2i.DOWN if (abs(_prev_direction.x) > DEADZONE) else Vector2i.RIGHT
	
	move_target(direction)

func handle_turns(direction: Vector2i):
	move_count += 1
	if move_count >= MOVES_PER_TURN:
		GameManager.next_turn()
		move_count = 0

func move_target(direction: Vector2i):
	if direction == Vector2i.ZERO or not map.is_ground_cell(_target_cell + direction):
		return
	
	_target_cell += direction
	_target_pos = get_target_position()

	player_moved.emit(direction)
	player_moved_to.emit(map.get_cell_from_coord(_target_cell))
	_prev_direction = direction

func on_game_end(_a):
	game_active = false

func get_target_position() -> Vector2:
	return map.cell_coord_to_pos(_target_cell)

func is_moving() -> bool:
	return (position - _target_pos).length() > MIN_DIST
