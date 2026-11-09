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

### Phase 2 — Player & Obstacle (current)
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Added `Player` (centred spaceship) and `Obstacle` (alien). Created two alien objects on the PLAYING screen. Added a simple static starfield.
- **Techniques used:** classes, constructors, encapsulation fields, `pushMatrix()`/`popMatrix()`, `triangle()`, `ellipse()`, arrays for stars.
- **Screenshot:** (add when you run it locally)
- **Code location:** `Player.pde`, `Obstacle.pde`, `DontCrash.pde` (`drawPlaying()`)

### Phase 3 — Keyboard controls (not started)
### Phase 4 — Collision detection (not started)
### Phase 5 — Dynamic obstacles / ArrayList (not started)
### Phase 6 — Inheritance (not started)
### Phase 7 — Animation, polymorphism, high scores (not started)
### Phase 8 — Interface/abstract class, explosion (not started)
