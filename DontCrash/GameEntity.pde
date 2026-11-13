/**
 * GameEntity.pde — Shared interface for updateable / drawable game objects.
 * Enables polymorphism via ArrayList<GameEntity>.
 */
interface GameEntity {
  void update();
  void display();
  void moveBy(float dx, float dy);

  // True when the object should be removed from its list
  boolean isFinished();
}
