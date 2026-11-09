# Don't Crash!! — Development Notes

> For the Development Report (max 500 words). Record real progress only.
> Screenshots: save under `DontCrash/screenshots/` when you capture them.

## Target marking band
80%+

## Design choice
Scheme A: Star Wars theme on top of Don't Crash rules — ship fixed at centre;
arrow keys move aliens/background the opposite way; shooting comes later.

## Progress log

### Phase 1 — Environment & skeleton
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Created Processing sketch with window, title screen, and game-state constants.
- **Techniques used:** `setup()`, `draw()`, `size()`, `background()`, `text()`, `switch`, `keyPressed()`.
- **Code location:** `DontCrash/DontCrash.pde`

### Phase 2 — Player & Obstacle
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Added `Player` (centred spaceship) and `Obstacle` (alien). Created two alien objects on the PLAYING screen. Added a simple static starfield. Window enlarged to 1280×800. Aliens move on their own with random wandering (`heading`, `turnSpeed`, Perlin `noise`), occasional soft bias toward centre, variable speed, and random-edge respawn.
- **Techniques used:** classes, constructors, encapsulation fields, `pushMatrix()`/`popMatrix()`, `triangle()`, `ellipse()`, arrays for stars, `atan2` / angle lerp, Perlin `noise()`, per-frame `update()` loop.
- **Screenshot:** (add when you run it locally)
- **Code location:** `Player.pde`, `Obstacle.pde`, `DontCrash.pde` (`drawPlaying()`)

### Phase 3 — Keyboard controls
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Arrow keys push all aliens and the starfield in the opposite direction while the ship stays centred. Hold flags + `keyPressed`/`keyReleased` support continuous steering. Stars wrap around the screen.
- **Techniques used:** `keyCode` (LEFT/RIGHT/UP/DOWN), `keyPressed`/`keyReleased`, boolean hold flags, opposite-direction delta, `Obstacle.moveBy()`, starfield wrap.
- **Code location:** `DontCrash.pde` — `applyArrowPush()`, `shiftStarfield()`, `keyPressed()`, `keyReleased()`

### Phase 4 — Collision detection (current)
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Implemented `boolean checkCollision(Obstacle obstacle)` on `Player` (circle vs circle with `dist()`). On hit: lose a life, show "CRASH!" message, red flash, blink invulnerability, respawn alien. Lives 0 → `GAME_OVER`; ENTER restarts. Fixed a bug where `respawnAtEdge()` + tight `isOffScreen()` caused aliens to reset every frame and never appear; start-of-run now uses `placeOnScreen()`.
- **Techniques used:** `dist()`, boolean method return, invulnerability timer, game state transition, on-screen feedback.
- **Code location:** `Player.pde` (`checkCollision`), `Obstacle.pde` (`getCollisionRadius`), `DontCrash.pde` (`handleCollisionWith`, `drawGameOver`, `restartGame`)

### Phase 5 — Dynamic obstacles / ArrayList (not started)
### Phase 6 — Inheritance (not started)
### Phase 7 — Animation, polymorphism, high scores (not started)
### Phase 8 — Interface/abstract class, explosion (not started)
