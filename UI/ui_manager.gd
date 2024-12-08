class_name UIManager extends Control

# Singleton instance
static var instance: UIManager

# UI Elements
@export_category("General UI Elements")
@export var harvested_text: Label
@export var day_display: Label

@export_category("Current Cell Elements")
@export var current_cell: Panel
@export var current_cell_plant: Label
@export var current_cell_sun: Label
@export var current_cell_water: Label

@export_category("GameOver Elements")
@export var game_over_panel: Panel
@export var score_display: Label
@export var results_display: Label

const WIN_CONDITION = 10
var harvested: int = 0
var current_day: int = 0
var current_plant: String
var current_sun: float
var current_water: float

func _ready():
	if instance == null:
		instance = self

# Call this to update the score UI
func update_score(new_score: int) -> void:
	harvested = new_score
	harvested_text.text = "Harvested: %d" % harvested

func update_day(day: int) -> void:
	current_day = day
	day_display.text = "Day: %d" % current_day

func update_current_cell(cell: Cell) -> void:
	update_sun(cell.get_sun())
	update_water(cell.get_water())
	update_current_plant(cell.get_plant())

func update_current_plant(plant: Plant) -> void:
	if plant == null:
		current_plant = "none"
	else:
		current_plant = plant.get_name()
	current_cell_plant.text = "Plant: %s" % current_plant

func update_sun(sun_lvl: float) -> void:
	current_sun = round(sun_lvl * 100) / 100.0
	current_cell_sun.text = "Sun: LVL %.2f" % current_sun

func update_water(water_lvl: float) -> void:
	current_water = round(water_lvl * 100) / 100.0
	current_cell_water.text = "Water: LVL %.2f" % current_water

func enable_game_over_ui(score: int) -> void:
	print("FICL")
	current_cell.hide()
	game_over_panel.show()
	score_display.text = "You harvested %d crops!" % score
	if score > WIN_CONDITION:
		score_display.text = "A Great Harvest!! You Won !!!"
	else:
		results_display.text = "A Poor Harvest. You lost !!!"

func _process(delta: float) -> void:
	if (Input.is_physical_key_pressed(KEY_SPACE)):
		enable_game_over_ui(100)
