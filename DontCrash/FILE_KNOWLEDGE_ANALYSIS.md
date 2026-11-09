# Don't Crash!! — File Knowledge Analysis

> Files sorted by **ascending disk size**.  
> Each entry lists: role, size, and knowledge points / techniques used.  
> Generated for study / Development Report reference. Date: 2026-11-09 (Asia/Shanghai).

---

## Index (small → large)

| # | File | Size (bytes) |
|---|------|-------------:|
| 1 | `data/alien_orange.png` | 323 |
| 2 | `data/alien_purple.png` | 323 |
| 3 | `data/alien_green.png` | 326 |
| 4 | `GameEntity.pde` | 398 |
| 5 | `WorldObject.pde` | 837 |
| 6 | `HealthPack.pde` | 998 |
| 7 | `Bullet.pde` | 1102 |
| 8 | `MovingObstacle.pde` | 1283 |
| 9 | `ScoreManager.pde` | 1678 |
| 10 | `Explosion.pde` | 1771 |
| 11 | `FastObstacle.pde` | 1862 |
| 12 | `Player.pde` | 3177 |
| 13 | `Obstacle.pde` | 3500 |
| 14 | `DEVELOPMENT_NOTES.md` | 6705 |
| 15 | `DontCrash.pde` | 11916 |
| 16 | `data/player_ship.png` | 13970 |

Empty folder (not a file): `screenshots/`

---

## 1. `data/alien_orange.png` (323 B)

**Role:** Sprite for FastObstacle (orange alien).

**Knowledge points:**
- Game asset / resource file in Processing `data/` folder
- `PImage` + `loadImage("alien_orange.png")` + `image()`
- Transparent PNG for overlay on game background
- Visual distinction of obstacle **subtypes** (inheritance band)

---

## 2. `data/alien_purple.png` (323 B)

**Role:** Sprite for MovingObstacle (purple zig-zag alien).

**Knowledge points:**
- Same asset pipeline as above (`data/`, `PImage`)
- Different colour asset to mark a different subclass behaviour
- Image vs procedural drawing trade-off (here: simple generated PNG)

---

## 3. `data/alien_green.png` (326 B)

**Role:** Sprite for base `Obstacle` (normal wanderer).

**Knowledge points:**
- Default obstacle appearance for the superclass type
- Resource naming convention by entity type
- Loaded once in `setup()`, reused by many objects (memory-friendly)

---

## 4. `GameEntity.pde` (398 B)

**Role:** Common **interface** for most game objects (80%+).

**Knowledge points:**
- Java / Processing **`interface`**
- Method contracts only: `update()`, `display()`, `moveBy()`, `isFinished()`
- Enables **polymorphism**: `ArrayList<GameEntity>` can hold mixed types
- Separation of “what an entity can do” from “how it does it”
- Supports marking band: Interface / Abstract Class

---

## 5. `WorldObject.pde` (837 B)

**Role:** **Abstract class** implementing `GameEntity`; shared world-space logic.

**Knowledge points:**
- **`abstract class`**
- `implements GameEntity`
- Shared fields: `x`, `y`, `size`
- Constructor + inheritance of common behaviour
- Concrete method: `moveBy()`, `isOffScreen()`, default `isFinished()`
- **`abstract` methods**: `update()`, `display()` (subclasses must implement)
- Encapsulation of screen-boundary test (margin)
- Code reuse / DRY for Obstacle, HealthPack, Bullet, Explosion

---

## 6. `HealthPack.pde` (998 B)

**Role:** Healing pickup (+1 life, max 3); does not self-move.

**Knowledge points:**
- `class HealthPack extends WorldObject`
- Constructor chaining: `super(...)`
- Intentional empty `update()` (stationary object still fits polymorphism)
- Processing drawing: `ellipse`, `rect`, `fill`, alpha transparency
- `pushMatrix()` / `popMatrix()` / `translate()` / `scale()`
- Simple **animation** via `sin(frameCount)` pulse
- Collision helper: `dist()` circle test with `Player`
- Game design: pickup item vs hazard

---

## 7. `Bullet.pde` (1102 B)

**Role:** Laser projectile fired with SPACE along ship facing.

**Knowledge points:**
- Extends `WorldObject` / GameEntity pipeline
- Velocity from angle: `cos(angle)`, `sin(angle)`
- Projectile update loop (position += velocity)
- `atan2` + `rotate` to orient the beam
- Boolean flag `dead` + overridden `isFinished()`
- Bullet–alien collision with `dist()`
- Object lifecycle: create → update → remove when off-screen or hit

---

## 8. `MovingObstacle.pde` (1283 B)

**Role:** Zig-zag alien subclass (60–70% inheritance).

**Knowledge points:**
- **`extends Obstacle`** (inheritance)
- **`@Override`** on `update()` / `display()`
- Different behaviour from parent: lateral zig-zag
- Trigonometry: `atan2`, `cos`/`sin`, `HALF_PI` for perpendicular offset
- Phase / amplitude variables for periodic motion
- `super.display()` to reuse parent drawing then add a ring
- Polymorphism: stored in `ArrayList<Obstacle>` as parent type

---

## 9. `ScoreManager.pde` (1678 B)

**Role:** Current score + high-score **file I/O** (70–80%).

**Knowledge points:**
- Dedicated class for single responsibility (scoring)
- **`loadStrings()`** read high score from `highscore.txt`
- **`saveStrings()`** write high score
- String ↔ int conversion: `Integer.parseInt`, `str()`, `trim()`
- `try/catch` for bad/missing file data
- Frame counter to award ~1 point per second
- Conditional save only when beating record
- `final` constant for filename

