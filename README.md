# Kevin Shao · 作品集 demos

English: **Student portfolio — Python scripts & simple landing pages**

大学生 · Python 脚本 / 简单网页 · 周末交付

本仓库放了 3 个可直接展示的小作品，对应接单方向：落地页、公开数据整理成 CSV、批量文件自动化。全部可在家、周末完成级别。

## 项目列表

| 文件夹 | 英文标题 | 说明 | 技术 |
|--------|----------|------|------|
| [cafe-landing](./cafe-landing/) | Xuzhou Local Cafe Landing | 「假·徐州本地咖啡馆」响应式单页，含菜单 / 预约 / 二维码占位 | HTML · CSS · JS |
| [public-scraper](./public-scraper/) | Public Page → CSV Scraper | 抓取练习站 books.toscrape.com，导出 CSV | Python · httpx · BeautifulSoup |
| [file-batch](./file-batch/) | Batch CSV Merge & Rename | 合并多月订单 CSV + 批量重命名照片 | Python 标准库 |

## 建议的 GitHub 仓库描述

```
大学生 · Python脚本 / 简单网页 · 周末交付
```

Topics 可加：`python`, `web-scraping`, `landing-page`, `freelance`, `portfolio`

## 快速跑一遍

```bash
# 1) 咖啡馆落地页
cd cafe-landing && python3 -m http.server 5173
# 浏览器打开 http://localhost:5173

# 2) 公开页爬虫
cd ../public-scraper
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python scrape_books.py --pages 2

# 3) 批量工具
cd ../file-batch
python3 batch_tools.py merge-csv
python3 batch_tools.py rename --copy
```

## 接单说明（可放进简介）

- 在校学生，主要技术：Python、前端（HTML/JS，Vue/React 学习中）
- 接小而清楚的需求：数据整理脚本、自动化小工具、单页网站
- **周末集中交付**；合作方式：定金 50% 开工，验收后付尾款
- 不接：作业/毕设代做、需登录抓取、违法用途

## 作者

Kevin Shao（Messi）
