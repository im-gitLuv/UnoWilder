# 🛠️ UnoWilder — Roadmap de Desarrollo (Godot)

### Documento de conocimiento maestro — Arquitectura técnica y progreso del proyecto

> Este documento asume cero conocimiento previo del stack de desarrollo de videojuegos y explica, en paralelo, los equivalentes conceptuales con el mundo webdev (JS/Next.js/GitHub) para que la transición sea intuitiva.
> Todas las reglas referenciadas aquí están definidas de forma oficial en `UNOWILDER_GAME_BIBLE.md`.

---

## 0. El "stack" de un juego en Godot — equivalencias con webdev

No existe un "Next.js para videojuegos" único, pero sí existe un ecosistema equivalente, y es más maduro de lo que parece:

| Concepto Webdev                        | Equivalente en desarrollo de juegos con Godot                                                                                                                                                                             |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Lenguaje (JavaScript/TypeScript)       | **GDScript** (lenguaje propio de Godot, sintaxis parecida a Python) como lenguaje principal del Core Engine — combinado con **C#** en los sistemas donde convenga más (ver 0.2, decisión de lenguaje híbrido confirmada). |
| Framework (Next.js, React)             | **Godot Engine** en sí mismo: escena + nodo son los "componentes", las señales (`signals`) son el equivalente a eventos/callbacks.                                                                                        |
| Componentes reutilizables              | **Escenas (.tscn)** — cualquier escena puede instanciarse dentro de otra, igual que un componente de React.                                                                                                               |
| Estado global / store (Redux, Zustand) | **Autoloads (Singletons)** — scripts que Godot carga siempre en memoria y son accesibles desde cualquier escena.                                                                                                          |
| Modelos de datos / DTOs                | **Resources (.tres)** — objetos serializables de Godot, ideales para representar datos "puros" como una carta.                                                                                                            |
| Base de datos / JSON config            | Resources, o JSON/CSV cargado en runtime, según el caso.                                                                                                                                                                  |
| Control de versiones                   | **Git**, exactamente igual que en web. Godot funciona muy bien con Git (los `.tscn` y `.tres` son texto plano).                                                                                                           |
| Repositorio remoto / CI                | **GitHub** (o GitLab) — igual que en web. Se pueden usar GitHub Actions para exportar builds automáticamente.                                                                                                             |
| Gestor de paquetes (npm)               | **AssetLib** de Godot (para addons/plugins) — más limitado que npm, se usa menos que en web.                                                                                                                              |
| Testing                                | **GUT (Godot Unit Test)**, un framework de testing para GDScript inspirado en frameworks xUnit.                                                                                                                           |
| "Server actions" / lógica de backend   | Si hay multijugador: **Godot High-Level Multiplayer API**, o backends externos tipo **Nakama** / servidor propio en GDScript/Godot headless.                                                                              |

**Versión fijada del proyecto:** **Godot 4.7**. Esta es la versión objetivo confirmada del proyecto (ya no una recomendación abierta) — se usa por su sistema de shaders maduro, `Resource`, y `Control` nodes para UI, todos pilares clave para UnoWilder.

### 0.2 Decisión de lenguaje: GDScript + C# híbrido (confirmado)

UnoWilder usará un enfoque **híbrido**, no GDScript puro:

- **GDScript** sigue siendo el lenguaje por defecto del **Core Engine** (`core/`, `autoloads/`, módulos de carta en `cards/`): reglas, turnos, Cadena, puntuación, y todo lo cubierto en los Capítulos 1–2 y 4–7. Se mantiene el principio de "Core Engine testeable sin UI" (ver sección 3, buenas prácticas).
- **C#** se usa específicamente donde el tipado fuerte y el rendimiento en cómputo intensivo convienen más — el caso principal identificado hasta ahora es la **IA de oponentes** (evaluación de jugadas, heurísticas o modelos de decisión más pesados que una simple lista de reglas en GDScript).
- La interfaz entre ambos mundos debe mantenerse explícita y acotada: la IA en C# consulta el estado de juego expuesto por el Core Engine (GDScript) a través de una interfaz clara, sin que la lógica de reglas dependa de C# para funcionar. Esto preserva la posibilidad de correr el Core Engine "headless" (Cap. 11, Multijugador Online) sin arrastrar dependencias de C# innecesarias.
- Otros sistemas que puedan beneficiarse de C# (por ejemplo, cómputo pesado de red en el Modo Online, Cap. 11) se evaluarán caso por caso conforme se llegue a esos capítulos, documentando la decisión aquí cuando se tome.

### 0.1 Organización recomendada del repositorio

