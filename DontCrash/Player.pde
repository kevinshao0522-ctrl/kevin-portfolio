/**
 * Player.pde — Player spaceship fixed at the screen centre.
 * Four facing sprites plus a PImage flame animation sequence.
 */
class Player implements GameEntity {
  final int DIR_UP = 0;
  final int DIR_RIGHT = 1;
  final int DIR_DOWN = 2;
  final int DIR_LEFT = 3;

  float x;
  float y;
  float bodySize;
  private int lives;
  private int facing;

  PImage spriteUp;
  PImage spriteDown;
  PImage spriteLeft;
  PImage spriteRight;
  PImage[] flameFrames;

  int animFrame;
  int animTimer;
  int animCount;
  final int ANIM_SPEED = 5;

  Player() {
    this(null, null, null, null);
  }

  Player(PImage up, PImage down, PImage left, PImage right) {
    x = width / 2.0;
    y = height / 2.0;
    bodySize = 72;
    lives = 3;
    facing = DIR_UP;
    animFrame = 0;
    animTimer = 0;
    animCount = 4;
    flameFrames = null;
    spriteUp = up;
    spriteDown = down;
    spriteLeft = left;
    spriteRight = right;
  }

  void setFlameFrames(PImage[] frames) {
    flameFrames = frames;
    if (frames != null && frames.length > 0) {
      animCount = frames.length;
    }
  }

  int getLives() {
    return lives;
  }

  void loseLife() {
    if (lives > 0) {
      lives = lives - 1;
    }
  }

  void resetForNewRun() {
    lives = 3;
    facing = DIR_UP;
    animFrame = 0;
    animTimer = 0;
  }

  void setFacingFromKey(int dir) {
    if (dir == DIR_UP || dir == DIR_RIGHT || dir == DIR_DOWN || dir == DIR_LEFT) {
      facing = dir;
    }
  }

  int getFacing() {
    return facing;
  }

  float getCollisionRadius() {
    return bodySize * 0.45;
  }

  boolean checkCollision(Obstacle obstacle) {
    float distance = dist(x, y, obstacle.x, obstacle.y);
    float minDist = getCollisionRadius() + obstacle.getCollisionRadius();
    return distance < minDist;
  }

  boolean heal(int amount) {
    if (lives >= 3) return false;
    if (lives + amount > 3) {
      lives = 3;
    } else {
      lives = lives + amount;
    }
    return true;
  }

  float getBulletVx(float speed) {
    if (facing == DIR_LEFT)  return -speed;
    if (facing == DIR_RIGHT) return speed;
    return 0;
  }

  float getBulletVy(float speed) {
    if (facing == DIR_UP)   return -speed;
    if (facing == DIR_DOWN) return speed;
    return 0;
  }

  float getNoseX() {
    if (facing == DIR_LEFT)  return x - bodySize * 0.55;
    if (facing == DIR_RIGHT) return x + bodySize * 0.55;
    return x;
  }

  float getNoseY() {
    if (facing == DIR_UP)   return y - bodySize * 0.55;
    if (facing == DIR_DOWN) return y + bodySize * 0.55;
    return y;
  }

  PImage currentSprite() {
    if (facing == DIR_DOWN)  return spriteDown;
    if (facing == DIR_LEFT)  return spriteLeft;
    if (facing == DIR_RIGHT) return spriteRight;
    return spriteUp;
  }

  void update() {
    updateAnimation();
  }

  void updateAnimation() {
    animTimer++;
    if (animTimer >= ANIM_SPEED) {
      animTimer = 0;
      if (animCount > 0) {
        animFrame = (animFrame + 1) % animCount;
      }
    }
  }

  void moveBy(float dx, float dy) {
  }

  boolean isFinished() {
    return false;
  }

  void display() {
    // Engine flame: PImage sequence when available
    if (flameFrames != null && flameFrames.length > 0 &&
        flameFrames[animFrame] != null) {
      PImage flame = flameFrames[animFrame];
      float fw = bodySize * 0.45;
      float fh = bodySize * 0.55;
      if (facing == DIR_UP) {
        image(flame, x - fw / 2, y + bodySize * 0.25, fw, fh);
      } else if (facing == DIR_DOWN) {
        image(flame, x - fw / 2, y - bodySize * 0.25 - fh, fw, fh);
      } else if (facing == DIR_LEFT) {
        image(flame, x + bodySize * 0.25, y - fw / 2, fh, fw);
      } else {
        image(flame, x - bodySize * 0.25 - fh, y - fw / 2, fh, fw);
      }
    } else {
      float flameLen = 12 + animFrame * 6;
      noStroke();
      fill(255, 160, 40);
      if (facing == DIR_UP) {
        ellipse(x - bodySize * 0.12, y + bodySize * 0.42 + flameLen * 0.2, 10, flameLen);
        ellipse(x + bodySize * 0.12, y + bodySize * 0.42 + flameLen * 0.2, 10, flameLen);
      } else if (facing == DIR_DOWN) {
        ellipse(x - bodySize * 0.12, y - bodySize * 0.42 - flameLen * 0.2, 10, flameLen);
        ellipse(x + bodySize * 0.12, y - bodySize * 0.42 - flameLen * 0.2, 10, flameLen);
      } else if (facing == DIR_LEFT) {
        ellipse(x + bodySize * 0.42 + flameLen * 0.2, y - bodySize * 0.12, flameLen, 10);
        ellipse(x + bodySize * 0.42 + flameLen * 0.2, y + bodySize * 0.12, flameLen, 10);
      } else {
        ellipse(x - bodySize * 0.42 - flameLen * 0.2, y - bodySize * 0.12, flameLen, 10);
        ellipse(x - bodySize * 0.42 - flameLen * 0.2, y + bodySize * 0.12, flameLen, 10);
      }
    }

    PImage spr = currentSprite();
    if (spr != null) {
      float drawH;
      float drawW;
      if (facing == DIR_LEFT || facing == DIR_RIGHT) {
        drawW = bodySize * 1.35;
        drawH = drawW * (spr.height / float(spr.width));
      } else {
        drawH = bodySize * 1.35;
        drawW = drawH * (spr.width / float(spr.height));
      }
      image(spr, x - drawW / 2, y - drawH / 2, drawW, drawH);
    } else {
      fill(180, 210, 255);
      noStroke();
      if (facing == DIR_UP) {
        triangle(x, y - bodySize * 0.7,
                 x - bodySize * 0.55, y + bodySize * 0.55,
                 x + bodySize * 0.55, y + bodySize * 0.55);
      } else if (facing == DIR_DOWN) {
        triangle(x, y + bodySize * 0.7,
                 x - bodySize * 0.55, y - bodySize * 0.55,
                 x + bodySize * 0.55, y - bodySize * 0.55);
      } else if (facing == DIR_LEFT) {
        triangle(x - bodySize * 0.7, y,
                 x + bodySize * 0.55, y - bodySize * 0.55,
                 x + bodySize * 0.55, y + bodySize * 0.55);
      } else {
        triangle(x + bodySize * 0.7, y,
                 x - bodySize * 0.55, y - bodySize * 0.55,
                 x - bodySize * 0.55, y + bodySize * 0.55);
      }
    }
  }
}
