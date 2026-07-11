# core/models/Deck.gd
# Representa una pila de cartas dentro de la partida (la baraja de robo,
# la pila de descartes, o la pila de quemadas — todas son instancias de Deck).
#
# Fuente de reglas: Game Bible 3.3 (Jugar / Descartar / Quemar / Remezclar).
# Los cuatro verbos tienen semántica DISTINTA y este script los respeta:
#   - play(card)    -> Jugar: va al descarte, SÍ aplica efecto (el efecto en sí
#                       no se ejecuta aquí todavía, eso es Capítulo 4; Deck solo
#                       mueve la carta y dispara la señal correspondiente).
#   - discard(card) -> Descartar: va al descarte, NO aplica efecto ni respeta color.
#   - burn(card)    -> Quemar: va a una pila SEPARADA e irrecuperable, fuera de
#                       la partida para siempre. Nunca vuelve, ni por Remezcla.
#   - reshuffle()   -> Remezclar: toma la pila de descartes (jugado + descartado,
#                       NUNCA lo quemado) y la convierte en nueva pila de robo.
class_name Deck
extends RefCounted

## Pila de robo activa (de donde se roba con draw()).
var draw_pile: Array[CardData] = []

## Pila de descartes (cartas jugadas o descartadas). La cima es el último elemento.
var discard_pile: Array[CardData] = []

## Pila de cartas quemadas. Separada y nunca se remezcla de vuelta al juego (3.3).
var burn_pile: Array[CardData] = []

## Cuántas remezclas ha habido en la ronda actual. Se resetea al iniciar cada ronda.
## Usado por TurnManager/GameState (Capítulo 2) para detectar Primer/Segundo Enojo (3.6).
var reshuffles_this_round: int = 0


## Baraja aleatoriamente la pila de robo (Fisher-Yates vía shuffle() de Array).
func shuffle() -> void:
	draw_pile.shuffle()


## Roba `n` cartas de la pila de robo y las devuelve como Array.
## Si la pila de robo se queda sin cartas a mitad de un robo múltiple, dispara
## una Remezcla automáticamente (Game Bible 3.6, punto 5) y continúa robando.
## Devuelve menos de `n` cartas solo si ni siquiera remezclando hay suficientes
## (caso borde que TurnManager deberá vigilar en el Capítulo 2).
func draw(n: int = 1) -> Array[CardData]:
	var drawn: Array[CardData] = []

	for i in range(n):
		if draw_pile.is_empty():
			var reshuffled := reshuffle()
			if not reshuffled:
				# No hay nada en descarte tampoco: no quedan cartas en el sistema.
				break
		drawn.append(draw_one_without_reshuffle())

	return drawn


## Roba una sola carta sin intentar Remezclar. TurnManager usa este método para
## decidir si corresponde una Remezcla, el Primer Enojo o el Segundo Enojo.
func draw_one_without_reshuffle() -> CardData:
	if draw_pile.is_empty():
		return null
	return draw_pile.pop_back()


## Jugar (3.3): mueve la carta desde donde esté (se asume ya removida de la mano
## por PlayerState) a la cima del descarte. SÍ debe aplicarse su efecto — pero
## la ejecución del efecto en sí vive en CardEffect (Capítulo 4), no aquí.
func play(card: CardData) -> void:
	discard_pile.append(card)


## Descartar (3.3): igual que play() en términos de destino (va al descarte),
## pero conceptualmente NUNCA aplica efecto. Se separa como método propio para
## que el código que lo llama sea explícito sobre cuál de los dos verbos aplica.
func discard(card: CardData) -> void:
	discard_pile.append(card)


## Quemar (3.3): retira la carta a la pila de quemadas. Irrecuperable: no vuelve
## a la partida ni siquiera vía Remezcla, y nunca otorga ni cuesta puntos a nadie.
func burn(card: CardData) -> void:
	burn_pile.append(card)


## Quema múltiples cartas a la vez (ej. quema inicial de 3.4, o mano completa al
## perder por límite de 25+ cartas, 3.6).
func burn_multiple(cards: Array[CardData]) -> void:
	for c in cards:
		burn(c)


## Quema una cantidad aleatoria de cartas del descarte. Se usa exclusivamente en
## los Enojos: no puede tocar cartas que ya estén en la pila de quemadas.
func burn_random_discard_cards(count: int) -> Array[CardData]:
	var burned: Array[CardData] = []
	discard_pile.shuffle()

	for i in range(mini(count, discard_pile.size())):
		var card: CardData = discard_pile.pop_back()
		burn(card)
		burned.append(card)

	return burned


## Reúne las cartas no quemadas que siguen dentro de este Deck y vacía sus pilas
## operativas. TurnManager añade a este resultado las manos al cerrar una Ronda.
func take_all_unburned_cards() -> Array[CardData]:
	var cards: Array[CardData] = []
	cards.append_array(draw_pile)
	cards.append_array(discard_pile)
	draw_pile.clear()
	discard_pile.clear()
	return cards


## Inserta cartas en la pila de robo sin mezclar. The Wild Deck debe barajarlas
## después de incorporar las Wild Cards seleccionadas antes de cada Ronda.
func add_to_draw_pile(cards: Array[CardData]) -> void:
	draw_pile.append_array(cards)


## Remezclar (3.3, 3.6): toma toda la pila de descartes y la convierte en la
## nueva pila de robo. Incrementa `reshuffles_this_round`. Devuelve false si la
## pila de descartes también está vacía (no hay nada que remezclar).
##
## NOTA: esta función solo mueve cartas. La lógica de qué pasa cuando esto es
## la SEGUNDA remezcla de la ronda (Primer Enojo) o la repetición del patrón en
## otra ronda (Segundo Enojo) vive en GameState/TurnManager (Capítulo 2), porque
## requiere conocer el estado de la Partida completa, no solo de este Deck.
func reshuffle() -> bool:
	if discard_pile.is_empty():
		return false

	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	shuffle()
	reshuffles_this_round += 1
	return true


## Resetea el contador de remezclas. Debe llamarse al iniciar cada Ronda nueva
## (no cada Partida, no cada Vuelta) — ver jerarquía temporal, Game Bible 3.2.
func reset_round_reshuffle_count() -> void:
	reshuffles_this_round = 0


## Revela y devuelve la carta superior actual del descarte, sin removerla.
## Usado, por ejemplo, para validar contra qué se puede jugar en el turno.
func peek_discard_top() -> CardData:
	if discard_pile.is_empty():
		return null
	return discard_pile[-1]


func is_draw_pile_empty() -> bool:
	return draw_pile.is_empty()


func draw_pile_count() -> int:
	return draw_pile.size()


func discard_pile_count() -> int:
	return discard_pile.size()


func burn_pile_count() -> int:
	return burn_pile.size()
