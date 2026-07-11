🃏 UnoWilder — Game Bible
Documento de conocimiento maestro — Narrativa, Lore y Reglas Oficiales

Eslogan: UnoWilder — Where every card unleashes chaos. 🔥🃏

0. Cómo usar este documento
   Este archivo es la fuente única de verdad sobre qué ES UnoWilder: su concepto, su mundo y sus reglas. Cualquier decisión de diseño, balance o implementación en Godot debe poder rastrearse hasta una sección de este documento. El archivo hermano UNOWILDER_DEV_ROADMAP.md traduce todo esto en tareas técnicas de desarrollo.
   Las reglas numéricas ya definidas (copias de Wild, puntuación, límite de jugadores) se consideran oficiales. Cualquier punto que quede abierto se marca explícitamente como [NOTA DE IMPLEMENTACIÓN], que no es un desacuerdo de reglas sino un detalle menor a confirmar antes de programarlo.

1. Concepto y Visión
   UnoWilder es una reinvención extrema del clásico UNO: un simulador visualmente impactante donde cada partida se convierte en caos estratégico, lleno de reglas salvajes, efectos cinematográficos, animaciones dinámicas y giros inesperados.
   No es "otro juego de UNO". Es un simulador modular de cartas al estilo de los motores TCG (YuGiOh / EDOPro / YGOPro): existe un motor principal (core engine) que conoce las reglas generales del juego, y cada carta es un módulo independiente que el motor sabe leer, interpretar y ejecutar. Esto permite que, con el tiempo, se añadan nuevas cartas Wild con efectos completamente nuevos sin tener que reescribir el motor — incluyendo cartas creadas por la comunidad.
   Pilares de diseño:

Caos controlado — el azar y la agresividad son parte del núcleo del juego, no un accidente.
Modularidad total — cada carta (especialmente las Wild) es un módulo autocontenido con su propia lógica.
Espectáculo visual — cada jugada relevante dispara una animación o efecto que la hace sentir importante.
Honestidad como mecánica narrativa — The Wild Deck observa el comportamiento del jugador y reacciona.
Extensibilidad comunitaria — el Wild Codex está pensado desde el día uno para recibir cartas hechas por terceros.

2. Lore — "The Wild Deck"
   Género: Cyber-fi / anime tech-fantasy.
   2.1 Premisa
   Un grupo de jóvenes queda atrapado dentro de una consola abandonada, tras insertar un viejo cartucho de un simulador de cartas olvidado. Al encenderlo, el cartucho no los deja salir: los absorbe a un mundo digital decadente construido enteramente alrededor de un único juego. La única forma de escapar es jugar — y jugar bien, en todos los sentidos de la palabra.
   Dentro de este mundo habita The Wild Deck: no es una simple baraja, es una entidad viva, el árbitro y crupier definitivo de cada partida. The Wild Deck lo sabe todo sobre cada jugador: sus dudas, sus máscaras, sus verdaderas intenciones detrás de cada carta jugada. No juzga por las reglas del juego solamente — juzga por la honestidad con la que cada jugador juega su propia partida.
   2.2 La Corrupción Wild
   El mundo dentro del cartucho está siendo consumido por la Corrupción Wild: una plaga digital que borra recuerdos y despoja a las personas de su identidad, devolviéndolas a un estado "salvaje" — impulsivo, vacío, sin memoria de quiénes eran. Cuanto más tiempo pasa alguien atrapado sin enfrentarse a sí mismo a través del juego, más avanza su corrupción.
   The Wild Deck no causa la corrupción, pero la contiene a través de sus reglas: recompensa (asciende) a quienes juegan siendo fieles a sí mismos sin dañar a otros, y castiga (penaliza) a quienes traicionan su propia naturaleza o dañan deliberadamente a los demás para ganar.
   2.3 Tema central

Todos buscamos guardar las apariencias, pero cuando las condiciones internas se alinean, aflora lo que realmente somos.

UnoWilder no dice que "ser uno mismo" sea automáticamente positivo — algunos personajes, al soltar la máscara, revelan una naturaleza dañina. El mensaje que persigue la historia es que es posible ser auténtico sin herir a otros, y que esa autenticidad honesta es, dentro del mundo del juego, la única forma real de escapar.
2.4 Ganchos narrativos disponibles para desarrollo futuro

Cada personaje jugable puede tener una "Carta Wild personal" ligada a su arco narrativo.
The Wild Deck puede tener fragmentos de "voz" o diálogo que reaccionan a la forma de jugar (agresiva, defensiva, oportunista, leal).
La progresión de "ascenso" o "penalización" narrativa puede reflejarse visualmente en el propio cartucho/consola (glitches, restauración de color, etc.).
El caos del grito de UNO (sección 3.11) es también una oportunidad narrativa: The Wild Deck "reacciona" con humor/imprevisibilidad cuando un jugador declara su última carta, como si disfrutara el momento.
Final(es) múltiples en función de cómo el grupo jugó colectivamente, no solo de quién ganó.
La apertura del Wild Codex (mecánica de selección de Wilds, sección 3.5) es un momento visualmente ritual: antes de cada ronda, The Wild Deck "abre" el Codex como quien abre un libro místico envuelto en un aura sobrenatural, y cada jugador es llevado en privado ante sus páginas para escoger sus dos Wild Cards. Es una oportunidad narrativa y de puesta en escena (animación/VFX) recurrente en cada ronda, no solo una pantalla de selección funcional.