```
UnoWilder/
├── addons/                  # plugins de terceros / GUT / herramientas propias
├── assets/
│   ├── art/
│   ├── audio/
│   ├── fonts/
│   └── vfx/
├── autoloads/                 # Singletons: WildDeck.gd, GameState.gd, EventBus.gd, RandomEventManager.gd
├── core/
│   ├── models/                 # Resources: Card.gd, Deck.gd, Player.gd
│   ├── rules/                   # TurnManager.gd, ChainManager.gd, ScoreManager.gd, JumpCounter.gd
│   └── enums/                    # CardColor, CardActionType (Jugar/Descartar/Quemar), ElementType, etc.
├── cards/
│   ├── base/                     # CardEffect.gd (clase/interfaz base)
│   ├── standard/                  # efectos de Skip, Reverse, Draw, Jump, Exchange
│   └── wild_codex/               # cada Wild Card como módulo independiente (incluye Wild Shift, la básica)
├── ui/
│   ├── screens/                  # MainMenu, GameTable, RoundSummary
│   └── components/                # CardView.tscn, HandView.tscn, ChainIndicator.tscn
├── narrative/                    # diálogos, escenas de lore
├── tests/                        # tests con GUT
├── docs/                         # este roadmap, la biblia del juego, notas de diseño
└── project.godot
```

Este árbol es la traducción directa de la Game Bible a estructura de proyecto: `cards/wild_codex/` es el equivalente técnico literal del "Wild Codex" narrativo, y `autoloads/WildDeck.gd` es el módulo que implementa a The Wild Deck como árbitro (baraja, revela primera carta, gestiona remezclas, resuelve el caos del grito de UNO, etc.).

---

## 1. Arquitectura núcleo: el motor "tipo TCG"

Igual que YGOPro/EDOPro separan el **motor de reglas** de las **cartas individuales**, UnoWilder debe separar:

1. **El Core Engine** (`core/` + `autoloads/`): no conoce el contenido de ninguna carta específica, solo sabe _cómo_ pedirle a una carta que se ejecute, y aplica las reglas generales (turnos, cadena, puntuación).
2. **Los módulos de carta** (`cards/`): cada carta implementa una interfaz común y encapsula su propia lógica.

### 1.1 Interfaz base de carta (concepto)

Toda carta (estándar o Wild) hereda de una clase base, por ejemplo `CardEffect`, que expone métodos como:

- `can_be_played(game_state, player) -> bool`
- `on_play(game_state, player) -> void`
- `on_chain_response(game_state, player) -> bool` (si aplica a la Cadena)
- `get_types() -> Array` (ej. `[Type.WILD, Type.DRAW]`, ver 1.3)
- `get_point_value() -> int` (calculado a partir de `get_types()`, ver Capítulo 7)
  El **Core Engine** nunca hace `if card.name == "Wild Draw 6": ...`. En su lugar, llama siempre a `card.on_play(...)` y deja que sea la propia carta la que sepa qué hacer. Esto es exactamente el patrón que usan los motores TCG modulares: el motor "no sabe" qué hace cada carta, solo sabe _que_ tiene que invocarla.

### 1.2 Cartas como Resources + Script

- Cada carta se define como un `Resource` personalizado (ej. `CardData.gd` con `class_name CardData extends Resource`), con campos exportados: color, tipo(s), valor, texto, ícono, y una referencia a un script de efecto.
- Esto permite crear cartas **desde el editor de Godot sin tocar código**, arrastrando valores en el Inspector — clave para que, más adelante, el Wild Codex sea accesible a creadores externos con conocimientos técnicos limitados.
- **Wild Shift** (Game Bible 5.3.1) es el caso de prueba más simple posible para este sistema: una `CardData` con `types = [CardType.WILD]` y ningún dato adicional. Es la referencia mínima contra la que validar que el resto de Wilds ("Wild Shift + algo más") se construyen correctamente.

### 1.3 Modelo de "tipos acumulables" (clave para el puntaje)

Según la Game Bible (sección 3.12), **una carta puede tener más de un tipo a la vez** y su puntaje es la suma de los valores de cada tipo. Esto significa que `CardData` **no debe** tener un campo único `type: String`, sino un **array de tipos**, por ejemplo:

```gdscript
enum CardType { NUMBER, COLOR_EFFECT, DRAW, WILD }

# Ejemplo: Wild Shift (la Wild básica/canónica)
types = [CardType.WILD]

# Ejemplo: Wild Draw 4
types = [CardType.WILD, CardType.DRAW]
draw_value = 4  # usado solo si CardType.DRAW está presente

# Ejemplo: Wild Reverse
types = [CardType.WILD, CardType.COLOR_EFFECT]

# Ejemplo: Draw 2 normal (no wild)
types = [CardType.DRAW]
draw_value = 2
```

