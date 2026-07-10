# core/models/CardData.gd
# Resource base que representa una carta de UnoWilder.
# Fuente de reglas: Game Bible 3.12 (puntuación), 5.1-5.3 (catálogo de tipos de carta),
# 1.3 del Roadmap (modelo de "tipos acumulables").
#
# IMPORTANTE: `types` es un Array de Globals.CardType, NUNCA un campo único `type`.
# Esto es lo que permite que una Wild Card combine, por ejemplo, WILD + DRAW
# (Wild Draw 4) o WILD + COLOR_EFFECT (Wild Reverse), y que el puntaje se calcule
# sumando el valor de cada tipo presente (Game Bible 3.12).
class_name CardData
extends Resource

## Identificador único de esta carta dentro de la partida (no del catálogo).
## Se asigna al instanciar copias concretas de una carta (ej. las 2 copias de un "5 Rojo",
## o las 4 copias de una Wild Card seleccionada, Game Bible 3.5).
@export var id: String = ""

## Nombre legible de la carta (ej. "5", "Skip", "Wild Draw 4", "Wild Shift").
@export var display_name: String = ""

## Color de la carta. Las Wild Cards SIEMPRE usan Globals.CardColor.WILD
## hasta que se declara un color al jugarlas (Game Bible 5.3: "inmunes a
## efectos que dependan de un color... hasta que se declara uno").
@export var color: Globals.CardColor = Globals.CardColor.RED

## Array de tipos que posee esta carta (Globals.CardType). Puede tener 1 o más.
## Ejemplos (Roadmap 1.3):
##   Wild Shift      -> [WILD]
##   Wild Draw 4     -> [WILD, DRAW]
##   Wild Reverse    -> [WILD, COLOR_EFFECT]
##   Draw 2 normal   -> [DRAW]
##   Skip normal     -> [COLOR_EFFECT]
##   "5" (numérica)  -> [NUMBER]
@export var types: Array[Globals.CardType] = []

## Valor numérico de la carta, solo relevante si types contiene NUMBER.
## Rango válido: 0-9 (Game Bible 4.1).
@export var number_value: int = -1

## Valor de robo de la carta, solo relevante si types contiene DRAW.
## UnoWilder soporta Draw 1, 2, 4, 5, 6, 8, 10, 12 (Game Bible 3.8, 3.12).
@export var draw_value: int = 0

## Nombre del efecto de color concreto, solo relevante si types contiene COLOR_EFFECT.
## Valores esperados: "skip", "reverse", "jump", "exchange" (Game Bible 5.2).
## Se maneja como String (no enum) porque cada efecto se implementará como su propio
## módulo CardEffect en el Capítulo 4 (Roadmap 1.1) — este campo solo identifica cuál usar.
@export var color_effect_name: String = ""

## Referencia opcional a un script de efecto (CardEffect, Capítulo 4).
## En el Capítulo 1 este campo existe pero no se usa todavía: el Core Engine
## aún no invoca on_play()/on_chain_response(). Se conecta en el Capítulo 4.
@export var effect_script: Script = null


## Calcula el puntaje de la carta sumando el valor de CADA tipo presente en `types`,
## según la tabla de la Game Bible 3.12. Reusa las constantes ya definidas en Globals
## (autoloads/globals.gd) en vez de duplicar los números mágicos aquí.
func get_point_value() -> int:
	var total := 0

	for t in types:
		match t:
			Globals.CardType.NUMBER:
				if number_value == 0:
					total += Globals.POINT_VALUE_ZERO
				else:
					total += number_value * Globals.POINT_VALUE_NUMBER_BASE
			Globals.CardType.COLOR_EFFECT:
				total += Globals.POINT_VALUE_COLOR_EFFECT
			Globals.CardType.DRAW:
				total += draw_value * Globals.POINT_VALUE_DRAW_MULTIPLIER
			Globals.CardType.WILD:
				total += Globals.POINT_VALUE_WILD_BASE

	return total


## Devuelve true si esta carta posee el tipo indicado.
## Ayuda a que el resto del Core Engine (Deck, TurnManager, ChainManager en capítulos
## futuros) no tenga que hacer `types.has(...)` repetido por todos lados.
func has_type(type: Globals.CardType) -> bool:
	return types.has(type)


## Devuelve true si esta carta es una Wild Card.
## Atajo usado constantemente en reglas futuras (Cadena, elementos, Wild Codex).
func is_wild() -> bool:
	return has_type(Globals.CardType.WILD)


## Representación legible para debugging/tests.
func _to_string() -> String:
	return "CardData(id=%s, name=%s, color=%s, types=%s, pts=%d)" % [
		id, display_name, Globals.CardColor.keys()[color], str(types), get_point_value()
	]
