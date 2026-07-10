# 🃏 UnoWilder

A mechanically expanded, visually cinematic reimagining of UNO, built in Godot 4.x.

**Status:** Pre-production (Capítulo 0 setup complete)

## Proyecto

- **Game Bible:** [docs/UNOWILDER_GAME_BIBLE.md](docs/UNOWILDER_GAME_BIBLE.md)
- **Dev Roadmap:** [docs/UNOWILDER_DEV_ROADMAP.md](docs/UNOWILDER_DEV_ROADMAP.md)

## Requisitos

- **Godot 4.7** (con soporte .NET/C#)
- **GUT** (testing framework, instalado vía AssetLib)
- **Git**

## Instalación & Setup

1. Clona este repositorio:

```bash
   git clone https://github.com/im-gitLuv/UnoWilder.git
   cd UnoWilder
```

2. Abre el proyecto en Godot 4.7.

3. (Más instrucciones conforme avance el desarrollo)

## Estructura del proyecto

- `autoloads/` — Singletons (WildDeck, GameState, EventBus, RandomEventManager)
- `core/` — Lógica de reglas (modelos de datos, máquina de estados, turnos)
- `cards/` — Sistema modular de cartas (base, estándar, Wild Codex)
- `ui/` — Interfaz visual (pantallas y componentes)
- `narrative/` — Narrativa integrada (Cap. 13)
- `tests/` — Tests unitarios con GUT

## Licencia

(A definir — por ahora sin licencia oficial)

---

_Last updated: [July 9 - 2026]_