El método `get_point_value()` de `CardEffect` simplemente **recorre `types` y suma** el valor correspondiente de cada uno (tabla completa en Capítulo 7). Esto es lo que permite que cualquier Wild Card nueva —incluidas las de la comunidad— calcule su puntaje automáticamente sin lógica especial por carta.

### 1.4 Jerarquía temporal en el modelo de datos

La Game Bible (sección 3.2) define cuatro unidades de tiempo anidadas: **Partida → Ronda → Vuelta → Turno**, donde **la Vuelta tiene prioridad sobre el Turno individual** (una Vuelta se completa por el recorrido completo del ciclo, sin importar si algún jugador fue saltado). El modelo de datos y el motor de estados deben reflejar esta jerarquía de forma explícita desde el diseño inicial (ver detalle de implementación en Capítulo 2), ya que de ella dependen:

- La duración de los efectos elementales (medida en Vueltas del jugador afectado, no en turnos globales).
- La persistencia de las Wild Cards seleccionadas entre rondas de una misma partida (Capítulo 4).
- La ventana de la quema inicial (Game Bible 3.4): disponible **una vez por ronda**, limitada a la primera Vuelta de esa ronda — un jugador saltado durante la primera Vuelta pierde la oportunidad de quemar en esa ronda aunque su primer Turno jugable caiga en la segunda Vuelta. El motor necesita poder distinguir "¿ya se completó la primera Vuelta de esta ronda?" independientemente de si un jugador específico ya tuvo su Turno.
- El cierre de partida por Segundo Enojo de The Wild Deck (Game Bible 3.6): requiere que el motor recuerde, a nivel de Partida (no solo de Ronda), si ya ocurrió un Primer Enojo (remezcla doble) en alguna ronda anterior, para poder detectar cuándo el patrón se repite en una ronda distinta y disparar el cierre completo de la partida.

---

## 2. Progreso del proyecto — Capítulos de desarrollo

> Cada capítulo tiene: objetivo, entregables concretos y estado. Actualiza el campo **Estado** conforme avances (Pendiente / En progreso / Completado). Este documento está pensado para reflejar fielmente lo mismo que un GitHub Project/Issues board — se recomienda espejar estos capítulos como _Milestones_ en GitHub.

### Capítulo 0 — Preproducción y setup del entorno

**Estado:** ✅ Completado (2026-07-10)

- ✅ Godot 4.7.stable.mono instalado, soporte .NET confirmado.
- ✅ Repositorio GitHub creado: https://github.com/im-gitLuv/UnoWilder
- ✅ Repo clonado localmente y vinculado a Git.
- ✅ Estructura de carpetas base creada (ver sección 0.1).
- ✅ `.gitignore` actualizado con artefactos de C#/.NET (`.mono/`, `obj/`, `bin/`, etc.).
- ✅ Convenciones de nombres documentadas en `docs/CODING_CONVENTIONS.md`.
- ✅ GUT 9.7.0 instalado como **Plugin** (Project Settings → Plugins), no como Autoload — ver nota de arquitectura abajo.
- ✅ `autoloads/globals.gd` creado y registrado como Autoload (`Globals`), con `MAX_PLAYERS`, `MIN_PLAYERS`, `HAND_LIMIT`, y enums `CardType`, `CardColor`, `CardActionType`, `ElementType`.
- ✅ `docs/UNOWILDER_GAME_BIBLE.md` y `docs/UNOWILDER_DEV_ROADMAP.md` presentes en el repo.
- ✅ `README.md` creado en raíz.
- ✅ Commit inicial pusheado a `main`.

**Nota de arquitectura — GUT como Plugin, no Autoload:** confirmado que las versiones modernas de GUT (9.x) se integran vía el sistema de Plugins de Godot (Project Settings → Plugins), exponiendo su panel de testing en la barra inferior del editor. No requiere (ni debe) registrarse manualmente como Autoload — el plugin gestiona su propia inicialización internamente. Registrarlo también como Autoload arriesgaría doble inicialización.

**Nota de setup — ubicación del proyecto Godot:** el `project.godot` debe vivir en la **raíz** del repositorio, al mismo nivel que `autoloads/`, `core/`, `cards/`, etc. — no en una subcarpeta. Si `New Project` en Godot crea una subcarpeta extra por error, mover todo el contenido a la raíz antes de continuar.

### Capítulo 1 — Modelo de datos núcleo

**Objetivo:** tener las clases de datos base sin ninguna lógica de UI todavía.
**Estado:** Pendiente

