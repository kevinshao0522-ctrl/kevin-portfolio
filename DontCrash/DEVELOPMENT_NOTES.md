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

### Phase 4 — Collision detection
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Implemented `boolean checkCollision(Obstacle obstacle)` on `Player` (circle vs circle with `dist()`). On hit: lose a life, show "CRASH!" message, red flash, blink invulnerability, respawn alien. Lives 0 → `GAME_OVER`; ENTER restarts. Fixed a bug where `respawnAtEdge()` + tight `isOffScreen()` caused aliens to reset every frame and never appear; start-of-run now uses `placeOnScreen()`.
- **Techniques used:** `dist()`, boolean method return, invulnerability timer, game state transition, on-screen feedback.
- **Code location:** `Player.pde` (`checkCollision`), `Obstacle.pde` (`getCollisionRadius`), `DontCrash.pde` (`handleCollisionWith`, `drawGameOver`, `restartGame`)

### Phase 5 — Dynamic obstacles / ArrayList
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Replaced fixed `alien1`/`alien2` with `ArrayList<Obstacle>`. Timed spawning adds new aliens; off-screen and hit aliens are `remove`d from the list. Added `PImage` sprites in `data/alien_green.png` and `data/alien_purple.png`.
- **Techniques used:** `ArrayList`, `add`/`get`/`remove`/`clear`, reverse-index loop for safe deletion, `loadImage`/`image`, spawn timer, max-count cap.
- **Code location:** `DontCrash.pde` (`aliens`, `spawnAlienAtEdge`, `drawPlaying`), `Obstacle.pde` (PImage display; update no longer self-respawns), `data/*.png`

### Phase 6 — Inheritance
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Added `FastObstacle` and `MovingObstacle` subclasses with overridden `update()`/`display()`. Spawn mixes types into `ArrayList<Obstacle>`. Player `facing` rotates with arrow keys while position stays centred. Added `data/alien_orange.png`.
- **Techniques used:** `extends`, `@Override`, method overriding, polymorphism via ArrayList, `rotate()` for ship facing.
- **Code location:** `FastObstacle.pde`, `MovingObstacle.pde`, `Player.pde` (`updateFacing`), `DontCrash.pde` (`spawnAlienAtEdge`)

### Phase 6+ — Health packs
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Added `HealthPack` pickups that do not self-move after spawn. Collecting heals +1 life, capped at 3. Arrow-key world push still shifts packs with the scene.
- **Techniques used:** new class, `ArrayList<HealthPack>`, `Player.heal()`, spawn away from centre.
- **Code location:** `HealthPack.pde`, `Player.heal()`, `DontCrash.pde` (`spawnHealthPack`, `handleHealthPickups`)

### Phase 7 — Animation, polymorphism, high scores
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Player engine flame animation sequence; alien pulse scale animation. Survival score (+1/sec) and heal bonus. `ScoreManager` loads/saves `highscore.txt` with `loadStrings`/`saveStrings`. ArrayList polymorphism call path kept/emphasized.
- **Techniques used:** frame-index animation, `saveStrings`/`loadStrings`, scoring, file I/O, polymorphism via `Obstacle` list.
- **Code location:** `ScoreManager.pde`, `Player.updateAnimation()`, `Obstacle.display()` pulse, `DontCrash.pde` (`endRun`, HUD score)

### Phase 8 — Interface/abstract class, explosion
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Added `GameEntity` interface and abstract `WorldObject`. `Obstacle`, `HealthPack`, `Explosion` extend `WorldObject`; `Player` implements `GameEntity`. Crash spawns `Explosion` animation that plays briefly while gameplay continues; finished explosions are removed from `ArrayList<GameEntity> effects`.
- **Techniques used:** `interface`, `abstract class`, polymorphism across entities, short-lived VFX while game loop continues.
- **Code location:** `GameEntity.pde`, `WorldObject.pde`, `Explosion.pde`, `DontCrash.pde` (`effects`, `handleCollisionWith`)

### Phase 8+ — SPACE shooting
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Added `Bullet` lasers fired with SPACE along player facing. Hits destroy aliens (+10 score) and spawn explosions. Fire cooldown prevents spam.
- **Techniques used:** `key == ' '`, projectile list, bullet-obstacle collision, cooldown timer.
- **Code location:** `Bullet.pde`, `DontCrash.pde` (`tryFireBullet`, bullet update loop)

### Art pass — custom player ship
- **Date:** 2026-11-09 (Asia/Shanghai)
- **What was done:** Converted provided ship JPG (checkerboard background) to transparent PNG `data/player_ship.png` and drew it via `Player` sprite with engine flame still animated underneath.
- **Techniques used:** image preprocessing, `PImage`, `image()`, fallback shape drawing.
- **Code location:** `data/player_ship.png`, `Player.pde`, `DontCrash.pde` (`loadImage`)




