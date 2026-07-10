# tests/test_card_data.gd
# Valida CardData.get_point_value() contra la tabla oficial de Game Bible 3.12,
# incluyendo los casos multi-tipo (Wild Shift, Wild Draw 4, Wild Draw 12, Wild Reverse).
extends GutTest


func test_number_zero_is_ten_points() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.NUMBER]
	card.number_value = 0
	assert_eq(card.get_point_value(), 10, "Número 0 debe valer 10 pts (3.12)")


func test_number_five_is_five_points() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.NUMBER]
	card.number_value = 5
	assert_eq(card.get_point_value(), 5, "Número 5 debe valer 5 pts (su propio número)")


func test_number_nine_is_nine_points() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.NUMBER]
	card.number_value = 9
	assert_eq(card.get_point_value(), 9, "Número 9 debe valer 9 pts")


func test_color_effect_is_twenty_points() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.COLOR_EFFECT]
	card.color_effect_name = "skip"
	assert_eq(card.get_point_value(), 20, "Skip normal debe valer 20 pts (3.12)")


func test_draw_2_normal_is_four_points() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.DRAW]
	card.draw_value = 2
	assert_eq(card.get_point_value(), 4, "Draw 2 normal debe valer 2*2=4 pts (3.12)")


func test_wild_shift_is_fifty_points() -> void:
	# Wild Shift (Game Bible 5.3.1): solo tipo WILD, sin extras. Caso base del sistema.
	var card := CardData.new()
	card.types = [Globals.CardType.WILD]
	assert_eq(card.get_point_value(), 50, "Wild Shift debe valer exactamente 50 pts (5.3.1)")


func test_wild_draw_4_is_fifty_eight_points() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.WILD, Globals.CardType.DRAW]
	card.draw_value = 4
	assert_eq(card.get_point_value(), 58, "Wild Draw 4 = 50 + (4*2) = 58 pts (3.12)")


func test_wild_draw_12_is_seventy_four_points() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.WILD, Globals.CardType.DRAW]
	card.draw_value = 12
	assert_eq(card.get_point_value(), 74, "Wild Draw 12 = 50 + (12*2) = 74 pts (3.12)")


func test_wild_reverse_is_seventy_points() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.WILD, Globals.CardType.COLOR_EFFECT]
	card.color_effect_name = "reverse"
	assert_eq(card.get_point_value(), 70, "Wild Reverse = 50 + 20 = 70 pts (3.12)")


func test_wild_skip_is_seventy_points() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.WILD, Globals.CardType.COLOR_EFFECT]
	card.color_effect_name = "skip"
	assert_eq(card.get_point_value(), 70, "Wild Skip = 50 + 20 = 70 pts (3.12)")


func test_is_wild_true_for_wild_card() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.WILD]
	assert_true(card.is_wild(), "is_wild() debe ser true para una carta con tipo WILD")


func test_is_wild_false_for_number_card() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.NUMBER]
	card.number_value = 3
	assert_false(card.is_wild(), "is_wild() debe ser false para una carta numérica normal")


func test_has_type_checks_membership() -> void:
	var card := CardData.new()
	card.types = [Globals.CardType.WILD, Globals.CardType.DRAW]
	assert_true(card.has_type(Globals.CardType.DRAW))
	assert_false(card.has_type(Globals.CardType.COLOR_EFFECT))