(Este documento cubre el abrebocas de lore; personajes, facciones y guion detallado se desarrollarán en un documento narrativo aparte una vez el sistema de reglas esté cerrado.)

3. Reglas Oficiales de UnoWilder (UNOW)
   3.1 The Wild Deck como árbitro
   En términos de reglas (no solo de lore), The Wild Deck es un módulo separado del motor: actúa como crupier/árbitro. Es quien pregunta a los jugadores por sus Wild Cards antes de la ronda, arma y baraja la baraja de partida, revela la primera carta, valida las jugadas, resuelve la Cadena, aplica las remezclas y calcula puntuaciones. Ningún jugador manipula la baraja directamente — todo pasa "a través" de The Wild Deck.
   Límite técnico de jugadores: UnoWilder soporta partidas de 2 a 8 jugadores.
   3.2 Jerarquía temporal: Partida, Ronda, Vuelta y Turno
   UnoWilder distingue cuatro unidades de tiempo de juego, cada una contenida dentro de la anterior. Esta jerarquía es la base de reglas como la duración de los efectos elementales o la persistencia de las Wild Cards entre rondas, así que se define aquí de forma explícita antes de cualquier otra regla.
   UnidadDefiniciónTermina cuando...PartidaLa sucesión completa de todas las rondas, hasta que alguien gana.Un jugador alcanza el puntaje objetivo definido al inicio de la partida, o se activa el cierre de partida por Segundo Enojo de The Wild Deck (ver 3.6).RondaUna sucesión de Vueltas dentro de la partida.Un jugador la gana (ej. llega a "UNO" y se queda sin cartas) o la pierde (ej. acumula 25+ cartas, o pierde por Remezcla doble).VueltaUna sucesión de Turnos, contada desde el primer jugador de la ronda hasta que el turno vuelve a caer sobre ese mismo jugador. La Vuelta tiene prioridad sobre el Turno individual: el ciclo se completa en cuanto el turno recorre a todos los jugadores y regresa al primero, sin importar si alguno de ellos fue saltado por un Skip, un conteo de Jump, un Reverse, o cualquier otro efecto — un jugador saltado igual "cuenta" como recorrido dentro de esa Vuelta.El turno vuelve a caer sobre el jugador que abrió esa Vuelta, sin importar cuántos Turnos individuales se hayan saltado en el camino.TurnoEl momento puntual en que a un jugador le corresponde jugar.El jugador juega, descarta, o pierde el turno por efecto de una carta.
   Regla derivada clave: un efecto que dice "dura X vueltas" permanece activo sobre el jugador afectado hasta que a ese jugador le vuelva a tocar jugar X veces — no se mide en turnos ajenos, sino en cuántas veces ese jugador específico vuelve a tener su Turno.
   Regla derivada clave (prioridad de la Vuelta sobre el Turno): como la Vuelta se completa por el recorrido del ciclo completo y no por que cada jugador individual haya tenido su Turno, es posible que un jugador saltado durante la primera Vuelta nunca llegue a jugar mientras esa Vuelta esté activa. Esto tiene una consecuencia directa sobre la ventana de quema inicial (ver 3.4): si la primera Vuelta se completa sin que a ese jugador le haya tocado su Turno, pierde la oportunidad de quemar en esa ronda, aunque su primer Turno jugable ocurra ya en la segunda Vuelta.
   Regla derivada clave (persistencia entre rondas): las Wild Cards elegidas en una ronda no se devuelven al Wild Codex al terminar esa ronda: las copias que no se quemaron durante la ronda siguen dentro de The Deck, mezcladas y ocultas, disponibles para seguir apareciendo en las rondas siguientes de la misma partida. Ver el detalle completo en la sección 3.5.
   3.3 Terminología clave de acciones sobre cartas
   Estos cuatro verbos tienen significados precisos y distintos dentro de UnoWilder, y toda la lógica de reglas se apoya en esta distinción:
   AcciónQué pasa con la carta¿Aplica su efecto?¿Puede volver a jugarse en la partida?JugarSe manda a la pila de descartes desde la mano de un jugador, como acción normal de turno.Sí, siempre se aplica su efecto normal.Sí (puede volver por una Remezcla).DescartarSe manda a la pila de descartes, normalmente forzado por el efecto de otra carta (ej. "descarta 3 amarillas").No. Se ignora color y efecto por completo, sea carta numérica, de efecto o Wild. El siguiente jugador juega con total libertad.Sí (puede volver por una Remezcla).QuemarSe retira boca abajo a una pila de quemadas, completamente separada de la pila de descartes.No aplica (la carta ni siquiera se juega).No, nunca más — queda fuera de la partida por completo.RemezclarThe Wild Deck toma toda la pila de descartes y la vuelve a barajar como nueva pila de robo.No aplica un efecto por sí misma; es una acción administrativa de The Wild Deck.—
   Reglas derivadas importantes:

Las cartas quemadas nunca otorgan ni cuestan puntos a nadie, en ningún momento de la partida — desaparecen del cómputo por completo.
Descartar es la herramienta que usa The Wild Deck (a través de ciertos efectos Wild) para anular estrategias de un jugador que esté reteniendo una carta clave en mano: como no se aplica ningún efecto ni se respeta el color, no hay forma de "proteger" una carta de un descarte forzado.

3.4 Reparto inicial y quema de cartas (una vez por ronda, ventana: primera Vuelta)

Cada jugador recibe 7 cartas al inicio de cada ronda, como en el UNO clásico.
En cada ronda (no solo en la primera de la partida), cada jugador tiene la oportunidad de quemar (ver definición en 3.3) una cantidad x de sus cartas iniciales, una única vez por ronda.
Por cada carta quemada, The Wild Deck le entrega x + 1 cartas nuevas.

Ejemplo: si un jugador quema 2 cartas, recibe 3 nuevas a cambio (una ganancia neta de +1 carta en mano).

La ventana para quemar es la primera Vuelta de la ronda, no el primer Turno de cada jugador. Esta distinción es importante porque las Vueltas tienen prioridad sobre los Turnos individuales (ver jerarquía temporal, 3.2): una Vuelta se completa cuando el turno recorre a todos los jugadores desde el primer jugador de la ronda hasta volver a él — sin importar si algún jugador fue saltado por un Skip, un conteo de Jump, un Reverse, o cualquier otro efecto.

Esto significa que si un jugador es saltado durante la primera Vuelta y nunca llega a tener su Turno mientras esa Vuelta está en curso, pierde la oportunidad de quemar en esa ronda — aunque cuando finalmente le toque jugar (ya en la segunda Vuelta), la ventana ya se cerró.
Ejemplo: en una ronda de 4 jugadores (A, B, C, D), empieza A. A decide no quemar. A juega un Skip que salta a B, pasando el turno directo a C. C sí tiene su turno dentro de la primera Vuelta y puede decidir si quema o no. El turno continúa y eventualmente vuelve a caer sobre A — en ese momento la primera Vuelta se completa (todos los jugadores, incluido el saltado B, ya fueron "recorridos" por el ciclo). B nunca tuvo su Turno durante esa primera Vuelta, así que ya no puede quemar en el resto de esa ronda, aunque su primer Turno jugable ocurra recién en la segunda Vuelta.

Fuera de la ventana de la primera Vuelta de cada ronda, esta mecánica no está disponible — es un evento que ocurre como máximo una vez por jugador, por ronda.
Las cartas quemadas en este paso quedan fuera de la partida para siempre (nunca cuentan puntos, nunca vuelven a aparecer, ni siquiera vía Remezcla).

3.5 Selección de Wild Cards pre-ronda

Antes de cada ronda, The Wild Deck pregunta en privado/secreto y de forma secuencial (uno por uno, nunca simultánea) a cada jugador qué dos Cartas Wild quiere incluir en la partida, eligiéndolas del Wild Codex.
Orden de selección: el jugador que ganó la ronda anterior elige primero; a partir de ahí, se continúa en sentido horario. En la primera ronda de la partida (sin ganador previo), el orden se define aleatoriamente o por posición de asiento.
Preguntar uno por uno (y no todos a la vez) existe específicamente para que no se repitan selecciones entre jugadores dentro de la misma ronda — cada Wild Card elegida en el Wild Codex queda "tomada" para esa ronda de selección y no puede ser vuelta a elegir por otro jugador en esa misma tanda.
Esta elección es estratégica y de riesgo: la carta que un jugador elige puede terminar beneficiando a un oponente, ya que cualquier jugador puede recibirla, robarla o que le sea jugada en su contra según el efecto.
Cantidad de copias (regla oficial): por cada Wild Card seleccionada, The Wild Deck inserta 4 copias en la baraja de la partida. Como cada jugador selecciona 2 Wild Cards distintas, esto equivale a 8 copias de Wild Cards por jugador añadidas a la baraja.

Ejemplo (2 jugadores): 2 jugadores × 2 wilds × 4 copias = 16 Wild Cards en The Deck para esa ronda.
Fórmula general: Wilds nuevas insertadas por ronda = jugadores × 2 × 4 = jugadores × 8.

