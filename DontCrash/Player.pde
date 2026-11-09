/**
 * Player — the player's spaceship.
 *
 * Assignment rule: the ship stays FIXED at the centre of the screen.
 * Arrow keys will NOT move this object; they will move obstacles / background
 * in the opposite direction (Phase 3).
 *
 * Theme (Scheme A): Star Wars style ship that can shoot later.
 */
class Player {
  // Centre position — set once and kept fixed during gameplay
  float x;
  float y;

  // Visual size (used later for collision radius)
  float bodySize;

  // Optional lives (used from Phase 4+)
  int lives;

  /**
   * Constructor: place the ship at the canvas centre.
   * width and height are Processing built-in variables.
   */
  Player() {
    x = width / 2.0;
    y = height / 2.0;
    bodySize = 48;  // slightly larger for the 1280x800 window
    lives = 3;
  }

  /**
   * Draw a simple spaceship pointing upward.
   * Uses triangle + small cockpit circle (no images yet).
   */
  void display() {
    pushMatrix();
    translate(x, y);

    // Ship body (triangle nose up)
    noStroke();
    fill(180, 210, 255);
    triangle(0, -bodySize * 0.7,
             -bodySize * 0.55, bodySize * 0.55,
             bodySize * 0.55, bodySize * 0.55);

    // Cockpit
    fill(80, 160, 255);
    ellipse(0, 0, bodySize * 0.35, bodySize * 0.35);

    // Engine glow
    fill(255, 140, 40);
    ellipse(-bodySize * 0.2, bodySize * 0.55, 8, 12);
    ellipse(bodySize * 0.2, bodySize * 0.55, 8, 12);

    popMatrix();
  }

  /**
   * Collision will be implemented in Phase 4.
   * Signature reserved so later code stays stable:
   * boolean checkCollision(Obstacle obstacle)
   */
}
