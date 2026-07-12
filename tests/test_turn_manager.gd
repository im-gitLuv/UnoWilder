# tests/test_turn_manager.gd
# Pruebas end-to-end del flujo de Turnos del Capítulo 2.
extends GutTest

var state: Node
var deck: Deck
var manager: TurnManager


func before_each() -> void:
	state = load("res://autoloads/game_state.gd").new()
	deck = Deck.new()
	var players: Array[PlayerState] = []
	for index in range(3):
		var player := PlayerState.new()
		player.player_name = "P%d" % index
		players.append(player)
	state.start_match(players, deck)
	manager = TurnManager.new(state)


func after_each() -> void:
	state.free()


func _make_number(color: Globals.CardColor, value: int) -> CardData:
	var card := CardData.new()
	card.color = color
	card.types = [Globals.CardType.NUMBER]
	card.number_value = value
	return card


func _make_draw(color: Globals.CardColor, value: int) -> CardData:
	var card := CardData.new()
	card.color = color
	card.types = [Globals.CardType.DRAW]
	card.draw_value = value
	return card


func _make_effect(color: Globals.CardColor, effect_name: String) -> CardData:
	var card := CardData.new()
	card.color = color
	card.types = [Globals.CardType.COLOR_EFFECT]
	card.color_effect_name = effect_name
	return card


func _start_manual_turn() -> void:
	state.start_round()
	state.start_lap(0)
	var top := _make_number(Globals.CardColor.RED, 5)
	deck.play(top)
	state.set_active_color(Globals.CardColor.RED)


func _give_card(player_index: int, card: CardData) -> void:
	state.players[player_index].hand.append(card)


func test_round_deals_seven_cards_and_reveals_opening_card() -> void:
	for value in range(24):
		deck.draw_pile.append(_make_number(Globals.CardColor.RED, value % 10))
	assert_true(manager.start_round(0))
	assert_true(manager.begin_turn_phase_after_wild_selection())
	for player in state.players:
		assert_eq(player.hand_size(), 7)
	assert_eq(deck.discard_pile_count(), 1)
	assert_eq(state.phase, state.Phase.TURN)


func test_initial_burn_replaces_x_cards_with_x_plus_one() -> void:
	for value in range(24):
		deck.draw_pile.append(_make_number(Globals.CardColor.RED, value % 10))
	manager.start_round(0)
	manager.begin_turn_phase_after_wild_selection()
	var card_to_burn: CardData = state.players[0].hand[0]
	assert_true(manager.use_initial_burn(0, [card_to_burn]))
	assert_eq(state.players[0].hand_size(), 8)
	assert_eq(deck.burn_pile_count(), 1)
	assert_false(manager.use_initial_burn(0, [state.players[0].hand[0]]))


func test_player_skipped_in_first_lap_loses_initial_burn_window() -> void:
	_start_manual_turn()
	var skip := _make_effect(Globals.CardColor.RED, "skip")
	var final_card := _make_number(Globals.CardColor.RED, 6)
	var missed_burn_card := _make_number(Globals.CardColor.RED, 2)
	_give_card(0, skip)
	_give_card(0, _make_number(Globals.CardColor.RED, 1))
	_give_card(1, missed_burn_card)
	_give_card(2, final_card)
	_give_card(2, _make_number(Globals.CardColor.RED, 3))
	assert_true(manager.play_card(0, skip))
	assert_eq(state.current_player_index, 2)
	assert_true(manager.play_card(2, final_card))
	assert_true(state.first_lap_completed_this_round)
	assert_false(manager.use_initial_burn(1, [missed_burn_card]))