Persistencia entre rondas: al terminar una ronda, las Wild Cards seleccionadas no se devuelven al Wild Codex. Todas las copias que no fueron quemadas durante la ronda permanecen dentro de The Deck, se remezclan junto con el resto de la baraja, y siguen disponibles para aparecer en las rondas siguientes de la misma partida.
El Wild Codex solo se "abre" de nuevo para elegir cartas nuevas que añadir — nunca para retirar lo ya elegido. Cada ronda nueva simplemente suma las Wild Cards recién seleccionadas por cada jugador a las que ya estaban circulando desde rondas anteriores.
Esto mantiene el misterio de fondo durante toda la partida: un jugador solo conoce con certeza las wilds que él mismo eligió (en cualquier ronda) y las que ya se han revelado en mesa; nunca conoce el pool completo que su oponente fue seleccionando ronda tras ronda.
Ciclo persistente de The Wild Deck entre Rondas: al terminar una Ronda se calcula y otorga su puntuación. Si la Partida no ha terminado, toda carta no quemada —las cartas de las manos, de la pila de descartes y de la pila de robo— vuelve a The Wild Deck como un único mazo persistente. The Wild Deck conserva memoria de las copias Wild que han entrado y de todas las cartas quemadas, que nunca regresan. Antes del siguiente reparto de 7 cartas, el Wild Codex se abre de nuevo y las Wild Cards recién seleccionadas se añaden a ese mismo mazo persistente; solo entonces The Wild Deck lo baraja y comienza la nueva Ronda.
Ejemplo: en una partida de 2 jugadores, en la Ronda 1 el Jugador A elige Draw 4 y Wild Shift, y el Jugador B elige Draw 6 y Reverse Wild. Durante la Ronda 1 se queman las 4 copias de Wild Shift y 2 de las 4 copias de Reverse Wild. Al empezar la Ronda 2, The Deck ya no tiene ninguna copia de Wild Shift en circulación (se quemaron todas), pero sí conserva las 2 copias restantes de Reverse Wild mezcladas en la baraja, más las 4 copias de Draw 6 que no se quemaron. A esto se le suman las Wild Cards nuevas que A y B elijan para la Ronda 2.

3.6 Flujo básico de turno

Arranque de la primera Vuelta: una vez seleccionadas e insertadas todas las Wild Cards, The Wild Deck baraja frenéticamente toda la baraja de partida y revela la primera carta en la pila de descartes.

Sea cual sea esa carta, su efecto se aplica de inmediato como si The Wild Deck mismo la hubiera "jugado" contra el primer jugador en turno.
Ejemplo: si sale un Draw 2, el primer jugador roba 2 cartas o puede iniciar la Cadena (ver 3.8) si tiene con qué responder.
Ejemplo: si sale un Skip, el primer jugador pierde su turno inaugural y el segundo jugador comienza a jugar.
Ejemplo: si sale un Reverse, el primer jugador juega con normalidad, pero el sentido de la Vuelta cambia, y el siguiente jugador pasa a ser el del sentido opuesto.
Ejemplo: si sale una Wild Card, The Wild Deck escoge el color de forma aleatoria y aplica el efecto adicional de esa carta según corresponda; el juego procede con normalidad.

Se juega en el sentido de las manecillas del reloj (puede invertirse con Reverse).
En su turno, el jugador debe jugar una carta que coincida en color, número o efecto con la carta superior del descarte, o una carta Wild.
Si un jugador no puede jugar, roba cartas de forma continua hasta conseguir una carta jugable en su mano (no se limita a robar solo 1). En cuanto consigue una carta jugable, la juega siguiendo el flujo normal de turno.

Si durante la ronda, por este motivo o por cualquier otro, la baraja de robo se agota, se dispara una Remezcla (ver abajo).
Si en este proceso el jugador llega a acumular 25 cartas o más en mano, pierde automáticamente la ronda (ver regla de límite de mano, más abajo).

Remezcla: si The Wild Deck se queda sin cartas para robar, toma toda la pila de descartes (todo lo que fue jugado o descartado, nunca lo quemado) y la vuelve a barajar como nueva pila de robo. Esto solo puede ocurrir una vez por ronda sin consecuencias adicionales.

Si The Wild Deck se queda sin cartas por segunda vez en la misma ronda, se "enoja" (Primer Enojo): quema una tercera parte de la pila de descartes, elegida al azar, y da la ronda por finalizada de inmediato.

Redondeo del Primer Enojo: la cantidad a Quemar se calcula como el tercio de la pila de descartes y se redondea al entero más cercano; todo valor decimal de `.5` o superior sube al entero siguiente. Ejemplos: 5 / 3 = 1.67, por lo que se Quemar 2 cartas; 4 / 3 = 1.33, por lo que se Quema 1 carta.

En ese caso, gana la ronda quien tenga menos cartas en mano en ese momento.
Si hay empate en cantidad de cartas, gana quien tenga menor puntaje acumulado en su mano (usando la tabla de puntuación de la sección 3.12).
El ganador de la ronda por esta vía se lleva el puntaje de todos sus oponentes, exactamente como si hubiera ganado la ronda de forma normal.

