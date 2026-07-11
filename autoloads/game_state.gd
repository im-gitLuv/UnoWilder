# autoloads/game_state.gd
# Estado autoritativo de una Partida de UnoWilder, sin dependencia de UI.
# Fuente: Game Bible 3.2 y 3.6; Roadmap, Capítulo 2.
extends Node


## Fases globales del flujo de una Ronda. La Cadena se implementará en el Capítulo 5,
## pero su fase existe desde ahora para que la jerarquía no tenga que rediseñarse después.
enum Phase {
	SETUP,
	WILD_SELECTION,
	TURN,
	CHAIN,
	ROUND_ENDED,
	MATCH_ENDED
}


signal phase_changed(new_phase: Phase)
signal match_started
signal round_started(round_number: int)
signal lap_started(lap_number: int, opening_player_index: int)
signal first_lap_completed
signal round_ended(winner: PlayerState)
signal match_ended(winner: PlayerState)


## Estado de la Partida.
var players: Array[PlayerState] = []
var deck: Deck
var phase: Phase = Phase.SETUP
var round_number: int = 0

## Estado de la Ronda y la Vuelta actuales.
var lap_number: int = 0
var current_player_index: int = -1
var lap_opening_player_index: int = -1
var turn_number: int = 0
var direction: int = 1
var first_lap_completed_this_round: bool = false
var active_color: Globals.CardColor = Globals.CardColor.RED
var eliminated_player_indices: Array[int] = []

## Estado que debe sobrevivir entre Rondas de la misma Partida (Game Bible 3.6).
var first_enojo_occurred_this_match: bool = false


## Inicializa el contenedor de una Partida. La creación del mazo y el reparto se
## delegan a The Wild Deck/TurnManager para conservar responsabilidades separadas.
func start_match(match_players: Array[PlayerState], match_deck: Deck) -> bool:
	if match_players.size() < Globals.MIN_PLAYERS or match_players.size() > Globals.MAX_PLAYERS:
		return false

	if match_deck == null:
		return false

	players = match_players.duplicate()
	deck = match_deck
	round_number = 0
	lap_number = 0
	current_player_index = -1
	lap_opening_player_index = -1
	turn_number = 0
	direction = 1
	first_lap_completed_this_round = false
	eliminated_player_indices.clear()
	first_enojo_occurred_this_match = false
	_set_phase(Phase.SETUP)
	match_started.emit()
	return true


## Abre una Ronda y restablece exclusivamente el estado que, por regla, termina con ella.
## La selección secuencial del Wild Codex sucede después de este punto (Game Bible 3.5).
func start_round() -> bool:
	if players.is_empty() or deck == null:
		return false

	round_number += 1
	lap_number = 0
	current_player_index = -1
	lap_opening_player_index = -1
	turn_number = 0
	direction = 1
	first_lap_completed_this_round = false
	eliminated_player_indices.clear()
	deck.reset_round_reshuffle_count()

	for player in players:
		player.status = PlayerState.Status.ACTIVE
		player.reset_for_new_round()

	_set_phase(Phase.WILD_SELECTION)
	round_started.emit(round_number)
	return true


## Comienza una Vuelta. El jugador que la abre se conserva aunque otros jugadores
## sean saltados; TurnManager lo usará para detectar correctamente su cierre.
func start_lap(opening_player_index: int) -> bool:
	if not _is_valid_player_index(opening_player_index):
		return false

	lap_number += 1
	current_player_index = opening_player_index
	lap_opening_player_index = opening_player_index
	turn_number = 0
	_set_phase(Phase.TURN)
	lap_started.emit(lap_number, opening_player_index)
	return true


## Marca el cierre de la primera Vuelta de la Ronda. La quema inicial deja de estar
## disponible para todos los jugadores desde este momento (Game Bible 3.4).
func complete_first_lap() -> void:
	if first_lap_completed_this_round:
		return

	first_lap_completed_this_round = true
	first_lap_completed.emit()


## El color activo puede diferir del color impreso en una Wild Card.
func set_active_color(new_color: Globals.CardColor) -> void:
	active_color = new_color


## Un jugador eliminado por límite de mano deja de recibir Turnos hasta la próxima Ronda.
func eliminate_player(player_index: int) -> void:
	if not _is_valid_player_index(player_index) or eliminated_player_indices.has(player_index):
		return

	eliminated_player_indices.append(player_index)
	players[player_index].status = PlayerState.Status.ELIMINATED


func is_player_active(player_index: int) -> bool:
	return _is_valid_player_index(player_index) and not eliminated_player_indices.has(player_index)


func get_active_player_indices() -> Array[int]:
	var active_indices: Array[int] = []
	for player_index in range(players.size()):
		if is_player_active(player_index):
			active_indices.append(player_index)
	return active_indices


## Centraliza el cierre de Ronda para que UI y futuras capas de puntuación reaccionen
## mediante señales, sin que este estado global dependa de una escena.
func end_round(winner: PlayerState) -> void:
	_set_phase(Phase.ROUND_ENDED)
	round_ended.emit(winner)


## Señala el final definitivo de la Partida, incluido el cierre por Segundo Enojo.
func end_match(winner: PlayerState) -> void:
	_set_phase(Phase.MATCH_ENDED)
	match_ended.emit(winner)


func _set_phase(new_phase: Phase) -> void:
	if phase == new_phase:
		return

	phase = new_phase
	phase_changed.emit(phase)


func _is_valid_player_index(player_index: int) -> bool:
	return player_index >= 0 and player_index < players.size()
