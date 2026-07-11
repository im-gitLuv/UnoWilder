# tests/test_chain_manager.gd
# Valida The Chain según Game Bible 3.8–3.9.
extends GutTest

var chain: ChainManager


func before_each() -> void:
	chain = ChainManager.new()


func _make_draw(value: int) -> CardData:
	var card := CardData.new()
	card.types = [Globals.CardType.DRAW]
	card.draw_value = value
	return card


func _make_reverse() -> CardData:
	var card := CardData.new()
	card.types = [Globals.CardType.COLOR_EFFECT]
	card.color_effect_name = "reverse"
	return card


func test_any_draw_can_continue_the_chain_and_adds_its_value() -> void:
	chain.start_chain(_make_draw(6), 0, 2)
	assert_true(chain.can_respond_with_draw(_make_draw(1)))
	chain.register_draw_response(0, _make_draw(1), 1)
	assert_eq(chain.accumulated_draw_value, 7)
	assert_eq(chain.threatened_player_index, 1)


func test_reverse_redirects_without_changing_accumulated_draw_value() -> void:
	chain.start_chain(_make_draw(2), 0, 2)
	chain.register_draw_response(0, _make_draw(1), 1)
	chain.register_reverse_response(1, _make_reverse(), 0)
	assert_eq(chain.accumulated_draw_value, 3)
	assert_eq(chain.threatened_player_index, 0)
	assert_eq(chain.response_history.size(), 3)


func test_resolve_chain_returns_total_and_resets_state() -> void:
	chain.start_chain(_make_draw(4), 0, 1)
	chain.register_draw_response(0, _make_draw(2), 1)
	assert_eq(chain.resolve_chain(), 6)
	assert_false(chain.is_active)
	assert_eq(chain.accumulated_draw_value, 0)
	assert_eq(chain.threatened_player_index, -1)