- `CardData.gd` (Resource): color, **array de tipos** (`CardType`, ver sección 1.3), valor numérico, `draw_value` (si aplica), puntos calculados, id único.
- `Deck.gd`: colección de `CardData`, métodos `shuffle()`, `draw(n)`, `discard(card)` (sin efecto), `play(card)` (con efecto), `burn(card)` (pila separada, irrecuperable).
- `PlayerState.gd`: mano, puntos, estado (activo, penalizado, ascendido — gancho para lore).
- Script generador de la baraja estándar de 128 cartas (Game Bible 4.1–4.3), cubierto por un test unitario que valide el conteo exacto.
- Test unitario de `get_point_value()` contra la tabla de la Game Bible 3.12 (incluyendo casos multi-tipo: Wild Shift = 50, Wild Draw 4 = 58, Wild Draw 12 = 74, Wild Reverse = 70, etc.).

### Capítulo 2 — Máquina de estados de partida y turnos

**Objetivo:** lógica de turno funcional sin UI (se puede probar por consola/tests).
**Estado:** Pendiente

- `GameState.gd` (Autoload): fase actual (setup, selección de wilds, turno, cadena, fin de ronda).
- **Jerarquía temporal explícita en el motor:** `GameState.gd` debe modelar Partida → Ronda → Vuelta → Turno como estados anidados reales, no como variables sueltas. En particular, `TurnManager.gd` necesita saber en todo momento "quién abrió la Vuelta actual" para poder detectar cuándo una Vuelta se completa (el turno vuelve a caer sobre ese jugador, **sin importar si algún jugador intermedio fue saltado** — la Vuelta tiene prioridad sobre el Turno, ver Game Bible 3.2), ya que de esto depende la duración de todos los efectos elementales (Cap. 6), la mecánica de Nature (juegos dobles), y la ventana de la quema inicial (ver punto siguiente).
- Cada Wild Card/efecto temporal debe registrar su duración como **"X Vueltas del jugador afectado"**, no como un contador global de turnos de mesa — dos jugadores distintos pueden tener el mismo efecto corriendo con distinta cantidad de Vueltas restantes en paralelo.
- `TurnManager.gd`: orden de turno, dirección (para Reverse), validación de jugadas legales.
- Implementar la mecánica de "quema inicial" (Game Bible 3.4), disponible **una vez por ronda** (no una vez por partida), usando `Deck.burn()`. La ventana se cierra en cuanto se completa la primera Vuelta de esa ronda: `TurnManager.gd` debe exponer un flag tipo `first_lap_completed_this_round` consultado antes de permitir la quema, de forma que un jugador saltado durante la primera Vuelta no pueda quemar aunque su primer Turno jugable ocurra ya en la segunda Vuelta.
- **Arranque de la primera Vuelta de cada ronda:** al iniciar cada ronda, revelar la primera carta de la pila y **aplicar su efecto contra el primer jugador** como si The Wild Deck la hubiera jugado (Game Bible 3.6, punto 1) — cubre los casos de Draw (dispara Cadena), Skip, Reverse (invierte el sentido antes de que nadie juegue) y Wild (The Wild Deck escoge color al azar).
- **Robo continuo hasta poder jugar:** cuando un jugador no puede jugar, `TurnManager` debe robar cartas **en bucle** hasta obtener una jugable, no una sola vez (Game Bible 3.6, punto 4).
- **Remezcla escalonada:** lógica en `Deck.gd`/`WildDeck.gd` para reconstruir la pila de robo desde el descarte cuando se agota, con contador `reshuffles_this_round`. Al segundo intento en la misma ronda (**Primer Enojo**): quemar un tercio aleatorio del descarte y finalizar esa ronda de inmediato, resolviendo el ganador por menor cantidad de cartas (o menor puntaje en caso de empate). Si el patrón de remezcla doble se repite en **otra ronda posterior** de la misma partida (**Segundo Enojo**): quemar todo el descarte, finalizar esa ronda, y además **finalizar la partida completa**, otorgando la victoria al jugador con más puntos acumulados hasta ese momento — ver Game Bible 3.6. Esto requiere que `GameState.gd` mantenga un flag a nivel de **Partida** (`first_enojo_occurred_this_match`), no solo a nivel de Ronda, para poder detectar la repetición entre rondas distintas.
- **Límite de mano (25+), confirmado sin nota abierta:** chequeo tras cada robo (por cualquier motivo: robo continuo o Cadena grande); si un jugador alcanza 25+ cartas, se marca como "perdedor de la ronda" y su mano completa se quema (sin bono de puntos para el resto, salvo evento narrativo opcional de The Wild Deck — ver Cap. 13). En partidas de más de 2 jugadores, **solo ese jugador queda fuera** y la ronda continúa con normalidad entre el resto, salvo que quede un único jugador en pie (gana por defecto). En partidas de exactamente 2 jugadores, la ronda termina de inmediato y gana el jugador restante.
- Tests: partida simulada de 2–4 jugadores sin cartas Wild, solo con el mazo estándar, cubriendo remezcla simple, Primer Enojo, Segundo Enojo (across múltiples rondas), la ventana de quema limitada a la primera Vuelta (incluyendo el caso de jugador saltado), y el límite de 25 cartas en partidas de 2 y de 3+ jugadores.

