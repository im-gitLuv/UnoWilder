# tests/test_game_state.gd
# Valida la jerarquía Partida → Ronda → Vuelta del Capítulo 2.
extends GutTest

var state: Node


func _make_players(count: int) -> Array[PlayerState]:
	var players: Array[PlayerState] = []
	for index in range(count):
		var player := PlayerState.new()
		player.player_name = "P%d" % index
		players.append(player)
	return players


func before_each() -> void:
	state = load("res://autoloads/game_state.gd").new()


func after_each() -> void:
	state.free()


func test_match_requires_two_to_eight_players() -> void:
	assert_false(state.start_match(_make_players(1), Deck.new()))
	assert_false(state.start_match(_make_players(9), Deck.new()))
	assert_true(state.start_match(_make_players(2), Deck.new()))


func test_start_round_resets_round_state_but_keeps_first_enojo_of_match() -> void:
	state.start_match(_make_players(2), Deck.new())
	state.first_enojo_occurred_this_match = true
	state.first_lap_completed_this_round = true
	state.eliminate_player(1)
	state.start_round()
	assert_eq(state.round_number, 1)
	assert_false(state.first_lap_completed_this_round)
	assert_true(state.first_enojo_occurred_this_match)
	assert_eq(state.get_active_player_indices().size(), 2)


func test_first_lap_can_only_complete_once() -> void:
	state.start_match(_make_players(2), Deck.new())
	state.start_round()
	state.start_lap(0)
	state.complete_first_lap()
	state.complete_first_lap()
	assert_true(state.first_lap_completed_this_round)
