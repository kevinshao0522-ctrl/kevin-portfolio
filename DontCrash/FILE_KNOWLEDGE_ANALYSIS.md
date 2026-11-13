# Don't Crash!! — 逐文件知识点解析（中文）

> 按**文件体积从小到大**排序。  
> 每项包含：作用、大小、用到的知识点 / 技术。  
> 可用于复习与撰写 Development Report。日期：2026-11-09（Asia/Shanghai）。

---

## 目录（小 → 大）

| # | 文件 | 大小（字节） |
|---|------|-------------:|
| 1 | `data/alien_orange.png` | 323 |
| 2 | `data/alien_purple.png` | 323 |
| 3 | `data/alien_green.png` | 326 |
| 4 | `GameEntity.pde` | 398 |
| 5 | `WorldObject.pde` | 837 |
| 6 | `HealthPack.pde` | 998 |
| 7 | `Bullet.pde` | 1102 |
| 8 | `MovingObstacle.pde` | 1283 |
| 9 | `ScoreManager.pde` | 1678 |
| 10 | `Explosion.pde` | 1771 |
| 11 | `FastObstacle.pde` | 1862 |
| 12 | `Player.pde` | 3177 |
| 13 | `Obstacle.pde` | 3500 |
| 14 | `DEVELOPMENT_NOTES.md` | 6705 |
| 15 | `DontCrash.pde` | 11916 |
| 16 | `data/player_ship.png` | 13970 |

空文件夹（不是文件）：`screenshots/`

---

## 1. `data/alien_orange.png`（323 B）

**作用：** 快速外星人（`FastObstacle`）的贴图。

**知识点：**
- Processing 资源放在 `data/` 目录
- `PImage`、`loadImage()`、`image()` 显示图片
- 透明 PNG，方便叠在游戏背景上
- 用不同颜色贴图区分障碍物**子类型**（对应继承分数段）

---

## 2. `data/alien_purple.png`（323 B）

**作用：** Zigzag 外星人（`MovingObstacle`）的贴图。

**知识点：**
- 与上相同的资源加载流程（`data/` + `PImage`）
- 用外观区分不同子类行为
- 资源命名与实体类型对应

---

## 3. `data/alien_green.png`（326 B）

**作用：** 普通外星人（基类 `Obstacle`）的贴图。

**知识点：**
- 父类默认外观资源
- 在 `setup()` 中只加载一次，多个对象共用（更省内存）
- 图片资源管理基础

---

## 4. `GameEntity.pde`（398 B）

**作用：** 大多数游戏对象共用的**接口**（冲 80%+）。

**知识点：**
- Java / Processing 的 **`interface`（接口）**
- 只定义方法约定：`update()`、`display()`、`moveBy()`、`isFinished()`
- 支持**多态**：`ArrayList<GameEntity>` 可装不同类型
- 把“能做什么”和“怎么做”分开
- 对应评分：Interface / Abstract Class

---

## 5. `WorldObject.pde`（837 B）

**作用：** 实现 `GameEntity` 的**抽象类**，放公共的世界坐标逻辑。

**知识点：**
- **`abstract class`（抽象类）**
- `implements GameEntity`
- 公共字段：`x`、`y`、`size`
- 构造方法 + 子类继承共用行为
- 已实现方法：`moveBy()`、`isOffScreen()`、默认 `isFinished()`
- **`abstract` 方法**：`update()`、`display()`（子类必须实现）
- 封装出屏判断（带边距）
- 减少重复代码（Obstacle / HealthPack / Bullet / Explosion 共用）

---

## 6. `HealthPack.pde`（998 B）

**作用：** 回血道具（+1 命，最多 3）；自己不会乱飞。

**知识点：**
- `class HealthPack extends WorldObject`
- 构造里调用 `super(...)`
- `update()` 故意为空（静止物体仍可参与多态）
- 绘图：`ellipse`、`rect`、`fill`、透明度
- `pushMatrix()` / `popMatrix()` / `translate()` / `scale()`
- 用 `sin(frameCount)` 做轻微脉冲动画
- 用 `dist()` 做与玩家的圆形碰撞
- 游戏设计：增益道具 vs 障碍物

---

## 7. `Bullet.pde`（1102 B）

**作用：** 空格发射的激光，沿飞船朝向飞行。

**知识点：**
- 继承 `WorldObject`，走 GameEntity 体系
- 由角度算速度：`cos(angle)`、`sin(angle)`
- 子弹每帧位置更新（位置 += 速度）
- `atan2` + `rotate` 让激光朝向飞行方向
- 布尔标记 `dead`，重写 `isFinished()`
- 用 `dist()` 检测子弹与外星人碰撞
- 对象生命周期：创建 → 更新 → 出屏/命中后删除

---

## 8. `MovingObstacle.pde`（1283 B）

**作用：** 左右 Zigzag 的外星人子类（60–70% 继承）。

**知识点：**
- **`extends Obstacle`（继承）**
- **`@Override`** 重写 `update()` / `display()`
- 与父类不同的移动方式：横向摆动
- 三角函数：`atan2`、`cos`/`sin`、`HALF_PI`（垂直方向偏移）
- 相位 / 振幅变量做周期性运动
- `super.display()` 先画父类，再画紫色光圈
- 多态：作为父类型放进 `ArrayList<Obstacle>`

---

## 9. `ScoreManager.pde`（1678 B）

**作用：** 当前分数 + 高分**文件读写**（70–80%）。

**知识点：**
- 单一职责：专门管分数
- **`loadStrings()`** 从 `highscore.txt` 读高分
- **`saveStrings()`** 写入高分
- 字符串与整数转换：`Integer.parseInt`、`str()`、`trim()`
- `try/catch` 处理文件损坏或缺失
- 帧计数，大约每秒 +1 分
- 仅在破纪录时保存
- `final` 常量保存文件名

