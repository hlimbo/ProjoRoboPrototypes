extends Node

signal on_setup_test

var modifier_data_container: StatusEffectDataContainer

func setup_test():
	modifier_data_container.load_modifiers()

func load_modifiers_test():
	var buff_count: int = modifier_data_container.buffs.size()
	var debuff_count: int = modifier_data_container.debuffs.size()
	
	assert(buff_count > 0)
	assert(debuff_count > 0)

func get_valid_buff_test():
	var modifier_data: StatusEffect = modifier_data_container.get_buff("Thorned Armor")
	assert(is_instance_valid(modifier_data))
	assert(modifier_data.name == "Thorned Armor")
	assert(modifier_data.description == "Deals damage back to opposing bot that attacks with a physical move")
	assert(modifier_data.duration_type == "seconds")
	assert(modifier_data.duration == 3)
	
func get_invalid_buff_test():
	var modifier_data: StatusEffect = modifier_data_container.get_buff("No Name")
	assert(is_instance_valid(modifier_data) == false)
	
func get_valid_debuff_test():
	var modifier_data: StatusEffect = modifier_data_container.get_debuff("Slow")
	assert(is_instance_valid(modifier_data))
	assert(modifier_data.name == "Slow")
	assert(modifier_data.description == "slows down the bot's speed on the timeline")
	assert(modifier_data.duration_type == "seconds")
	assert(modifier_data.duration == 3)
	
func get_invalid_debuff_test():
	var modifier_data: StatusEffect = modifier_data_container.get_debuff("No Name")
	assert(is_instance_valid(modifier_data) == false)

func run_tests():
	var tests: Array = [
		load_modifiers_test,
		get_valid_buff_test,
		get_invalid_buff_test,
		get_valid_debuff_test,
		get_invalid_debuff_test,
	]
	
	for test in tests:
		on_setup_test.emit()
		test.call()

func _ready():
	modifier_data_container = StatusEffectDataContainer.new()
	
	on_setup_test.connect(setup_test)
	run_tests()
	print_rich("[color=green]All ModifierDataContainer Tests passed![/color]")
