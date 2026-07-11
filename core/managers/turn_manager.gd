# core/managers/turn_manager.gd
# Orquesta las reglas de Turno sin depender de escenas.
# Fuente: Game Bible 3.2–3.6, 3.8–3.9; Roadmap, Capítulo 2.
class_name TurnManager
extends RefCounted


const INITIAL_HAND_SIZE = 7  # Game Bible 3.4
const STANDARD_COLORS: Array[Globals.CardColor] = [
	Globals.CardColor.RED,
	Globals.CardColor.BLUE,
	Globals.CardColor.YELLOW,
	Globals.CardColor.GREEN,
]

var game_state: Node
var chain_manager: ChainManager
var _pending_first_player_index: int = -1


func _init(state: Node, chain: ChainManager = null) -> void:
	game_state = state
	chain_manager = chain if chain != null else ChainManager.new()


## Abre la Ronda, reúne todas las cartas no quemadas y deja el juego en la fase
## de selección del Wild Codex. El reparto ocurre solo después de esa selección.
func start_round(first_player_index: int) -> bool:
	if not game_state.start_round() or not game_state.is_player_active(first_player_index):
		return false

	_pending_first_player_index = first_player_index
	var persistent_cards: Array[CardData] = game_state.deck.take_all_unburned_cards()

	for player in game_state.players:
		persistent_cards.append_array(player.release_hand())

	game_state.deck.add_to_draw_pile(persistent_cards)
	return true


## Finaliza la preparación que sigue a la selección del Wild Codex: baraja, reparte
## 7 cartas, revela la primera carta y aplica su efecto contra el primer jugador.
func begin_turn_phase_after_wild_selection() -> bool:
	if _pending_first_player_index < 0 or game_state.phase != game_state.Phase.WILD_SELECTION:
		return false

	game_state.deck.shuffle()
	for player_index in game_state.get_active_player_indices():
		for card_number in range(INITIAL_HAND_SIZE):
			if _draw_one_to_player(player_index) == null:
				return false

	if not game_state.start_lap(_pending_first_player_index):
		return false

	_pending_first_player_index = -1
	return _reveal_opening_card()


## Una carta es jugable por color activo, número, efecto equivalente o por ser Wild.
func is_card_playable(card: CardData) -> bool:
	if card == null or card.is_wild():
		return card != null

	var discard_top: CardData = game_state.deck.peek_discard_top()
	if discard_top == null:
		return true
	if card.color == game_state.active_color:
		return true
	if card.has_type(Globals.CardType.NUMBER) and discard_top.has_type(Globals.CardType.NUMBER):
		return card.number_value == discard_top.number_value
	if card.has_type(Globals.CardType.DRAW) and discard_top.has_type(Globals.CardType.DRAW):
		return true
	if card.has_type(Globals.CardType.COLOR_EFFECT) and discard_top.has_type(Globals.CardType.COLOR_EFFECT):
		return card.color_effect_name == discard_top.color_effect_name
	return false


## Jugar normal. Las Wilds deben indicar su color elegido; las demás cartas actualizan
## el color activo a su propio color antes de resolver su efecto.
func play_card(player_index: int, card: CardData, declared_wild_color: Globals.CardColor = Globals.CardColor.WILD) -> bool:
	if game_state.phase != game_state.Phase.TURN or game_state.current_player_index != player_index:
		return false
	if not game_state.is_player_active(player_index) or not game_state.players[player_index].hand.has(card):
		return false
	if not is_card_playable(card):
		return false
	if card.is_wild() and not STANDARD_COLORS.has(declared_wild_color):
		return false

	game_state.players[player_index].remove_card(card)
	game_state.deck.play(card)
	game_state.set_active_color(declared_wild_color if card.is_wild() else card.color)

	if game_state.players[player_index].hand.is_empty():
		_end_round_with_winner(player_index)
		return true

	if card.has_type(Globals.CardType.DRAW):
		var threatened := _next_active_player_index(player_index)
		chain_manager.start_chain(card, threatened, player_index)
		game_state.current_player_index = threatened
		game_state._set_phase(game_state.Phase.CHAIN)
		return true

	if card.has_type(Globals.CardType.COLOR_EFFECT):
		match card.color_effect_name:
			"skip":
				_advance_turn(2)
			"reverse":
				game_state.direction *= -1
				_advance_turn()
			_:
				_advance_turn()
		return true

	_advance_turn()
	return true


