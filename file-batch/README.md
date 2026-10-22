# 批量文件处理 · File Batch Tools

English title: **Batch CSV Merge & File Rename**

两个实用小工具，演示「重复电脑操作 → 一键脚本」类接单能力：

1. **合并多个同结构 CSV**（如按月订单表）
2. **批量重命名杂乱文件名**（手机照片 / 微信导出图）

全部本地运行，无网络、无账号。

## 环境

- Python 3.10+（仅标准库，无需 pip）

```bash
cd file-batch
```

## 示例 1：合并订单 CSV

`sample_input/` 里有 `orders_2026-01.csv` / `orders_2026-02.csv` / `orders_2026-03.csv`。

```bash
python3 batch_tools.py merge-csv \
  --input-dir sample_input \
  --out sample_output/orders_merged.csv
```

结果多一列 `_source_file`，方便追溯来自哪个月份文件。

## 示例 2：批量重命名照片

```bash
# 先 dry-run 看效果
python3 batch_tools.py rename \
  --src sample_input/photos_raw \
  --dest sample_output/photos_renamed \
  --prefix cafe_shot \
  --copy \
  --dry-run

# 确认后真正复制并重命名
python3 batch_tools.py rename \
  --src sample_input/photos_raw \
  --dest sample_output/photos_renamed \
  --prefix cafe_shot \
  --copy
```

输出形如：`cafe_shot_001.jpg`, `cafe_shot_002.png`, …

默认 `--copy` 建议打开，避免误改原文件；去掉 `--copy` 则为移动。

## 技术栈

- Python 标准库：`csv`, `argparse`, `pathlib`, `shutil`

## 作者

Kevin Shao · 大学生作品 · 周末交付示例
