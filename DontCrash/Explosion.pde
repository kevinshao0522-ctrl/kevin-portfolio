/**
 * Explosion — short VFX using fixed offset arrays (no cos/sin).
 * Game continues while this plays.
 */
class Explosion extends WorldObject {
  int life;
  final int MAX_LIFE = 36;

  // Prefixed spark directions as raw dx/dy (no angles)
  float[] sparkDx;
  float[] sparkDy;
  float[] sparkDist;

  Explosion(float cx, float cy) {
    super(cx, cy, 40);
    life = MAX_LIFE;

    sparkDx = new float[] { 1, -1, 0, 0, 1, -1, 1, -1, 0.5, -0.5 };
    sparkDy = new float[] { 0, 0, 1, -1, 1, -1, -1, 1, 0.5, -0.5 };
    sparkDist = new float[10];
    for (int i = 0; i < sparkDist.length; i++) {
      sparkDist[i] = random(8, 28);
    }
  }

  void update() {
    life--;
    for (int i = 0; i < sparkDist.length; i++) {
      sparkDist[i] = sparkDist[i] + 2.2;
    }
  }

  void display() {
    float t = 1.0 - life / float(MAX_LIFE);
    float radius = size * (0.4 + t * 2.2);

    noStroke();
    // Expanding rings as filled ellipses (no strokeWeight / alpha)
    fill(255, 200, 80);
    ellipse(x, y, radius, radius);
    fill(255, 100, 40);
    ellipse(x, y, radius * 0.65, radius * 0.65);
    fill(255, 240, 180);
    ellipse(x, y, radius * 0.35, radius * 0.35);

    for (int i = 0; i < sparkDx.length; i++) {
      float sx = x + sparkDx[i] * sparkDist[i] * (0.5 + t);
      float sy = y + sparkDy[i] * sparkDist[i] * (0.5 + t);
      fill(255, 180, 60);
      ellipse(sx, sy, 5, 5);
    }
  }

  boolean isFinished() {
    return life <= 0;
  }
}