### Capítulo 3 — Prototipo jugable en UI básica ("gris box")

**Objetivo:** poder jugar una partida completa localmente con arte placeholder.
**Estado:** Pendiente

- `GameTable.tscn`: mesa, mano del jugador, pila de descarte, pila de quemadas (visible aparte), indicador de turno.
- `CardView.tscn`: representación visual mínima de una carta (sin animación aún).
- Interacción: click/drag para jugar carta, validación visual de jugadas ilegales.
- Loop de partida completo hasta fin de ronda y cálculo de puntuación (Game Bible 3.12).
- Este capítulo es la base funcional de lo que luego se presenta como **"Partida Rápida"** en el menú (hotseat local, sin red): incluso antes de tener IA (Cap. 10), el prototipo debe soportar jugar localmente contra otro humano en el mismo dispositivo.

### Capítulo 4 — Sistema modular de Wild Cards y selección pre-ronda

**Objetivo:** implementar el patrón de "carta = módulo" descrito en la sección 1 de este documento, junto con el flujo social de selección de wilds.
**Estado:** Pendiente

- Clase base `CardEffect.gd` con la interfaz descrita en 1.1.
- Implementar **Wild Shift** (la Wild básica, `types = [WILD]`, sin efectos adicionales) como primer módulo — sirve de plantilla mínima para todas las demás.
- Implementar 4–6 Wild Cards adicionales como prueba de concepto, incluyendo al menos una con múltiples tipos (ej. Wild Draw N, Wild Reverse).
- **Flujo de selección secuencial de Wild Cards:** `WildDeck.gd` pregunta jugador por jugador (nunca simultáneo), en el orden oficial (ganador de la ronda anterior primero, luego sentido horario; orden inicial aleatorio o por asiento en la primera ronda de la partida). Cada Wild elegida queda "reservada" dentro de esa tanda de selección para que no se repita entre jugadores en la misma ronda (Game Bible 3.5).
- Inserción de **4 copias por Wild Card seleccionada** (8 copias por jugador, por ronda) en la baraja de partida (Game Bible 3.5 y 4.4). Validar con test la fórmula `jugadores × 8`.
- **Persistencia de Wilds entre rondas (clave de arquitectura):** el pool de Wild Cards en juego **no se resetea al terminar una ronda**. `WildDeck.gd` debe mantener un registro de "Wilds actualmente en circulación en esta partida" que persiste entre rondas, y cada ronda nueva únicamente **añade** las Wild Cards recién elegidas por cada jugador a ese pool existente — nunca lo reemplaza. Las copias quemadas durante una ronda sí se descuentan permanentemente del pool (ver `Deck.burn()`, Cap. 1). Cubrir con un test que simule 2+ rondas seguidas y verifique que las wilds sobrevivientes de la Ronda 1 siguen apareciendo en la Ronda 2.
- `WildDeck.gd` (Autoload): rol de árbitro — recibe selección de wilds, arma la baraja de partida, valida jugadas, revela la primera carta de cada ronda.

### Capítulo 5 — Sistema de Cadena (Chain), Reverse y Jump

**Objetivo:** las tres mecánicas de turno más distintivas del juego, funcionando end-to-end.
**Estado:** Pendiente

- `ChainManager.gd`: estado de cadena activa (valor acumulado, jugador amenazado, historial de respuestas).
- Lógica de respuesta válida (carta Draw igual o superior).
- Implementar la redirección vía Reverse (Game Bible 3.9).
- `JumpCounter.gd`: lógica de conteo especial cuando Jump es seguido de una carta numérica (Game Bible 3.7) — conteo cíclico desde el siguiente jugador, tantas posiciones como el número jugado, dando la vuelta a la mesa si hace falta. Si Jump es seguido de un efecto de color o Wild, se resuelve con reglas normales (sin conteo).
- Indicador visual de "Cadena activa" y de "combo Jump" en la UI (placeholder en este capítulo, se refina en el Cap. 8).
- Tests exhaustivos: cadenas de 2, 3, 4+ jugadores, casos límite (nadie puede responder desde el inicio, Reverse en la última posición); Jump con números que dan la vuelta completa a la mesa (auto-combo) y con distintos tamaños de grupo (2 a 8 jugadores).

### Capítulo 6 — Sistema Elemental y caos del grito de UNO

