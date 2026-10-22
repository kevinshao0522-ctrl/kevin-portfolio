# 慢巷咖啡落地页 · Cafe Landing

English title: **Xuzhou Local Cafe — Responsive Landing Page**

徐州本地「假·咖啡馆」单页落地页作品。纯静态 HTML / CSS / JS，手机端优先，可直接部署到 Vercel 或 Netlify。

## 功能

- 响应式导航（移动端汉堡菜单）
- 菜单卡片（手冲 / 意式 / 轻食）
- 店铺故事与营业时间
- 预约表单（前端演示，不发送数据）
- 微信二维码占位区（上线时替换为真实图）

## 本地预览

任选一种：

```bash
# 方式 A：Python 内置服务器
cd cafe-landing
python3 -m http.server 5173

# 方式 B：npx（若已装 Node）
npx --yes serve .
```

浏览器打开 http://localhost:5173

## 部署到 Vercel / Netlify

1. 把本文件夹推到 GitHub 仓库（或只推 `cafe-landing` 子目录）
2. **Vercel**：Import Project → Framework Preset 选 Other → Output/Root 指向本目录 → Deploy
3. **Netlify**：Add new site → 选择仓库 → Publish directory 填 `.`（若仓库根就是本目录）或 `cafe-landing`

无需构建步骤，直接发布静态文件即可。

## 技术栈

- HTML5 + CSS3（CSS Grid / Flex / sticky header）
- 原生 JavaScript（无框架）
- Google Fonts：Noto Sans SC + Playfair Display

## 作者

Kevin Shao · 大学生作品 · 周末交付示例
