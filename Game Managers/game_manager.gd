class_name GameManager extends Node

# Parameters
@export var number_of_turns = 31

# Singleton instance
static var instance: GameManager

# Current Stats
static var current_turn: int = 0
var score: int = 0

# Signals for turn events
signal score_updated(score: int)
signal new_turn(turn: int)
	# UI Manager: update_day()
signal game_ended(score: int)


func _ready():
	if instance == null:
		instance = self


static func next_turn():
	if instance == null: return
	
	current_turn += 1
	instance.new_turn.emit(current_turn)
	print("Turn %d has started." % current_turn)
	
	if current_turn == instance.number_of_turns:
		instance.end_game()


static func get_score() -> int:
	return instance.score


static func add_score(value: int) -> void:
	instance.score += value
	print(instance.score_updated.get_connections())
	instance.score_updated.emit(instance.score)


func end_game():
	print("Turn ", instance.number_of_turns, " reached. Ending game...")
	print(instance.game_ended.get_connections())
	instance.game_ended.emit(score)
