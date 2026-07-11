# tests/test_player_state.gd
# Valida PlayerState.gd: manejo de mano, límite de 25+ cartas (Game Bible 3.6),
# y suma de puntaje de mano (3.12).
extends GutTest

var player: PlayerState


func before_each() -> void:
	player = PlayerState.new()
	player.player_name = "TestPlayer"


func _make_number_card(value: int) -> CardData:
	var c := CardData.new()
	c.types = [Globals.CardType.NUMBER]
	c.number_value = value
	return c


func test_add_cards_increases_hand_size() -> void:
	player.add_cards([_make_number_card(1), _make_number_card(2)])
	assert_eq(player.hand_size(), 2)


func test_remove_card_removes_from_hand() -> void:
	var card := _make_number_card(5)
	player.add_cards([card])
	var removed := player.remove_card(card)
	assert_eq(removed, card)
	assert_eq(player.hand_size(), 0)


func test_remove_card_not_in_hand_returns_null() -> void:
	var card := _make_number_card(5)
	var result := player.remove_card(card)
	assert_null(result)


func test_has_reached_hand_limit_false_under_25() -> void:
	for i in range(24):
		player.add_cards([_make_number_card(1)])
	assert_false(player.has_reached_hand_limit())


func test_has_reached_hand_limit_true_at_25() -> void:
	for i in range(25):
		player.add_cards([_make_number_card(1)])
	assert_true(player.has_reached_hand_limit(), "25 cartas debe activar el límite (3.6)")


func test_get_hand_point_value_sums_all_cards() -> void:
	player.add_cards([_make_number_card(0), _make_number_card(5), _make_number_card(9)])
	# 0 -> 10 pts, 5 -> 5 pts, 9 -> 9 pts = 24 total
	assert_eq(player.get_hand_point_value(), 24)


func test_reset_for_new_round_resets_burn_flag() -> void:
	player.has_used_initial_burn_this_round = true
	player.reset_for_new_round()
	assert_false(player.has_used_initial_burn_this_round)


func test_release_hand_returns_cards_and_clears_hand() -> void:
	var first_card := _make_number_card(1)
	var second_card := _make_number_card(2)
	player.add_cards([first_card, second_card])
	var released := player.release_hand()
	assert_eq(released.size(), 2)
	assert_true(released.has(first_card))
	assert_true(released.has(second_card))
	assert_eq(player.hand_size(), 0)


func test_default_status_is_active() -> void:
	assert_eq(player.status, PlayerState.Status.ACTIVE)
