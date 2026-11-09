/**
 * Explosion — short collision animation.
 *
 * Plays for a brief time WHILE the game keeps running
 * (assignment 80%+ requirement).
 */
class Explosion extends WorldObject {
  int life;                 // remaining frames
  final int MAX_LIFE = 36;  // ~0.6s at 60fps
  float[] sparkAngle;
  float[] sparkDist;

  Explosion(float cx, float cy) {
    super(cx, cy, 40);
    life = MAX_LIFE;

    // Precompute a few spark directions
    sparkAngle = new float[10];
    sparkDist = new float[10];
    for (int i = 0; i < sparkAngle.length; i++) {
      sparkAngle[i] = random(TWO_PI);
      sparkDist[i] = random(8, 28);
    }
  }

  void update() {
    life--;
    // Sparks fly outward over time
    for (int i = 0; i < sparkDist.length; i++) {
      sparkDist[i] += 2.2;
    }
  }

  void display() {
    float t = 1.0 - life / float(MAX_LIFE);  // 0 → 1
    float radius = size * (0.4 + t * 2.2);
    float alpha = 255 * (1.0 - t);

    pushMatrix();
    translate(x, y);

    // Expanding shock rings
    noFill();
    stroke(255, 200, 80, alpha);
    strokeWeight(3);
    ellipse(0, 0, radius, radius);
    stroke(255, 100, 40, alpha * 0.7);
    strokeWeight(2);
    ellipse(0, 0, radius * 0.65, radius * 0.65);

    // Core flash
    noStroke();
    fill(255, 240, 180, alpha);
    ellipse(0, 0, radius * 0.35, radius * 0.35);
    fill(255, 120, 40, alpha * 0.8);
    ellipse(0, 0, radius * 0.2, radius * 0.2);

    // Sparks
    for (int i = 0; i < sparkAngle.length; i++) {
      float sx = cos(sparkAngle[i]) * sparkDist[i] * (0.5 + t);
      float sy = sin(sparkAngle[i]) * sparkDist[i] * (0.5 + t);
      fill(255, 180 + i * 5, 60, alpha);
      ellipse(sx, sy, 5, 5);
    }

    popMatrix();
  }

  boolean isFinished() {
    return life <= 0;
  }
}
