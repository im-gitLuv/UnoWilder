# autoloads/globals.gd
# Constantes globales del proyecto
extends Node

# Límites de jugadores (Game Bible 3.1)
const MAX_PLAYERS = 8
const MIN_PLAYERS = 2

# Límite de cartas en mano antes de pérdida automática (Game Bible 3.6)
const HAND_LIMIT = 25

# Puntuación base por tipo de característica (Game Bible 3.12)
const POINT_VALUE_ZERO = 10
const POINT_VALUE_NUMBER_BASE = 1  # números 1-9 valen su propio número
const POINT_VALUE_COLOR_EFFECT = 20  # Skip, Reverse, Jump, Exchange
const POINT_VALUE_DRAW_MULTIPLIER = 2  # Draw N vale N × 2
const POINT_VALUE_WILD_BASE = 50

# Enumeraciones de tipos de carta (Game Bible 1.3)
enum CardType {
	NUMBER,
	COLOR_EFFECT,  # Skip, Reverse, Jump, Exchange
	DRAW,
	WILD
}

enum CardColor {
	RED,
	BLUE,
	YELLOW,
	GREEN,
	WILD  # para Wild Cards
}

enum CardActionType {
	JUGAR,       # jugada normal con efecto (Game Bible 3.3)
	DESCARTAR,   # sin efecto, forzado (Game Bible 3.3)
	QUEMAR,      # irrecuperable (Game Bible 3.3)
	REMEZCLAR    # administrativo (Game Bible 3.3)
}

enum ElementType {
	FIRE,       # Game Bible 3.10
	WATER,      # Game Bible 3.10
	NATURE,     # Game Bible 3.10
	LIGHT       # Game Bible 3.10
}