---

## 10. `Explosion.pde`（1771 B）

**作用：** 短暂碰撞爆炸特效；播放时游戏继续跑（80%+）。

**知识点：**
- 继承 `WorldObject`，放在 `ArrayList<GameEntity> effects`
- 生命计时（`life` 倒数）
- 用数组存火花角度与距离
- `for` 循环让粒子向外飞
- 用剩余寿命算进度 `t`
- 透明度渐隐、光圈扩大（`stroke`、`ellipse`）
- `isFinished()` 控制删除时机
- 关键点：动画播放时**不暂停**主循环

---

## 11. `FastObstacle.pde`（1862 B）

**作用：** 更快、会冲刺的外星人。

**知识点：**
- 继承 `Obstacle`
- 方法重写（`update`、`display`）
- 冲刺冷却计时器
- `random()` 产生速度/时间变化
- 更强地朝中心追击：`lerpAngle` / `atan2`
- Perlin **`noise()`** 做不规则转向
- `super.display()` + 速度残影
- 体现“同一接口，不同行为”

---

## 12. `Player.pde`（3177 B）

**作用：** 居中飞船；碰撞；朝向；贴图；生命。

**知识点：**
- `class Player implements GameEntity`
- 位置固定在屏幕中心（作业硬性规则）
- 字段封装：`lives`、`facing`、`sprite`
- 构造方法重载：`Player()` / `Player(PImage)`
- **`boolean checkCollision(Obstacle)`**（作业要求的布尔碰撞）
- 圆形碰撞：`dist()`
- 回血有上限（`if/else` 封顶到 3）
- 方向键改变朝向：`atan2`
- 帧索引**动画序列**（引擎尾焰）
- `PImage` 飞船图 + 几何图形备用
- `pushMatrix` / `translate` / `rotate` / `image`
- `moveBy` 故意为空（飞船本身不平移）

---

## 13. `Obstacle.pde`（3500 B）

**作用：** 外星人基类；`FastObstacle` / `MovingObstacle` 的父类。

**知识点：**
- `extends WorldObject`
- 多个构造方法 / 构造链
- 字段：速度、速度向量、朝向、颜色、`PImage`
- 独立游荡 AI（`update`）
- Perlin `noise`、`random`、角度插值
- `respawnAtEdge()` / `placeOnScreen()`
- 出屏判断（配合主程序删除）
- 显示：优先图片，否则画形状
- 缩放脉冲动画
- 碰撞半径辅助方法
- **继承 + 多态**的基础

---

## 14. `DEVELOPMENT_NOTES.md`（6705 B）

**作用：** 按时间记录开发过程，供写报告用。

**知识点（文档，不是运行代码）：**
- Markdown 结构
- 分阶段记录，对应评分带
- 记录技术点与代码位置
- 学术作业的过程文档写法

---

## 15. `DontCrash.pde`（11916 B）

**作用：** 主程序入口与游戏主循环。

**知识点：**
- Processing 生命周期：`setup()`、`draw()`
- `size()`、`background()`、`text()`、`imageMode`
- **游戏状态机**：START / PLAYING / GAME_OVER + `switch`
- 草图级变量 vs 类字段
- **`ArrayList`**：外星人、回血包、子弹、特效
- 键盘：`keyPressed`、`keyReleased`、`keyCode`、`key == ' '`
- 障碍物与背景**反向**移动（核心玩法）
- 星空数组 + 出界回绕滚动
- 生成计时器 / 数量上限（动态对象管理）
- 倒序 `for` 安全删除列表元素
- 碰撞调度 + 无敌帧
- 屏幕闪色反馈（撞车红闪 / 回血绿闪）
- 对混合类型统一调用 `update`/`display`（多态）
- 重新开始 / 重置流程
- 总调度其他类（组合 / 编排）

---

## 16. `data/player_ship.png`（13970 B）

**作用：** 自定义玩家飞船贴图（你提供，处理后使用）。

**知识点：**
- 外部美术资源流程：JPG → 透明 PNG
- 放入 `data/` 供 `loadImage` 使用
- 比简单几何图形更精细的精灵图
- 用 `image()` 绘制，并随 `facing` 旋转
- 画质本身不直接计分，但提升展示效果

---

## 快速对照：文件 ↔ 评分带

| 分数带 | 主要相关文件 |
|--------|----------------|
| 40% | `DontCrash.pde`、`Obstacle.pde` / `Player.pde` |
| 40–50% | `Player.pde`（`checkCollision`）、主程序中多个障碍 |
| 50–60% | `DontCrash.pde`（ArrayList）、`data/alien_*.png`、生成与删除 |
| 60–70% | `FastObstacle.pde`、`MovingObstacle.pde`、Player 朝向 |
| 70–80% | Player/Obstacle 动画、`ScoreManager.pde`、多态 |
| 80%+ | `GameEntity.pde`、`WorldObject.pde`、`Explosion.pde` |
| 额外加分 | `Bullet.pde`、`HealthPack.pde`、`player_ship.png` |

---

## 建议口述答辩顺序

1. `DontCrash.pde` — 整体流程与反向控制  
2. `Player.pde` — 居中 + 碰撞  
3. `Obstacle.pde` → `FastObstacle` / `MovingObstacle` — 继承  
4. `GameEntity` + `WorldObject` — 接口 / 抽象类  
5. `Explosion.pde` — 爆炸时游戏仍继续  
6. `ScoreManager.pde` — `loadStrings` / `saveStrings`（`data/highscore.txt`）+ `getLevel()`
