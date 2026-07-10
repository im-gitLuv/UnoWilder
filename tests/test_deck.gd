# tests/test_deck.gd
# Valida el comportamiento básico de Deck.gd: la separación estricta entre
# Jugar / Descartar / Quemar / Remezclar (Game Bible 3.3).
extends GutTest

var deck: Deck


func before_each() -> void:
	deck = Deck.new()


func _make_dummy_card(id: String) -> CardData:
	var c := CardData.new()
	c.id = id
	c.types = [Globals.CardType.NUMBER]
	c.number_value = 1
	return c


func test_play_moves_card_to_discard_pile() -> void:
	var card := _make_dummy_card("c1")
	deck.play(card)
	assert_eq(deck.discard_pile_count(), 1)
	assert_eq(deck.peek_discard_top(), card)


func test_discard_moves_card_to_discard_pile() -> void:
	var card := _make_dummy_card("c1")
	deck.discard(card)
	assert_eq(deck.discard_pile_count(), 1)


func test_burn_moves_card_to_separate_burn_pile_not_discard() -> void:
	var card := _make_dummy_card("c1")
	deck.burn(card)
	assert_eq(deck.burn_pile_count(), 1)
	assert_eq(deck.discard_pile_count(), 0, "Una carta quemada NUNCA debe aparecer en el descarte (3.3)")


func test_burned_cards_never_return_via_reshuffle() -> void:
	var burned := _make_dummy_card("burned_1")
	var discarded := _make_dummy_card("discarded_1")
	deck.burn(burned)
	deck.discard(discarded)

	deck.reshuffle()

	assert_eq(deck.draw_pile_count(), 1, "Solo la carta descartada debe volver a la pila de robo")
	assert_true(deck.draw_pile.has(discarded))
	assert_false(deck.draw_pile.has(burned), "Una carta quemada nunca debe reaparecer en la pila de robo")


func test_reshuffle_returns_false_when_discard_pile_is_empty() -> void:
	var result := deck.reshuffle()
	assert_false(result, "No debe poder remezclar si no hay nada en el descarte")


func test_reshuffle_increments_counter() -> void:
	deck.discard(_make_dummy_card("c1"))
	deck.reshuffle()
	assert_eq(deck.reshuffles_this_round, 1)

	deck.discard(_make_dummy_card("c2"))
	deck.reshuffle()
	assert_eq(deck.reshuffles_this_round, 2, "Segunda remezcla en la misma ronda -> contador en 2 (dispara Primer Enojo en Cap. 2)")


func test_reset_round_reshuffle_count() -> void:
	deck.discard(_make_dummy_card("c1"))
	deck.reshuffle()
	deck.reset_round_reshuffle_count()
	assert_eq(deck.reshuffles_this_round, 0)


func test_draw_triggers_automatic_reshuffle_when_draw_pile_empty() -> void:
	# La pila de robo está vacía, pero hay 3 cartas en el descarte.
	deck.discard(_make_dummy_card("c1"))
	deck.discard(_make_dummy_card("c2"))
	deck.discard(_make_dummy_card("c3"))

	var drawn := deck.draw(2)

	assert_eq(drawn.size(), 2, "Debe poder robar 2 cartas remezclando automáticamente (3.6)")
	assert_eq(deck.reshuffles_this_round, 1)


func test_draw_returns_fewer_cards_if_deck_truly_exhausted() -> void:
	# Sin nada en robo ni en descarte: no hay de dónde sacar cartas.
	var drawn := deck.draw(3)
	assert_eq(drawn.size(), 0)


func test_burn_multiple() -> void:
	var cards: Array[CardData] = [_make_dummy_card("a"), _make_dummy_card("b"), _make_dummy_card("c")]
	deck.burn_multiple(cards)
	assert_eq(deck.burn_pile_count(), 3)