**Objetivo:** framework de estados temporales invocables por Wild Cards, más el módulo de caos al declarar UNO.
**Estado:** Pendiente

- `ElementalState.gd`: tipo de elemento, jugadores afectados, duración en **Vueltas del jugador afectado** (ver jerarquía temporal, Cap. 2 / sección 1.4), efecto asociado.
- Integrar Fire, Water, Nature, Light (Game Bible 3.10) como implementaciones concretas del framework. Cada uno requiere lógica propia además del estado temporal genérico:
  - **Fire:** intercepta el flujo de robo del jugador afectado (tanto robo por Cadena como robo por "no tengo jugada") y redirige cada carta robada directo a `Deck.burn()` en vez de a la mano, repitiendo hasta encontrar una jugable si aplica.
  - **Water:** al jugar una carta azul con este efecto activo, dispara descarte forzado sobre jugadores adyacentes (Wild si tienen, si no 2 cartas al azar vía `Deck.discard()`); si un adyacente queda en 0 cartas por esto, no se marca como ganador de la ronda, se le da un robo de 2 cartas.
  - **Nature:** habilita doble jugada en el turno del jugador afectado al jugar verde (no acumulable), y mientras está activo fuerza un robo previo a jugar para **todos** los jugadores cuando la carta superior del descarte es verde.
  - **Light:** la visión de mano es estrictamente privada para quien activa el efecto (no debe emitirse ningún evento/señal que exponga la mano ajena al resto de clientes en una partida en red — importante de cara al Cap. 10).
- Verificar que el sistema sea extensible: una Wild Card nueva debería poder declarar un elemento nuevo sin tocar el Core Engine.
- `RandomEventManager.gd` (Autoload): se dispara cada vez que un jugador declara "UNO". Elige aleatoriamente entre: efecto random a N jugadores random, regalo de carta, descarte forzado (sin efecto, usando `Deck.discard()`), o cambio de color activo (Game Bible 3.11). Este módulo debe ser fácilmente ampliable con nuevos tipos de caos en el futuro.

### Capítulo 7 — Puntuación y rondas completas

**Objetivo:** ciclo completo de partida por puntos, no solo por ronda.
**Estado:** Pendiente

- `ScoreManager.gd`: aplica la tabla de puntos por tipo de la Game Bible 3.12, sumando **todos los tipos presentes** en cada carta (no solo el "tipo principal"). Wild Shift como caso base de validación (50 pts exactos, sin extras).
- Resolución especial de fin de ronda por doble Remezcla: comparar cantidad de cartas en mano; en empate, comparar puntaje de mano (menor gana); el ganador recibe el puntaje de todos los oponentes como en una victoria normal (Game Bible 3.6).
- Condición de victoria configurable (puntos objetivo de partida).
- Pantalla de resumen de ronda / resumen de partida, mostrando el desglose de puntos por tipo (útil para que el jugador entienda por qué una Wild vale, por ejemplo, 58 y no 50).

### Capítulo 8 — Arte, animación y VFX cinematográfico

**Objetivo:** que UnoWilder se sienta "salvaje" visualmente, cumpliendo la promesa de la Game Bible.
**Estado:** Pendiente

- Definir dirección de arte (paleta, estilo cyber-fi anime, referencias visuales).
- Animaciones de robo/juego/quema de carta con `AnimationPlayer`/`Tween` (la quema, al ser irreversible, merece una animación claramente distinta al descarte normal).
- Shaders/partículas para activaciones de Wild Cards, elementos, y el momento de caos al gritar UNO (este último debería sentirse como un "evento especial", no un trámite).
- Feedback visual claro de la Cadena y del combo Jump (crucial para la legibilidad del juego).
- Sonido/música (opcional en este capítulo, puede diferirse).

### Capítulo 10 — IA de oponentes

**Objetivo:** oponentes controlados por la máquina, jugables tanto en Partida Rápida local como en el futuro Modo Campaña (Cap. 12).
**Estado:** Pendiente

- Definir la interfaz de consulta que el Core Engine (GDScript) expone hacia la IA: estado de mesa visible para ese jugador, mano propia, cartas jugables, estado de la Cadena si está activa, elementos activos, etc. — sin exponer información oculta de otros jugadores (salvo lo que el propio efecto Light legítimamente revele).
- Implementar el módulo de IA en **C#** (ver sección 0.2): heurísticas de decisión de jugada (qué carta jugar, cuándo responder en la Cadena, cuándo iniciar Jump/combo, qué Wild Cards elegir en la selección pre-ronda).
- Niveles de dificultad de IA (al menos: básica reactiva vs. una IA con heurísticas más ricas) — el detalle fino de cuántos niveles y su comportamiento exacto se define en el mapa de gameplay (pendiente, ver Cap. 12).
- La IA debe poder participar en el flujo de selección secuencial de Wild Cards (Game Bible 3.5) y en la declaración de "¡UNO!" con timing creíble (no instantáneo/robótico).
- Tests: partidas simuladas IA vs. IA para detectar softlocks o jugadas inválidas antes de exponer la IA a jugadores reales.
- Gancho para el Cap. 12: los oponentes "boss" del Modo Campaña son una **especialización** de este mismo sistema de IA, con parámetros de dificultad alta y penalizaciones temáticas adicionales inyectadas a nivel de partida (ver Cap. 12) — no un sistema aparte.