Regla especial — Segundo Enojo (cierre de partida): si este patrón de remezcla doble vuelve a ocurrir en otra ronda posterior de la misma partida (es decir, ya sucedió una vez en alguna ronda anterior y vuelve a suceder en una ronda distinta), The Wild Deck se enoja de forma mucho más notoria: en vez de quemar solo un tercio, quema toda la pila de descartes (todo el deck de esa ronda), la ronda termina de inmediato, y además se da por finalizada la partida completa en ese mismo momento.

Esa última ronda la gana el jugador con menos puntaje acumulado en su mano en ese momento (misma lógica de desempate que el Primer Enojo).
La partida completa la gana el jugador con más puntos acumulados hasta ese momento (sumando todas las rondas jugadas hasta entonces), no necesariamente quien ganó esa última ronda.
Ejemplo: en la Ronda 3 de una partida, ocurre una Remezcla, todo transcurre con normalidad; pero luego, en esa misma Ronda 3, ocurre una segunda Remezcla — The Wild Deck tiene su Primer Enojo: quema un tercio de la pila de descartes al azar, y la Ronda 3 termina (gana quien tenga menos cartas, o menor puntaje en caso de empate). La Ronda 4 transcurre con total normalidad, sin remezclas. En la Ronda 5 ocurre una Remezcla simple sin problema; pero si en esa misma Ronda 5 vuelve a ocurrir otra Remezcla, The Wild Deck tiene su Segundo Enojo: quema toda la pila, se aplican los puntajes correspondientes de esa ronda, y la partida completa se da por finalizada, ganando quien tenga más puntos acumulados en total.

Límite de mano — pérdida automática: cualquier jugador que acumule 25 cartas o más en su mano (sin importar el motivo — ya sea por robo continuo al no poder jugar, o por recibir una Cadena grande) pierde esa ronda automáticamente, y todas sus cartas (las que tenía en mano) se queman (no se descartan, no otorgan puntos a nadie).

Confirmado, sin nota abierta: en partidas de más de 2 jugadores, si solo un jugador alcanza este límite, únicamente ese jugador pierde y queda fuera de la ronda — la ronda continúa con total normalidad entre los jugadores restantes. Solo si llega a quedar un único jugador en pie, ese jugador gana la ronda por defecto.
En una partida de exactamente 2 jugadores, si uno de los dos alcanza el límite de 25+ cartas, la ronda termina de inmediato y gana el único jugador que queda en pie.
Al ser cartas quemadas, no otorgan puntos a nadie por regla general (ver 3.3): el ganador de la ronda por esta vía no recibe un bono de puntuación por las cartas quemadas del jugador eliminado, salvo que The Wild Deck decida otorgar un bono narrativo como parte de su "actuación" en la partida (ver Capítulo 13, Narrativa integrada, en el Roadmap — mecánica opcional, no una regla base).

Al quedarle 1 carta en mano, el jugador debe declararlo ("¡UNO!"), lo cual dispara el efecto de caos descrito en 3.11.

3.7 Jump — Mecánica de combo y conteo
Jump es mucho más que un "Skip mejorado": funciona como un acelerador de jugada que permite encadenar una segunda carta en el mismo turno.

Al jugar una carta Jump, el jugador tiene derecho a jugar inmediatamente una segunda carta, que debe ser del mismo color que el Jump, o una carta Wild.
Si la segunda carta es una carta numérica, se activa una mecánica especial de conteo: The Wild Deck cuenta, empezando por el siguiente jugador en el orden de turno, tantas posiciones como indique el número jugado. El jugador donde "cae" la cuenta es quien recibe el turno.

Ejemplo con 3 jugadores (A, B, C), turno de A: A juega Jump y luego un 2. The Wild Deck cuenta: B = 1, C = 2 → el turno pasa a C (equivalente en efecto a un Skip sobre B, pero es resultado del conteo, no un Skip real).
Mismo ejemplo pero A juega Jump y luego un 3: B = 1, C = 2, A = 3 → el turno vuelve a caer sobre A, quien puede seguir jugando en combo.
Mismo ejemplo pero A juega Jump y luego un 4: B = 1, C = 2, A = 3, B = 4 → el turno cae sobre B.
La cuenta es cíclica: si el número supera la cantidad de jugadores, simplemente se sigue contando dando la vuelta a la mesa tantas veces como haga falta.

Si la segunda carta es una carta de efecto del mismo color o una Wild, se resuelve con sus reglas normales (no aplica el conteo especial — el conteo es exclusivo de la combinación Jump + carta numérica).
Este mecanismo convierte a Jump en una herramienta de control de turno muy versátil: bien usado, permite recuperar el turno propio (combo) o saltar estratégicamente a un jugador específico según el número disponible en mano.

3.8 La Regla de la Cadena (The Chain)
Este es el corazón mecánico de UnoWilder.

UnoWilder introduce múltiples tipos de cartas de robo, no solo Draw 2 y Wild Draw 4: existen Draw 1, Draw 2, Wild Draw 5, 6, 8, 10 y 12.
Cuando un jugador juega cualquier carta con capacidad de robo (aunque sea Draw 1), se activa The Chain.
El jugador amenazado (el siguiente en turno, que recibiría el robo) tiene la opción de responder con cualquier carta tipo Draw que posea en mano, sin importar su valor. Cada respuesta suma su valor de robo al total acumulado de The Chain.

