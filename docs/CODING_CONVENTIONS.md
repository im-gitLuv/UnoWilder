# Convenciones de codificación — UnoWilder

## Archivos y carpetas

- **Archivos GDScript (`.gd`):** `snake_case` — ej. `card_effect.gd`, `turn_manager.gd`
- **Archivos C# (`.cs`):** `PascalCase` — ej. `AIPlayer.cs`, `HeuristicEvaluator.cs`
- **Escenas (`.tscn`):** `PascalCase` — ej. `GameTable.tscn`, `CardView.tscn`
- **Resources (`.tres`):** `snake_case` — ej. `wild_shift.tres`, `card_draw_2.tres`

## Clases y variables

- **Nombres de clases en GDScript:** `PascalCase` — ej. `class_name CardEffect`, `class_name GameState`
- **Nombres de variables/funciones en GDScript:** `snake_case` — ej. `func get_point_value()`, `var hand_cards`
- **Nombres de clases en C#:** `PascalCase` — ej. `public class AIPlayer`, `public class HeuristicEvaluator`
- **Nombres de variables/métodos en C#:** `camelCase` — ej. `public int EvaluateMove()`, `private List<Card> validMoves`

## Constantes

- **Constantes globales:** `SCREAMING_SNAKE_CASE` — definidas en `autoloads/globals.gd` — ej. `MAX_PLAYERS`, `HAND_LIMIT`

## Enumeraciones

- **Enumeraciones:** `PascalCase` para el nombre, `SCREAMING_SNAKE_CASE` para los valores — ej. `enum CardType { WILD, NUMBER }`, pero el acceso es `Globals.CardType.WILD`

## Señales (GDScript)

- **Nombres de señal:** `snake_case` — ej. `signal card_played`, `signal round_ended`

## Comentarios

- Comenta el "por qué", no el "qué" — el código debe ser legible por sí solo.
- Usa comentarios en línea para contexto de reglas — ej. `# Game Bible 3.5 — persistencia de Wilds entre rondas`