---

## 10. `Explosion.pde` (1771 B)

**Role:** Short collision VFX; game continues while it plays (80%+).

**Knowledge points:**
- Extends `WorldObject`, lives in `ArrayList<GameEntity> effects`
- Lifetime timer (`life` countdown)
- Arrays for spark angles/distances
- `for` loops to animate particles outward
- Interpolation / progress `t` from life remaining
- Alpha fade, expanding rings (`stroke`, `ellipse`)
- `isFinished()` for safe removal
- Requirement: animation plays **without pausing** the main game loop

---

## 11. `FastObstacle.pde` (1862 B)

**Role:** Faster chasing alien with dash bursts.

**Knowledge points:**
- Inheritance from `Obstacle`
- Method overriding (`update`, `display`)
- Cooldown timer for dash behaviour
- `random()` for speed / timing variation
- Stronger centre-seeking with `lerpAngle` / `atan2`
- Perlin **`noise()`** for irregular steering
- `super.display()` + motion streak visual
- Demonstrates “same interface, different behaviour”

---

## 12. `Player.pde` (3177 B)

**Role:** Centred spaceship; collision; facing; sprite; lives.

**Knowledge points:**
- `class Player implements GameEntity`
- Fixed centre position (assignment core rule)
- Fields / encapsulation: `lives`, `facing`, `sprite`
- Constructor overload: `Player()` / `Player(PImage)`
- **`boolean checkCollision(Obstacle)`** (required signature style)
- Circle collision with `dist()`
- Heal with upper cap (`min(3, ...)`)
- Keyboard-driven facing via `atan2`
- Frame-index **animation sequence** (engine flame)
- `PImage` ship art + fallback geometry
- `pushMatrix` / `translate` / `rotate` / `image`
- `moveBy` intentionally empty (ship does not translate)

---

## 13. `Obstacle.pde` (3500 B)

**Role:** Base alien class; parent of Fast/Moving types.

**Knowledge points:**
- `extends WorldObject`
- Multiple constructors / constructor chaining
- Fields: speed, velocity, heading, colour, `PImage`
- Independent AI-like wander (`update`)
- Perlin `noise`, `random`, angle lerp
- `respawnAtEdge()` / `placeOnScreen()`
- Boundary awareness (`isOffScreen` inherited/used by main)
- Display with optional image or shape fallback
- Pulse scale animation
- Collision radius helper
- Foundation for **inheritance + polymorphism**

---

## 14. `DEVELOPMENT_NOTES.md` (6705 B)

**Role:** Chronological development notes for the report.

**Knowledge points (documentation, not runtime):**
- Markdown structure
- Phase logging / evidence for Development Report
- Mapping features → marking bands
- Recording techniques and code locations
- Academic process documentation (not game logic)

---

## 15. `DontCrash.pde` (11916 B)

**Role:** Main Processing sketch — entry point and game loop.

**Knowledge points:**
- Processing lifecycle: `setup()`, `draw()`
- `size()`, `background()`, `text()`, `imageMode`
- **Game state machine**: START / PLAYING / GAME_OVER + `switch`
- Global / sketch-level variables vs class fields
- **`ArrayList`**: aliens, health packs, bullets, effects
- Keyboard: `keyPressed`, `keyReleased`, `keyCode`, `key == ' '`
- Opposite-direction world push (core mechanic)
- Starfield arrays + wrap-around scrolling
- Spawn timers / caps (dynamic object management)
- Safe list removal with reverse `for` loops
- Collision orchestration + invulnerability frames
- Screen flash feedback (red crash / green heal)
- Calling polymorphic `update`/`display` on mixed types
- Restart / reset flow
- Coordinates all other classes (composition / orchestration)

---

## 16. `data/player_ship.png` (13970 B)

**Role:** Custom player spaceship sprite (user-provided art, processed).

**Knowledge points:**
- External art pipeline: JPG → transparent PNG
- Asset placed under `data/` for `loadImage`
- Higher-resolution sprite vs simple shapes
- Drawn with `image()` and rotated by player facing
- Graphics quality optional for marks; supports presentation

---

## Quick map: file → marking band focus

| Band | Most relevant files |
|------|---------------------|
| 40% | `DontCrash.pde`, `Obstacle.pde` / `Player.pde` |
| 40–50% | `Player.pde` (`checkCollision`), multiple obstacles in main |
| 50–60% | `DontCrash.pde` (ArrayList), `data/alien_*.png`, spawn/remove |
| 60–70% | `FastObstacle.pde`, `MovingObstacle.pde`, `Player` facing |
| 70–80% | animation in Player/Obstacle, `ScoreManager.pde`, polymorphism |
| 80%+ | `GameEntity.pde`, `WorldObject.pde`, `Explosion.pde` |
| Extra | `Bullet.pde`, `HealthPack.pde`, `player_ship.png` |

---

## Suggested oral explanation order (viva)

1. `DontCrash.pde` — overall flow & reverse controls  
2. `Player.pde` — centre + collision  
3. `Obstacle.pde` → `FastObstacle` / `MovingObstacle` — inheritance  
4. `GameEntity` + `WorldObject` — interface / abstract class  
5. `Explosion.pde` — VFX while game continues  
6. `ScoreManager.pde` — `loadStrings` / `saveStrings`
