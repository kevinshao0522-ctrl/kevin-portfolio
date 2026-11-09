/**
 * WorldObject — abstract base for things that live in world space.
 *
 * Holds shared position/size helpers. Concrete subclasses:
 * Obstacle, HealthPack, Explosion, ...
 */
abstract class WorldObject implements GameEntity {
  float x;
  float y;
  float size;

  WorldObject(float startX, float startY, float objectSize) {
    x = startX;
    y = startY;
    size = objectSize;
  }

  void moveBy(float dx, float dy) {
    x += dx;
    y += dy;
  }

  boolean isOffScreen() {
    float margin = size + 120;
    return (x < -margin || x > width + margin ||
            y < -margin || y > height + margin);
  }

  /** Default: stay alive until a subclass says otherwise. */
  boolean isFinished() {
    return false;
  }

  // Subclasses must implement update() and display()
  abstract void update();
  abstract void display();
}
