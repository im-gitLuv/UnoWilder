# core/managers/chain_manager.gd
# Estado puro de The Chain. Fuente: Game Bible 3.8–3.9.
class_name ChainManager
extends RefCounted


var is_active: bool = false
var accumulated_draw_value: int = 0
var threatened_player_index: int = -1
var last_chain_player_index: int = -1
var response_history: Array[Dictionary] = []


## Inicia The Chain a partir de una carta Draw. `source_player_index` puede ser -1
## cuando The Wild Deck revela la carta inicial de la Ronda.
func start_chain(draw_card: CardData, initial_threatened_player_index: int, source_player_index: int = -1) -> bool:
	if draw_card == null or not draw_card.has_type(Globals.CardType.DRAW):
		push_error("The Chain solo puede iniciarse con una carta Draw.")
		return false

	is_active = true
	accumulated_draw_value = draw_card.draw_value
	threatened_player_index = initial_threatened_player_index
	last_chain_player_index = source_player_index
	response_history = [{
		"player_index": source_player_index,
		"card": draw_card,
		"action": "initial_draw"
	}]
	return true


## Desde la aclaración oficial, cualquier Draw puede responder y suma su propio
## valor, aunque sea inferior al valor acumulado de la Chain.
func can_respond_with_draw(card: CardData) -> bool:
	return is_active and card != null and card.has_type(Globals.CardType.DRAW)


func register_draw_response(player_index: int, card: CardData, next_threatened_player_index: int) -> bool:
	if not can_respond_with_draw(card):
		return false

	accumulated_draw_value += card.draw_value
	last_chain_player_index = player_index
	threatened_player_index = next_threatened_player_index
	response_history.append({
		"player_index": player_index,
		"card": card,
		"action": "draw_response"
	})
	return true


## Reverse no altera el robo acumulado: cambia la dirección y devuelve la amenaza
## al eslabón anterior. TurnManager calcula la dirección y el destino válidos.
func register_reverse_response(player_index: int, card: CardData, redirected_player_index: int) -> bool:
	if not is_active or card == null or redirected_player_index < 0:
		return false

	last_chain_player_index = player_index
	threatened_player_index = redirected_player_index
	response_history.append({
		"player_index": player_index,
		"card": card,
		"action": "reverse_response"
	})
	return true


## Cierra la Chain y devuelve el total que debe robar el jugador amenazado.
func resolve_chain() -> int:
	var resolved_value := accumulated_draw_value
	is_active = false
	accumulated_draw_value = 0
	threatened_player_index = -1
	last_chain_player_index = -1
	response_history.clear()
	return resolved_value