## Si un jugador no posee carta jugable, roba hasta obtener una y la juega de inmediato.
func resolve_turn_without_playable_card(player_index: int) -> bool:
	if game_state.phase != game_state.Phase.TURN or game_state.current_player_index != player_index:
		return false

	while game_state.phase == game_state.Phase.TURN:
		var drawn := _draw_one_to_player(player_index)
		if drawn == null:
			return game_state.phase == game_state.Phase.ROUND_ENDED or game_state.phase == game_state.Phase.MATCH_ENDED
		if is_card_playable(drawn):
			if drawn.is_wild():
				return play_card(player_index, drawn, STANDARD_COLORS[0] as Globals.CardColor)
			return play_card(player_index, drawn)

	return false


## Quema inicial: disponible una vez por Ronda, solo durante la primera Vuelta.
func use_initial_burn(player_index: int, cards: Array[CardData]) -> bool:
	if not game_state.is_player_active(player_index) or game_state.first_lap_completed_this_round:
		return false
	var player: PlayerState = game_state.players[player_index]
	if player.has_used_initial_burn_this_round or cards.is_empty():
		return false

	for card in cards:
		if not player.hand.has(card):
			return false

	for card in cards:
		player.remove_card(card)
		game_state.deck.burn(card)
	player.has_used_initial_burn_this_round = true

	for draw_number in range(cards.size() + 1):
		if _draw_one_to_player(player_index) == null:
			return false
	return true


## El jugador amenazado puede continuar The Chain con cualquier Draw o redirigirla
## con un Reverse del color activo. El Reverse nunca suma valor de robo.
func respond_to_chain(player_index: int, card: CardData, declared_wild_color: Globals.CardColor = Globals.CardColor.WILD) -> bool:
	if game_state.phase != game_state.Phase.CHAIN or player_index != chain_manager.threatened_player_index:
		return false
	if not game_state.players[player_index].hand.has(card):
		return false

	if chain_manager.can_respond_with_draw(card):
		game_state.players[player_index].remove_card(card)
		game_state.deck.play(card)
		game_state.set_active_color(declared_wild_color if card.is_wild() else card.color)
		var next_player := _next_active_player_index(player_index)
		chain_manager.register_draw_response(player_index, card, next_player)
		game_state.current_player_index = next_player
		return true

	if _is_valid_chain_reverse(card, declared_wild_color):
		var redirected_player := chain_manager.last_chain_player_index
		if redirected_player < 0:
			return false
		game_state.players[player_index].remove_card(card)
		game_state.deck.play(card)
		game_state.set_active_color(declared_wild_color if card.is_wild() else card.color)
		game_state.direction *= -1
		chain_manager.register_reverse_response(player_index, card, redirected_player)
		game_state.current_player_index = redirected_player
		return true

	return false


## El jugador que no responde recibe todo el robo y pierde su Turno.
func resolve_chain_without_response(player_index: int) -> bool:
	if game_state.phase != game_state.Phase.CHAIN or player_index != chain_manager.threatened_player_index:
		return false

	var cards_to_draw := chain_manager.resolve_chain()
	for draw_number in range(cards_to_draw):
		if _draw_one_to_player(player_index) == null:
			return game_state.phase == game_state.Phase.ROUND_ENDED or game_state.phase == game_state.Phase.MATCH_ENDED

	if game_state.phase != game_state.Phase.CHAIN:
		return true
	game_state._set_phase(game_state.Phase.TURN)
	game_state.current_player_index = player_index
	_advance_turn()
	return true


func _reveal_opening_card() -> bool:
	var opening_card := _take_draw_card_or_resolve_enojo()
	if opening_card == null:
		return false

	game_state.deck.play(opening_card)
	game_state.set_active_color(_random_standard_color() if opening_card.is_wild() else opening_card.color)

	if opening_card.has_type(Globals.CardType.DRAW):
		chain_manager.start_chain(opening_card, game_state.current_player_index)
		game_state._set_phase(game_state.Phase.CHAIN)
		return true
	if opening_card.has_type(Globals.CardType.COLOR_EFFECT):
		match opening_card.color_effect_name:
			"skip":
				_advance_turn()
			"reverse":
				game_state.direction *= -1
	return true


