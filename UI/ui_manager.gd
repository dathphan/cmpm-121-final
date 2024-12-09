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

@export_category("Save Load Elements")
@export var save_load_panel: Panel

const WIN_CONDITION = 10
var harvested: int = 0
var current_day: int = 0
var current_plant: String
var current_sun: float
var current_water: float

const LANGUAGES = ["en", "es", "fr", "ar"]
var index = 0

func _ready():
	if instance == null:
		instance = self
	
	update_locale()

# Call this to update the score UI
func update_score(new_score: int) -> void:
	harvested = new_score
	harvested_text.text = tr("HARVESTED") + ": %d" % harvested

func update_day(day: int) -> void:
	current_day = day
	day_display.text = tr("DAY") + ": %d" % current_day

func update_current_cell(cell: Cell) -> void:
	update_sun(cell.get_sun())
	update_water(cell.get_water())
	update_current_plant(cell.get_plant())

func update_current_plant(plant: Plant) -> void:
	if plant == null:
		current_plant = "---"
	else:
		current_plant = tr(plant.plant_data.plant_name)
	current_cell_plant.text = tr("PLANT") + ": %s" % current_plant

func update_sun(sun_lvl: float) -> void:
	current_sun = round(sun_lvl * 100) / 100.0
	current_cell_sun.text = tr("SUN LEVEL") + ": %.2f" % current_sun

func update_water(water_lvl: float) -> void:
	current_water = round(water_lvl * 100) / 100.0
	current_cell_water.text = tr("WATER LEVEL") + ": %.2f" % current_water

func enable_game_over_ui(score: int) -> void:
	current_cell.hide()
	game_over_panel.show()
	score_display.text = "HARVESTED: %d" % score
	if score > WIN_CONDITION:
		results_display.text = tr("WIN")
	else:
		results_display.text = tr("LOSE")


func cycle_language() -> void:
	index = (index + 1) % 4
	TranslationServer.set_locale(LANGUAGES[index])
	update_locale()


func update_locale() -> void:
	update_score(GameManager.get_score())
	update_day(GameManager.instance.current_turn)
	update_current_cell(GameManager.instance.map.get_cell_from_coord(Player.instance._target_cell))


func _process(delta: float) -> void:
	if (Input.is_physical_key_pressed(KEY_ESCAPE)):
		toggle_menu()


func toggle_menu() -> void:
	if save_load_panel.visible:
		save_load_panel.hide()
	else:
		save_load_panel.show()
