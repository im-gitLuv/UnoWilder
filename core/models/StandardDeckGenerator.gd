# core/models/StandardDeckGenerator.gd
# Genera el mazo estándar base de UnoWilder (128 cartas), ANTES de añadir
# ninguna Wild Card (las Wilds se insertan aparte en el Capítulo 4, según la
# selección pre-ronda de Game Bible 3.5).
#
# Fuente de reglas: Game Bible 4.1-4.3.
#   4.1 - Numéricas: 4 colores x números 0-9 x 2 copias = 80 cartas.
#   4.2 - Efecto de color: 4 colores x 6 tipos (Skip, Reverse, Draw 1, Draw 2,
#         Jump, Exchange) x 2 copias = 48 cartas.
#   4.3 - Total núcleo estándar: 80 + 48 = 128 cartas.
class_name StandardDeckGenerator
extends RefCounted

## Colores jugables del mazo estándar (excluye Globals.CardColor.WILD,
## que solo aplica a las Wild Cards del Wild Codex).
const STANDARD_COLORS: Array[Globals.CardColor] = [
	Globals.CardColor.RED,
	Globals.CardColor.BLUE,
	Globals.CardColor.YELLOW,
	Globals.CardColor.GREEN,
]

## Los 6 tipos de efecto de color, con su color_effect_name y, si aplica, draw_value.
## Estructura: { "name": String, "is_draw": bool, "draw_value": int }
const COLOR_EFFECT_DEFS := [
	{"name": "skip", "is_draw": false, "draw_value": 0},
	{"name": "reverse", "is_draw": false, "draw_value": 0},
	{"name": "jump", "is_draw": false, "draw_value": 0},
	{"name": "exchange", "is_draw": false, "draw_value": 0},
	{"name": "draw_1", "is_draw": true, "draw_value": 1},
	{"name": "draw_2", "is_draw": true, "draw_value": 2},
]

## Contador interno para generar ids únicos legibles dentro de una generación.
var _next_id: int = 0


## Genera y devuelve el mazo estándar completo de 128 cartas.
func generate() -> Array[CardData]:
	_next_id = 0
	var deck: Array[CardData] = []

	deck.append_array(_generate_number_cards())
	deck.append_array(_generate_color_effect_cards())

	return deck


func _generate_number_cards() -> Array[CardData]:
	var cards: Array[CardData] = []

	for color in STANDARD_COLORS:
		for number in range(0, 10):  # 0-9
			for copy in range(2):  # 2 copias de cada número (4.1)
				cards.append(_make_number_card(color, number))

	return cards


func _generate_color_effect_cards() -> Array[CardData]:
	var cards: Array[CardData] = []

	for color in STANDARD_COLORS:
		for effect_def in COLOR_EFFECT_DEFS:
			for copy in range(2):  # 2 copias de cada tipo (4.2)
				cards.append(_make_color_effect_card(color, effect_def))

	return cards


func _make_number_card(color: Globals.CardColor, number: int) -> CardData:
	var card := CardData.new()
	card.id = _generate_id("num")
	card.color = color
	card.types = [Globals.CardType.NUMBER]
	card.number_value = number
	card.display_name = str(number)
	return card


func _make_color_effect_card(color: Globals.CardColor, effect_def: Dictionary) -> CardData:
	var card := CardData.new()
	card.id = _generate_id("eff")
	card.color = color

	if effect_def["is_draw"]:
		# Draw 1 / Draw 2 normales (no Wild): solo tipo DRAW, no COLOR_EFFECT
		# (Game Bible 3.12: "Draw N (capacidad de robo)" es su propia categoría,
		# separada de "Efecto de color (Skip, Reverse, Jump, Exchange)").
		card.types = [Globals.CardType.DRAW]
		card.draw_value = effect_def["draw_value"]
		card.display_name = "Draw %d" % effect_def["draw_value"]
	else:
		card.types = [Globals.CardType.COLOR_EFFECT]
		card.color_effect_name = effect_def["name"]
		card.display_name = effect_def["name"].capitalize()

	return card


func _generate_id(prefix: String) -> String:
	_next_id += 1
	return "%s_%03d" % [prefix, _next_id]