### Capítulo 11 — Multijugador Online

**Objetivo:** llevar UnoWilder más allá del hotseat local hacia salas online (el hotseat local con IA o amigos ya se cubre en Cap. 2–3 como "Partida Rápida").
**Estado:** Pendiente

- Evaluar Godot High-Level Multiplayer API vs. solución externa (ej. Nakama) según necesidades (salas privadas vs. matchmaking público a lo largo del mundo). Recordar el límite oficial de 2 a 8 jugadores.
- Sincronización de estado autoritativo en servidor (el Core Engine ya diseñado en los Cap. 1–2 debe poder correr "headless" en servidor).
- Manejo de desconexiones/reconexiones.
- La selección secuencial de Wild Cards (Cap. 4) requiere especial cuidado en red: debe garantizarse el orden correcto y evitar condiciones de carrera entre jugadores eligiendo "al mismo tiempo".
- El efecto Light (Cap. 6) requiere que la visión de mano ajena viaje **solo** al cliente del jugador que activó el efecto — nunca broadcastearse a los demás.
- Definir si las salas online soportan mezcla de jugadores humanos y IA (relleno de sala), o son exclusivamente humanas — pendiente de definir en el mapa de gameplay.

### Capítulo 12 — Modo Campaña

**Objetivo:** experiencia de un jugador (o varios en local) que integra las reglas completas de UNOW con progresión de niveles, lore jugable, bosses temáticos y puzzles.
**Estado:** Pendiente — **diseño de detalle pendiente en un mapa de gameplay separado**

- **Alcance confirmado:** modo exclusivamente **local** (sin red), soporta 1 jugador o varios jugadores humanos locales compartiendo partida contra la IA/bosses; los oponentes no-humanos son siempre IA (Cap. 10).
- **Reglas:** el Modo Campaña usa el **mismo motor UNOW sin excepciones** — Cadena, Wilds, elementos, puntuación, todo igual que en Partida Rápida u Online. La progresión y el desafío vienen de la estructura de niveles y de las penalizaciones que imponen los bosses, no de una variante de reglas distinta.
- **Estructura de niveles:** sucesión de partidas/encuentros ligados a la narrativa de la Game Bible (Corrupción Wild, ascenso/penalización, sección 2), con dificultad progresiva.
- **Bosses:** cada boss es una IA fuerte (Cap. 10) con:
  - Objetivo de victoria específico del encuentro — por ejemplo, 1 contra 1 directo contra el boss, o (si participan varios jugadores humanos) la condición de victoria puede ser que **alguno** de los jugadores humanos alcance cierto puntaje objetivo antes que el boss.
  - Al menos **una penalización temática propia** inyectada como regla adicional de esa partida específica (ejemplos de referencia, a definir en detalle en el mapa de gameplay: "las cartas rojas se queman al robarse", "debes ganarle en X rondas o pierdes", etc.) — estas penalizaciones se implementan como modificadores de partida aplicados sobre el Core Engine estándar, no como cambios permanentes a las reglas base de la Game Bible.
  - Narrativa propia ligada a su encuentro (diálogo, presentación, reacción de The Wild Deck).
- **Puzzles:** retos no necesariamente centrados en ganar una partida completa, sino en situaciones de tablero específicas (a definir en el mapa de gameplay — fuera de alcance de este roadmap hasta ese diseño).
- Este capítulo depende de que Cap. 1–7 (Core Engine completo) y Cap. 10 (IA) estén funcionales antes de poder implementarse con solidez.
- **Nota:** el detalle fino de niveles, bosses concretos, sus penalizaciones específicas y los puzzles se define en un **mapa de gameplay** dedicado, aún no producido — este capítulo del roadmap se actualizará cuando ese documento exista.

### Capítulo 13 — Narrativa integrada

**Objetivo:** integrar el lore de la Game Bible como parte jugable, no solo como texto de fondo.
**Estado:** Pendiente