Si responde, su carta se suma a la cadena (el valor de robo acumulado aumenta y/o se traslada la amenaza al siguiente jugador).
La cadena continúa pasando de jugador en jugador mientras cada uno pueda responder.

La cadena termina cuando un jugador no puede responder, ya sea porque:

No tiene ninguna carta tipo Draw en mano, o
Solo tiene cartas Draw de valor inferior al acumulado, o
No tiene una carta Reverse válida para redirigir la cadena (ver 3.9).

Ese jugador es quien finalmente roba todas las cartas acumuladas en la cadena (sujeto al efecto Fire si lo tiene activo, ver 3.10). Después de recibir ese robo, pierde su Turno: no puede jugar una carta en ese mismo Turno y el juego continúa con el siguiente jugador según la dirección activa.

3.9 Reverse Card — Redirección de la Cadena

Si el jugador que está a punto de recibir toda la cadena posee una carta Reverse del color correspondiente, puede jugarla como respuesta. Una Wild Card que posea el efecto Reverse cuenta como Reverse una vez que su color haya sido declarado.
Efecto: la dirección del turno se invierte y la cadena completa recae sobre el jugador anterior (el penúltimo en la secuencia de la cadena) en lugar de sobre quien jugó el Reverse. The Chain no termina: el jugador redirigido conserva la oportunidad de responder con cualquier Draw o con otro Reverse válido. El Reverse se registra como un eslabón de la Chain, pero no suma cartas al valor de robo acumulado.
Esto convierte al Reverse en una pieza defensiva de altísimo valor táctico dentro de la Cadena, más allá de su función clásica de invertir el sentido del juego.

3.10 Sistema Elemental (efectos de las Wild Cards)
Las Wild Cards pueden imponer estados elementales sobre la partida, afectando a uno, varios o todos los jugadores. En todos los casos, el disparador es jugar una carta del color correspondiente durante la Vuelta activa, y el efecto se aplica sobre ese jugador durante un número X de Vueltas — donde X lo define la carta o efecto que originó el elemento, medido según la unidad "Vuelta" descrita en 3.2 (es decir, hasta que a ese jugador le vuelva a tocar jugar X veces).
🔥 Fire

Disparador: jugar una carta roja durante la Vuelta.
Efecto: el jugador queda inmune a robos durante su duración. Definición precisa: si a este jugador le toca robar cartas — ya sea porque no puede responder en una Cadena, o porque en su Turno no tiene una jugada válida — cada carta que robe se quema inmediatamente en vez de sumarse a su mano. Si está robando en busca de una carta jugable, sigue robando y quemando una a una hasta encontrar una que sí pueda jugar; esa la juega con normalidad.

💧 Water

Disparador: jugar una carta azul durante la Vuelta.
Efecto: cada vez que el jugador con este efecto activo juega una carta azul, los jugadores adyacentes deben descartar (sin efecto, ver 3.3) una Wild Card de su mano. Si un jugador adyacente no tiene ninguna Wild en mano, en su lugar descarta 2 cartas al azar. Si, como consecuencia de este descarte forzado, un jugador adyacente se queda sin cartas en la mano, no gana la ronda por ello — en su lugar, roba 2 cartas de inmediato.

🌿 Nature

Disparador: un oponente juega una carta verde durante la Vuelta.
Efecto: mientras este efecto esté activo, el jugador puede jugar dos veces en su Turno con solo jugar una carta verde (no acumulable — no se puede volver a activar sobre sí mismo mientras ya está activo). Como contrapartida, mientras el efecto está activo, todos los jugadores deben robar una carta antes de jugar en cada uno de sus turnos, siempre que la carta superior de la pila de descarte sea de color verde.

☀️ Light

Disparador: jugar una carta amarilla durante la Vuelta.
Efecto: el jugador observa en privado la mano de un oponente — esta visión es exclusiva de quien activó el efecto; el oponente no revela su mano al resto de la mesa. Si esa mano contiene al menos una carta amarilla, el jugador puede elegir cualquier carta de esa mano (no necesariamente la amarilla) y jugarla como si fuera propia. Si el oponente no tiene ninguna carta amarilla, el jugador solo obtiene la información visual — no puede seleccionar ni jugar ninguna carta de esa mano.

Reglas comunes a los cuatro elementos base:

El disparador siempre es jugar una carta del color correspondiente durante la Vuelta activa.
La duración (X Vueltas) la determina siempre la carta u efecto Wild que invoca el elemento — nunca es un valor fijo del propio elemento.
Una sola Wild Card puede aplicar un elemento a uno o varios jugadores a la vez, según su propia definición.
Los elementos son, en esencia, un framework de tags/estados temporales invocable por cualquier Wild Card — el Wild Codex puede introducir elementos nuevos en el futuro sin tocar el motor.

