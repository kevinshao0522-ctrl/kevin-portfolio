/**
 * WorldObject.pde — Abstract base for objects that exist in world space.
 * Stores position/size and shared helpers used by aliens, pickups, bullets, VFX.
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

  // Extra margin so edge-spawned aliens are not removed immediately
  boolean isOffScreen() {
    float margin = size + 120;
    return (x < -margin || x > width + margin ||
            y < -margin || y > height + margin);
  }

  boolean isFinished() {
    return false;
  }

  abstract void update();
  abstract void display();
}
