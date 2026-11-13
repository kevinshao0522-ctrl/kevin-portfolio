/**
 * Explosion.pde — Collision animation that plays while the game continues.
 * Cycles a PImage frame sequence (80%+ / 70–80% animation criterion).
 */
class Explosion extends WorldObject {
  int life;
  final int MAX_LIFE = 30;
  PImage[] frames;
  int frameIndex;
  int frameTimer;
  final int FRAME_HOLD = 6;

  Explosion(float cx, float cy, PImage[] animFrames) {
    super(cx, cy, 64);
    life = MAX_LIFE;
    frames = animFrames;
    frameIndex = 0;
    frameTimer = 0;
  }

  void update() {
    life--;
    frameTimer++;
    if (frames != null && frameTimer >= FRAME_HOLD) {
      frameTimer = 0;
      if (frameIndex < frames.length - 1) {
        frameIndex = frameIndex + 1;
      }
    }
  }

  void display() {
    if (frames != null && frames.length > 0 && frames[frameIndex] != null) {
      float drawSize = size * (0.8 + frameIndex * 0.15);
      image(frames[frameIndex], x - drawSize / 2, y - drawSize / 2, drawSize, drawSize);
    } else {
      // Fallback shapes if images failed to load
      noStroke();
      fill(255, 180, 40);
      ellipse(x, y, size, size);
      fill(255, 90, 30);
      ellipse(x, y, size * 0.6, size * 0.6);
    }
  }

  boolean isFinished() {
    return life <= 0;
  }
}
