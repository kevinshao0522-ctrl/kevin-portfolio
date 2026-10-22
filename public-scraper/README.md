# 公开网页数据整理 · Public Scraper

English title: **Public Page → CSV Scraper (books.toscrape.com)**

用 Python 把**公开、无需登录**的练习站点 [books.toscrape.com](https://books.toscrape.com/) 上的图书列表整理成 CSV。适合作为「网页数据 → Excel/CSV」接单作品。

## 合规说明

- 目标站是 Scrapy 官方练习站，公开可读，**无登录、无付费墙**
- 脚本带明确 User-Agent，请求间隔约 0.6 秒
- **不抓**需要账号、验证码或登录后的数据；不碰隐私信息
- 仅用于学习 / 作品展示；接单时请确认客户目标站允许抓取

## 环境

- Python 3.10+

```bash
cd public-scraper
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

## 运行

```bash
# 默认抓 2 页，输出到 output/books.csv
python scrape_books.py

# 抓 5 页，自定义输出路径
python scrape_books.py --pages 5 --out output/books_5pages.csv
```

输出字段：`title`, `price`, `availability`, `rating`, `url`

用 Excel / WPS / Numbers 直接打开 CSV（已用 `utf-8-sig`，中文 Excel 不易乱码）。

## 技术栈

- `httpx` — HTTP 客户端
- `BeautifulSoup4` — HTML 解析
- 标准库 `csv` / `argparse`

## 作者

Kevin Shao · 大学生作品 · 周末交付示例