func test_chain_accepts_any_draw_and_reverse_keeps_it_active() -> void:
	_start_manual_turn()
	var first_draw := _make_draw(Globals.CardColor.RED, 2)
	var lower_draw := _make_draw(Globals.CardColor.BLUE, 1)
	var reverse := _make_effect(Globals.CardColor.BLUE, "reverse")
	_give_card(0, first_draw)
	_give_card(0, _make_number(Globals.CardColor.RED, 4))
	_give_card(1, lower_draw)
	_give_card(2, reverse)
	deck.draw_pile.append(_make_number(Globals.CardColor.GREEN, 1))
	deck.draw_pile.append(_make_number(Globals.CardColor.GREEN, 2))
	deck.draw_pile.append(_make_number(Globals.CardColor.GREEN, 3))

	assert_true(manager.play_card(0, first_draw))
	assert_eq(state.phase, state.Phase.CHAIN)
	assert_true(manager.respond_to_chain(1, lower_draw))
	assert_eq(manager.chain_manager.accumulated_draw_value, 3)
	assert_true(manager.respond_to_chain(2, reverse))
	assert_eq(manager.chain_manager.threatened_player_index, 1)
	assert_eq(state.direction, -1)
	assert_true(manager.resolve_chain_without_response(1))
	assert_eq(state.players[1].hand_size(), 3)
	assert_eq(state.phase, state.Phase.TURN)


func test_first_enojo_burns_conventional_rounded_third_of_discard() -> void:
	_start_manual_turn()
	deck.discard_pile.clear()
	for value in range(5):
		deck.discard(_make_number(Globals.CardColor.RED, value))
	deck.reshuffles_this_round = 1
	assert_true(manager.resolve_turn_without_playable_card(0))
	assert_eq(deck.burn_pile_count(), 2)
	assert_true(state.first_enojo_occurred_this_match)
	assert_eq(state.phase, state.Phase.ROUND_ENDED)


func test_second_enojo_burns_entire_discard_and_ends_match() -> void:
	_start_manual_turn()
	deck.discard_pile.clear()
	for value in range(4):
		deck.discard(_make_number(Globals.CardColor.RED, value))
	deck.reshuffles_this_round = 1
	state.first_enojo_occurred_this_match = true
	assert_true(manager.resolve_turn_without_playable_card(0))
	assert_eq(deck.burn_pile_count(), 4)
	assert_eq(state.phase, state.Phase.MATCH_ENDED)


func test_hand_limit_eliminates_player_and_burns_their_hand() -> void:
	_start_manual_turn()
	for value in range(24):
		_give_card(0, _make_number(Globals.CardColor.BLUE, value % 10))
	deck.draw_pile.append(_make_number(Globals.CardColor.BLUE, 9))
	manager.resolve_turn_without_playable_card(0)
	assert_eq(state.players[0].status, PlayerState.Status.ELIMINATED)
	assert_eq(deck.burn_pile_count(), 25)
	assert_eq(state.get_active_player_indices().size(), 2)


func test_round_end_recovers_unburned_cards_for_multiple_rounds() -> void:
    # Ronda 1
	_start_manual_turn()
	var winning_card1 := _make_number(Globals.CardColor.RED, 7)
	var opponent_card1 := _make_number(Globals.CardColor.BLUE, 5)
	var burned_card := _make_number(Globals.CardColor.GREEN, 9)

	_give_card(0, winning_card1)
	_give_card(1, opponent_card1)
	_give_card(1, burned_card)

	assert_true(manager.play_card(0, winning_card1))
	deck.burn(burned_card)
	state.end_round(0)

	# Ronda 2
	assert_true(state.start_round())

	# Preparación manual mínima para el test (sin wild selection)
	state._set_phase(state.Phase.TURN)
	assert_true(state.start_lap(0))

	# Poner una carta en descarte para que sea jugable
	var top_card := _make_number(Globals.CardColor.RED, 5)
	deck.play(top_card)
	state.set_active_color(Globals.CardColor.RED)

	var winning_card2 := _make_number(Globals.CardColor.RED, 7)  # misma color que top
	_give_card(0, winning_card2)

	assert_true(manager.play_card(0, winning_card2), "Debe poder jugar en ronda 2")

	state.end_round(0)
	assert_eq(deck.burn_pile_count(), 1)


func test_second_enojo_ends_full_match() -> void:
	_start_manual_turn()
	state.first_enojo_occurred_this_match = true
	deck.discard_pile.clear()
	for i in range(5):
		deck.discard(_make_number(Globals.CardColor.RED, i))
	deck.reshuffles_this_round = 1

	var result = manager.resolve_turn_without_playable_card(0)
	assert_true(result)
	assert_eq(state.phase, state.Phase.MATCH_ENDED)
	assert_eq(deck.burn_pile_count(), 5)  # todo quemado