3.11 Grito de UNO — Caos garantizado
Cuando un jugador declara "¡UNO!" al quedarle una sola carta en mano, The Wild Deck siempre reacciona con un efecto aleatorio. Nunca es un simple trámite: cada grito de UNO dispara uno de los siguientes tipos de reacción, elegido al azar por The Wild Deck:

Aplica un efecto aleatorio a un número aleatorio de jugadores (puede incluir o no al propio jugador que gritó UNO).
Regala una carta a un jugador (cualquiera, no necesariamente quien gritó UNO).
Fuerza a uno o más jugadores a descartar cartas (sin efecto, según la definición de "Descartar" en 3.3).
Modifica el color de juego activo.

Esta reacción es parte del ADN caótico de UnoWilder: siempre pasa algo raro cuando alguien grita UNO, lo cual desalienta jugar de forma puramente "segura" y mantiene la tensión hasta el final de cada ronda.
3.12 Puntuación
UnoWilder se juega por rondas, hasta que un jugador alcanza una cantidad de puntos objetivo (configurable por partida, como en las reglas clásicas de UNO).
Valor base por tipo de característica:
Tipo de característicaValorNúmero 010 ptsNúmero 1–9Su propio númeroEfecto de color (Skip, Reverse, Jump, Exchange)20 ptsDraw N (capacidad de robo)N × 2 ptsWild (base, por ser carta comodín)50 pts
Regla clave — el puntaje es acumulativo por tipo: una carta puede tener más de un tipo a la vez, y su puntaje final es la suma de los valores de cada tipo que posea. Esto es especialmente relevante para las Wild Cards, que casi siempre combinan el tipo "Wild" con al menos otro tipo (Draw, o efecto de color).
Ejemplos:
CartaTipos que poseeCálculoPuntaje totalDraw 2 normal (no wild)Draw 22 × 24 ptsSkip normal (no wild)Efecto de color—20 ptsWild Draw 4 (clásica)Wild + Draw 450 + (4 × 2)58 ptsWild Draw 12Wild + Draw 1250 + (12 × 2)74 ptsWild ReverseWild + Efecto de color50 + 2070 ptsWild SkipWild + Efecto de color50 + 2070 ptsWild Shift (Wild simple/clásica)Solo Wild5050 pts
Esta lógica de "tipos acumulables" debe modelarse en el motor como una lista de tipos por carta (no un único campo type), de forma que cualquier Wild Card nueva —incluidas las creadas por la comunidad— pueda declarar cualquier combinación de tipos y el motor calcule su puntaje automáticamente sin lógica especial por carta. Ver detalle técnico en el roadmap, Capítulo 1 y Capítulo 7.
Al finalizar una ronda de forma normal, el ganador suma los valores de todas las cartas que quedaron en mano de sus oponentes (las cartas quemadas nunca se cuentan — ver 3.3). Para el caso especial de fin de ronda por doble Remezcla, ver la regla en 3.6.

4. Composición de The Deck (baraja estándar)
   4.1 Cartas de color / numéricas

4 colores: Rojo, Azul, Amarillo, Verde.
Cada color: números 0–9, 2 copias de cada número.

10 números × 2 copias × 4 colores = 80 cartas numéricas.

4.2 Cartas de efecto de color

Por cada color: Skip, Reverse, Draw 1, Draw 2, Jump, Exchange — 6 tipos, 2 copias de cada uno.

6 tipos × 2 copias × 4 colores = 48 cartas de efecto.

4.3 Total del núcleo estándar

80 (números) + 48 (efecto) = 128 cartas en el mazo estándar base, antes de añadir Wilds.

4.4 Wild Cards de la partida (regla oficial)

Cada jugador elige 2 Wild Cards del Wild Codex antes de cada ronda, en el orden descrito en 3.5 (ganador de la ronda anterior primero, luego sentido horario).
Por cada Wild Card seleccionada, The Wild Deck inserta 4 copias en la baraja de esa ronda.
Esto equivale a 8 copias de Wild Cards por jugador, por ronda.
Fórmula general: Wilds nuevas insertadas por ronda = jugadores × 8 (jugadores × 2 wilds × 4 copias).
Ejemplo con 2 jugadores: 2 × 8 = 16 Wild Cards insertadas en The Deck en esa ronda.
Ejemplo con 8 jugadores (máximo soportado): 8 × 8 = 64 Wild Cards insertadas en esa ronda, sobre una base de 128 cartas estándar.
Recordar que estas Wilds se acumulan entre rondas (ver 3.5, punto 6): el total de Wilds en circulación en una partida avanzada puede ser mayor a lo insertado en una sola ronda, salvo las que ya se hayan quemado.

5. Catálogo de tipos de carta
   5.1 Cartas numéricas (Rojo/Azul/Amarillo/Verde, 0–9)
   Sin efecto especial; se juegan por coincidencia de color o número.
   5.2 Cartas de efecto clásico (por color)