func _draw_one_to_player(player_index: int) -> CardData:
	var card := _take_draw_card_or_resolve_enojo()
	if card == null:
		return null
	game_state.players[player_index].add_cards([card] as Array[CardData])
	if game_state.players[player_index].has_reached_hand_limit():
		_resolve_hand_limit(player_index)
		return null
	return card


func _take_draw_card_or_resolve_enojo() -> CardData:
	if game_state.deck.is_draw_pile_empty():
		if game_state.deck.reshuffles_this_round == 0:
			if not game_state.deck.reshuffle():
				return null
		else:
			_resolve_double_reshuffle()
			return null
	return game_state.deck.draw_one_without_reshuffle()


func _resolve_double_reshuffle() -> void:
	var is_second_enojo: bool = game_state.first_enojo_occurred_this_match
	var cards_to_burn: int = game_state.deck.discard_pile_count()
	if not is_second_enojo:
		cards_to_burn = int(floor(float(cards_to_burn) / 3.0 + 0.5))
	game_state.deck.burn_random_discard_cards(cards_to_burn)

	var winner_index := _get_lowest_hand_player_index()
	if winner_index >= 0:
		_end_round_with_winner(winner_index)

	if is_second_enojo:
		var match_winner_index := _get_highest_score_player_index()
		if match_winner_index >= 0:
			game_state.end_match(game_state.players[match_winner_index])
	else:
		game_state.first_enojo_occurred_this_match = true


func _resolve_hand_limit(player_index: int) -> void:
	var player: PlayerState = game_state.players[player_index]
	game_state.deck.burn_multiple(player.release_hand())
	game_state.eliminate_player(player_index)

	var active_indices: Array[int] = game_state.get_active_player_indices()
	if active_indices.size() == 1:
		_end_round_with_winner(active_indices[0])
	elif game_state.current_player_index == player_index:
		_advance_turn()


func _end_round_with_winner(winner_index: int) -> void:
	if not game_state.is_player_active(winner_index):
		return
	var winner: PlayerState = game_state.players[winner_index]
	var round_points := 0
	for player_index in game_state.get_active_player_indices():
		if player_index != winner_index:
			round_points += game_state.players[player_index].get_hand_point_value()
	winner.score += round_points
	game_state.end_round(winner)


func _get_lowest_hand_player_index() -> int:
	var winner_index := -1
	var lowest_card_count := 0
	var lowest_hand_points := 0
	for player_index in game_state.get_active_player_indices():
		var player: PlayerState = game_state.players[player_index]
		if winner_index == -1 or player.hand_size() < lowest_card_count \
			or (player.hand_size() == lowest_card_count and player.get_hand_point_value() < lowest_hand_points):
			winner_index = player_index
			lowest_card_count = player.hand_size()
			lowest_hand_points = player.get_hand_point_value()
	return winner_index


func _get_highest_score_player_index() -> int:
	var winner_index := -1
	var highest_score := 0
	for player_index in range(game_state.players.size()):
		var player_score: int = game_state.players[player_index].score
		if winner_index == -1 or player_score > highest_score:
			winner_index = player_index
			highest_score = player_score
	return winner_index


func _is_valid_chain_reverse(card: CardData, declared_wild_color: Globals.CardColor) -> bool:
	if card == null or not card.has_type(Globals.CardType.COLOR_EFFECT) or card.color_effect_name != "reverse":
		return false
	if card.is_wild():
		return STANDARD_COLORS.has(declared_wild_color) and declared_wild_color == game_state.active_color
	return card.color == game_state.active_color


func _next_active_player_index(from_player_index: int) -> int:
	var candidate := from_player_index
	for step in range(game_state.players.size()):
		candidate = posmod(candidate + game_state.direction, game_state.players.size())
		if game_state.is_player_active(candidate):
			return candidate
	return -1


func _advance_turn(positions: int = 1) -> void:
	var next_player: int = game_state.current_player_index
	for position in range(positions):
		next_player = _next_active_player_index(next_player)
		if next_player == game_state.lap_opening_player_index:
			if not game_state.first_lap_completed_this_round:
				game_state.complete_first_lap()
			game_state.lap_number += 1
	game_state.current_player_index = next_player
	game_state.turn_number += 1


func _random_standard_color() -> Globals.CardColor:
	return STANDARD_COLORS.pick_random()
