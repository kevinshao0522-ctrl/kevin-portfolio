#!/usr/bin/env python3
"""
Scrape public book listings from books.toscrape.com (practice site, no login).

Respects:
- Public pages only (no auth, no private data)
- Polite delay between requests
- User-Agent identifying this script as a portfolio demo
"""

from __future__ import annotations

import argparse
import csv
import sys
import time
from pathlib import Path
from urllib.parse import urljoin

import httpx
from bs4 import BeautifulSoup

BASE_URL = "https://books.toscrape.com/"
USER_AGENT = "KevinPortfolioDemo/1.0 (+https://github.com/example; student portfolio scraper)"
DEFAULT_OUT = Path("output/books.csv")
REQUEST_GAP_SEC = 0.6


def fetch(client: httpx.Client, url: str) -> str:
    resp = client.get(url, timeout=30.0)
    resp.raise_for_status()
    return resp.text


def parse_listing(html: str, page_url: str) -> list[dict[str, str]]:
    soup = BeautifulSoup(html, "html.parser")
    rows: list[dict[str, str]] = []

    for article in soup.select("article.product_pod"):
        title_el = article.select_one("h3 a")
        price_el = article.select_one("p.price_color")
        avail_el = article.select_one("p.instock.availability")
        rating_el = article.select_one("p.star-rating")

        title = (title_el.get("title") or title_el.get_text(strip=True)) if title_el else ""
        href = title_el.get("href", "") if title_el else ""
        link = urljoin(page_url, href)
        price = price_el.get_text(strip=True) if price_el else ""
        availability = " ".join(avail_el.get_text().split()) if avail_el else ""
        rating = ""
        if rating_el:
            classes = rating_el.get("class", [])
            rating = next((c for c in classes if c != "star-rating"), "")

        rows.append(
            {
                "title": title,
                "price": price,
                "availability": availability,
                "rating": rating,
                "url": link,
            }
        )
    return rows


def next_page_url(html: str, page_url: str) -> str | None:
    soup = BeautifulSoup(html, "html.parser")
    next_link = soup.select_one("li.next a")
    if not next_link or not next_link.get("href"):
        return None
    return urljoin(page_url, next_link["href"])


def scrape(max_pages: int, out_path: Path) -> int:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = ["title", "price", "availability", "rating", "url"]
    all_rows: list[dict[str, str]] = []

    headers = {"User-Agent": USER_AGENT, "Accept": "text/html"}
    with httpx.Client(headers=headers, follow_redirects=True) as client:
        url: str | None = BASE_URL
        page = 0
        while url and page < max_pages:
            page += 1
            print(f"[page {page}] GET {url}", file=sys.stderr)
            html = fetch(client, url)
            rows = parse_listing(html, url)
            print(f"  -> {len(rows)} books", file=sys.stderr)
            all_rows.extend(rows)
            url = next_page_url(html, url)
            if url:
                time.sleep(REQUEST_GAP_SEC)

    with out_path.open("w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(all_rows)

    print(f"Wrote {len(all_rows)} rows -> {out_path.resolve()}", file=sys.stderr)
    return len(all_rows)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Scrape public books from books.toscrape.com into CSV."
    )
    parser.add_argument(
        "--pages",
        type=int,
        default=2,
        help="How many listing pages to scrape (default: 2, max useful ~50)",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"Output CSV path (default: {DEFAULT_OUT})",
    )
    args = parser.parse_args()
    if args.pages < 1:
        parser.error("--pages must be >= 1")

    scrape(max_pages=args.pages, out_path=args.out)


if __name__ == "__main__":
    main()
