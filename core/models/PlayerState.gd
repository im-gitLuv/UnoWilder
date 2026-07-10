# core/models/PlayerState.gd
# Representa el estado de un jugador dentro de una Partida.
# Fuente de reglas: Game Bible 3.6 (límite de mano 25+), 3.12 (puntuación),
# 2.4 (gancho narrativo de ascenso/penalización).
class_name PlayerState
extends RefCounted

## Estado narrativo del jugador (gancho para Capítulo 13, Game Bible 2.2-2.3).
## No tiene efecto mecánico todavía en el Capítulo 1 — solo se modela el campo.
enum Status {
	ACTIVE,      # jugando con normalidad
	ASCENDED,    # ascenso narrativo (juega siendo fiel a sí mismo sin dañar a otros)
	PENALIZED,   # penalización narrativa (traiciona su naturaleza o daña a otros)
	ELIMINATED   # perdió la ronda por límite de mano (3.6) u otro medio
}

## Nombre/identificador del jugador (display o id de red en el futuro Cap. 11).
var player_name: String = ""

## Mano actual del jugador.
var hand: Array[CardData] = []

## Puntaje acumulado de este jugador a lo largo de la Partida (suma de rondas ganadas).
var score: int = 0

## Estado actual del jugador (ver enum Status arriba).
var status: Status = Status.ACTIVE

## Si este jugador ya usó su oportunidad de "quema inicial" en la ronda actual
## (Game Bible 3.4: una única vez por ronda, ventana = primera Vuelta).
## Se resetea al empezar cada Ronda nueva.
var has_used_initial_burn_this_round: bool = false


func add_cards(cards: Array[CardData]) -> void:
	hand.append_array(cards)


## Remueve y devuelve una carta específica de la mano por referencia.
## Devuelve null si la carta no está en la mano (no debería ocurrir si el
## llamador ya validó la jugada, pero se protege contra el caso).
func remove_card(card: CardData) -> CardData:
	var idx := hand.find(card)
	if idx == -1:
		return null
	return hand.pop_at(idx)


func hand_size() -> int:
	return hand.size()


## Game Bible 3.6: cualquier jugador con 25+ cartas en mano pierde la ronda
## automáticamente. Este método solo expone la condición; la resolución
## completa (quemar toda la mano, marcar ELIMINATED, etc.) la orquesta
## GameState/TurnManager en el Capítulo 2, porque involucra a más de un jugador.
func has_reached_hand_limit() -> bool:
	return hand_size() >= Globals.HAND_LIMIT


## Suma el puntaje de todas las cartas actualmente en mano (Game Bible 3.12),
## usado al calcular cuánto recibe el ganador de una ronda por las manos
## restantes de sus oponentes.
func get_hand_point_value() -> int:
	var total := 0
	for card in hand:
		total += card.get_point_value()
	return total


## Debe llamarse al iniciar cada Ronda nueva (no cada Partida, no cada Vuelta).
func reset_for_new_round() -> void:
	has_used_initial_burn_this_round = false


func _to_string() -> String:
	return "PlayerState(%s, hand=%d cartas, score=%d, status=%s)" % [
		player_name, hand_size(), score, Status.keys()[status]
	]