- Sistema de diálogos/cinemáticas ligeras.
- Reacciones de The Wild Deck ante el comportamiento del jugador (ascenso/penalización, Game Bible 2.2–2.3), y ante los momentos de caos del grito de UNO.
- Puesta en escena de la apertura del Wild Codex antes de cada ronda (Game Bible 2.4): animación/VFX del "libro místico" abriéndose ante cada jugador en privado.
- Estructura de capítulos narrativos ligados a hitos de partidas jugadas y al avance del Modo Campaña (Cap. 12).

### Capítulo 14 — Pulido, QA y lanzamiento

**Estado:** Pendiente

- Balance final de reglas mediante playtesting (las reglas base ya están cerradas en la Game Bible).
- Testing de UX con jugadores reales.
- Optimización de rendimiento (especialmente VFX del Cap. 8, e IA del Cap. 10 en partidas con varios oponentes).
- Preparar builds de exportación (PC / eventualmente móvil).
- Página de itch.io / Steam / repositorio público, según el plan de distribución.

---

## 3. Buenas prácticas recomendadas desde el día uno

- **Git desde el commit 0**, con commits pequeños y descriptivos — igual que en cualquier proyecto web serio.
- **Nunca acoplar lógica de reglas a nodos de UI.** El Core Engine (Cap. 1–2) debe poder correr y testearse sin abrir una sola escena visual. Esto es lo que hace posible el Cap. 11 (multijugador online headless) y el Cap. 10 (IA) más adelante sin reescribir todo.
- **Tests desde el Cap. 1**, no al final. La Cadena y el Jump (Cap. 5) tienen suficiente complejidad de casos límite como para que los tests automatizados ahorren muchísimo tiempo de debugging manual.
- **Documentar cada Wild Card nueva** con el mismo formato desde el principio (aunque solo la programe el propio equipo al inicio) — esto es lo que hará viable el Cap. 9 sin fricción.
- **Modelar `types[]` como array desde el día uno** (sección 1.3), nunca como campo único — es la base de todo el sistema de puntaje acumulativo.
- **Modelar la jerarquía Partida → Ronda → Vuelta → Turno como estados anidados reales** desde el Cap. 2 (sección 1.4) — reescribirla después de que otros sistemas dependan de ella (elementos, persistencia de wilds, quema por ronda, Segundo Enojo) es costoso.
- **Mantener la interfaz GDScript ↔ C# acotada desde el Cap. 10** (sección 0.2) — evitar que la lógica de reglas del Core Engine llegue a depender de C# para funcionar.
- Mantener este roadmap **vivo**: actualizar el campo Estado de cada capítulo, y si es posible, espejarlo en GitHub Projects/Issues para tener trazabilidad visual del avance.

---

## 4. Registro de decisiones pendientes (a resolver antes de programar)

- [x] ~~Confirmar si la pérdida automática por límite de mano (25+ cartas) termina la ronda completa o solo elimina a ese jugador mientras el resto continúa~~ — **Resuelto:** solo ese jugador pierde y queda fuera de la ronda; el resto continúa con normalidad (2 jugadores: gana el que queda en pie). Ver Game Bible 3.6.
- [x] ~~Versión exacta de Godot a fijar como target del proyecto~~ — **Resuelto: Godot 4.7.**
- [x] ~~Decisión de lenguaje: GDScript puro vs. mezcla con C#~~ — **Resuelto: híbrido confirmado.** GDScript para el Core Engine, C# para IA de oponentes (ver sección 0.2 y Cap. 10).
- [x] ~~Alcance del multijugador: ¿local únicamente en la v1, o online desde el inicio?~~ — **Resuelto:** el juego contempla ambos desde el diseño: Partida Rápida local (IA o amigos, hotseat), salas Online, y Modo Campaña local (Cap. 12). El orden de implementación real entre Cap. 11 (Online) y Cap. 12 (Campaña) queda abierto — ver punto siguiente.
- [x] ~~Setup completo del Capítulo 0~~ — **Resuelto:** entorno, repo, estructura y constantes globales completados el 2026-07-10. Repo: https://github.com/im-gitLuv/UnoWilder
- [ ] Catálogo definitivo de tipos de eventos random para el grito de UNO (Cap. 6) — la Game Bible define 4 categorías amplias; falta el detalle fino de cada variante concreta.
- [ ] Orden de prioridad real de implementación entre Cap. 11 (Multijugador Online) y Cap. 12 (Modo Campaña) — ambos están definidos pero no se ha decidido cuál se aborda primero después del Core Engine (Cap. 1–7) y la IA (Cap. 10).
- [ ] Mapa de gameplay del Modo Campaña (Cap. 12): niveles concretos, catálogo de bosses con sus penalizaciones temáticas específicas, y diseño de los puzzles — documento aún no producido.
- [ ] Niveles de dificultad de IA (Cap. 10): cuántos niveles, y el detalle de heurísticas de cada uno.
