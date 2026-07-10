# tests/test_standard_deck_generator.gd
# Valida que el generador produzca exactamente el mazo estándar descrito en
# Game Bible 4.1-4.3: 80 numéricas + 48 de efecto = 128 cartas, con los
# desgloses exactos por color/tipo/copias.
extends GutTest

var generator: StandardDeckGenerator


func before_each() -> void:
	generator = StandardDeckGenerator.new()


func test_total_deck_size_is_128() -> void:
	var deck := generator.generate()
	assert_eq(deck.size(), 128, "El mazo estándar debe tener exactamente 128 cartas (4.3)")


func test_number_cards_total_is_80() -> void:
	var deck := generator.generate()
	var number_cards := deck.filter(func(c): return c.has_type(Globals.CardType.NUMBER))
	assert_eq(number_cards.size(), 80, "10 números x 2 copias x 4 colores = 80 (4.1)")


func test_color_effect_and_draw_cards_total_is_48() -> void:
	var deck := generator.generate()
	var effect_cards := deck.filter(func(c):
		return c.has_type(Globals.CardType.COLOR_EFFECT) or c.has_type(Globals.CardType.DRAW)
	)
	assert_eq(effect_cards.size(), 48, "6 tipos x 2 copias x 4 colores = 48 (4.2)")


func test_no_card_has_wild_type_in_standard_deck() -> void:
	# El mazo estándar NO incluye Wilds; esas se insertan aparte según selección
	# pre-ronda (Game Bible 3.5), fuera del alcance de este generador.
	var deck := generator.generate()
	var wild_cards := deck.filter(func(c): return c.is_wild())
	assert_eq(wild_cards.size(), 0, "El mazo estándar base no debe contener Wild Cards")


func test_each_number_zero_to_nine_has_two_copies_per_color() -> void:
	var deck := generator.generate()

	for color in StandardDeckGenerator.STANDARD_COLORS:
		for number in range(0, 10):
			var matches := deck.filter(func(c):
				return c.has_type(Globals.CardType.NUMBER) \
					and c.color == color \
					and c.number_value == number
			)
			assert_eq(matches.size(), 2,
				"Color %s, número %d debe tener 2 copias" % [Globals.CardColor.keys()[color], number])


func test_each_color_has_two_skips_two_reverses_two_jumps_two_exchanges() -> void:
	var deck := generator.generate()

	for color in StandardDeckGenerator.STANDARD_COLORS:
		for effect_name in ["skip", "reverse", "jump", "exchange"]:
			var matches := deck.filter(func(c):
				return c.has_type(Globals.CardType.COLOR_EFFECT) \
					and c.color == color \
					and c.color_effect_name == effect_name
			)
			assert_eq(matches.size(), 2,
				"Color %s, efecto %s debe tener 2 copias" % [Globals.CardColor.keys()[color], effect_name])


func test_each_color_has_two_draw_1_and_two_draw_2() -> void:
	var deck := generator.generate()

	for color in StandardDeckGenerator.STANDARD_COLORS:
		for dv in [1, 2]:
			var matches := deck.filter(func(c):
				return c.has_type(Globals.CardType.DRAW) \
					and c.color == color \
					and c.draw_value == dv
			)
			assert_eq(matches.size(), 2,
				"Color %s, Draw %d debe tener 2 copias" % [Globals.CardColor.keys()[color], dv])


func test_all_generated_cards_have_unique_ids() -> void:
	var deck := generator.generate()
	var ids := {}
	for c in deck:
		assert_false(ids.has(c.id), "El id %s no debería repetirse" % c.id)
		ids[c.id] = true
	assert_eq(ids.size(), 128, "Deben existir 128 ids únicos")