Skip — el siguiente jugador pierde su turno.
Reverse — invierte el sentido de juego (y puede redirigir la Cadena, ver 3.9).
Jump — permite jugar una segunda carta en el mismo turno; si esa segunda carta es numérica, activa la mecánica de conteo descrita en 3.7.
Exchange — intercambia la mano completa con otro jugador.
Draw 1 — el siguiente jugador roba 1 carta (puede iniciar/alimentar la Cadena).
Draw 2 — el siguiente jugador roba 2 cartas (puede iniciar/alimentar la Cadena).

5.3 Wild Cards (siempre de color negro/comodín)

Son las únicas cartas seleccionables desde el Wild Codex.
Cambian el color de juego a elección de quien la juega.
Son inmunes a efectos que dependan de un color (por definición, no tienen color propio hasta que se declara uno).
Pueden llevar asociados: valores de robo elevados (Wild Draw 5/6/8/10/12), efectos de color (Wild Skip, Wild Reverse), efectos elementales (ver 3.10), o efectos completamente personalizados definidos por su módulo.
Su puntaje se calcula sumando el valor de todos los tipos que posea (ver tabla de la sección 3.12).
La comunidad puede crear y programar sus propias Wild Cards siguiendo la especificación técnica del Wild Codex (ver UNOWILDER_DEV_ROADMAP.md, Capítulo 9).

5.3.1 Wild Shift — la Wild canónica básica
Wild Shift es la Wild Card más simple del juego: su único efecto es cambiar el color de juego, como cualquier Wild, pero sin ningún efecto adicional (ni robo, ni efecto de color, ni elemento). Es la Wild "clásica" de referencia, y sirve como caso base del sistema de tipos: al no tener más tipo que WILD, vale exactamente 50 puntos (ver tabla de la sección 3.12). Cualquier otra Wild Card se entiende como "Wild Shift + [tipos adicionales]".

6. Glosario rápido

The Wild Deck — entidad/árbitro que gestiona la baraja, las reglas y observa la honestidad de los jugadores.
Partida — la sucesión completa de rondas hasta que alguien alcanza el puntaje objetivo, o hasta que se activa el cierre por Segundo Enojo de The Wild Deck (ver 3.6).
Ronda — sucesión de Vueltas dentro de una partida; se gana o se pierde de forma independiente (ver 3.2).
Vuelta — sucesión de Turnos, contada desde el primer jugador de la ronda hasta que el turno vuelve a caer sobre ese mismo jugador; tiene prioridad sobre el Turno individual (un jugador saltado igual "cuenta" como recorrido). Unidad en la que se mide la duración de los efectos elementales y la ventana de la quema inicial (3.4).
Turno — el momento puntual en que un jugador juega, descarta o pierde su oportunidad de jugar.
Jugar — mandar una carta a la pila de descartes desde la mano, aplicando su efecto normal.
Descartar — mandar una carta a la pila de descartes por la fuerza de otro efecto, sin aplicar su color ni su efecto propio.
Quemar — retirar una carta boca abajo a la pila de quemadas; queda fuera de la partida para siempre y nunca otorga puntos.
Remezclar — acción de The Wild Deck de tomar la pila de descartes y convertirla en nueva pila de robo cuando esta se agota (una vez por ronda sin consecuencias; la segunda vez en la misma ronda dispara el Primer Enojo; si el patrón de doble remezcla se repite en otra ronda posterior de la misma partida, dispara el Segundo Enojo y cierra la partida — ver 3.6).
The Chain — cadena de respuestas encadenadas a una carta de robo.
Wild Codex — repositorio de Wild Cards, oficiales y creadas por la comunidad; The Wild Deck lo "abre" en privado ante cada jugador antes de cada ronda como parte de la puesta en escena narrativa (ver 2.4).
Wild Shift — la Wild Card básica/canónica: solo cambia el color, sin efectos adicionales. Vale 50 pts.
Corrupción Wild — plaga narrativa que borra memoria e identidad dentro del mundo de UnoWilder.
Elemento (Fire/Water/Nature/Light) — estado temporal que una Wild Card puede imponer sobre uno o varios jugadores, medido en Vueltas.
Quema inicial — mecánica de quema + reposición disponible una vez por ronda (no una vez por partida), limitada a la ventana de la primera Vuelta de esa ronda.
Primer Enojo — reacción de The Wild Deck ante una segunda Remezcla en la misma ronda: quema un tercio aleatorio de la pila de descartes y termina esa ronda de inmediato.
Segundo Enojo — reacción de The Wild Deck cuando el patrón de doble Remezcla se repite en una ronda posterior distinta dentro de la misma partida: quema toda la pila de descartes, termina esa ronda, y cierra la partida completa, dando la victoria a quien tenga más puntos acumulados.

7. Próximos documentos a derivar de esta biblia

Documento narrativo extendido (personajes, facciones, guion).
Especificación técnica formal del Wild Codex (schema de cartas, ver roadmap Cap. 9).
Documento de balance numérico fino (ajustes tras playtesting; las reglas base ya están cerradas en este documento).
