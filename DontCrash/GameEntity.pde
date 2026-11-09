/**
 * GameEntity — common interface for most game objects (Phase 8 / 80%+).
 *
 * Any class that implements this can be stored in ArrayList<GameEntity>
 * and updated/drawn through polymorphism.
 */
interface GameEntity {
  void update();
  void display();
  void moveBy(float dx, float dy);

  /** True when this entity should be removed (e.g. finished explosion). */
  boolean isFinished();
}
