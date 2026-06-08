# aa.v8i8.com — 去水印下載工具（迭代開發版）

> **當前版本：`d7c52ee`**（2026-06-08）⬅️ 滾回用這個
>
> 🚫 主站 `v8i8.com`（production）已凍結，所有修改先在這裡測試

---

## 支援平台（13個）

| # | 平台 | 解析 | 下載 | 技術方式 | iOS相簿 |
|:-:|:----|:----:|:----:|:---------|:-------:|
| 1 | **抖音 Douyin** | ✅ | ✅ | a_bogus + ttwid 直接調用 | ✅ |
| 2 | **TikTok** | ✅ | ✅ | tikwm API | ✅ |
| 3 | **B站 Bilibili** | ✅ | ✅ | 直打 Bilibili API | ✅ |
| 4 | **小紅書** | ✅ | ✅ | 直解 HTML（OG meta） | ✅ |
| 5 | **蝦皮 Shopee** | ✅ | ✅ | HTML 解析（stream 150KB） | ✅ |
| 6 | **Facebook** | ✅ | ✅ | 專屬 `best[ext=mp4]/best` | ✅ |
| 7 | **微博 Weibo** | ✅ | ✅ | 專屬解析器 + `best[ext=mp4]/best` | ✅ |
| 8 | **今日頭條** | ✅ | ✅ | 通用 yt-dlp | ✅ |
| 9 | **西瓜視頻** | ✅ | ✅ | 通用 yt-dlp | ✅ |
| 10 | **YouTube** | ✅ | ✅ | yt-dlp Android 客戶端 + H.264 | ⚠️ iOS到最近儲存 |
| 11 | **Instagram** | ✅ | ✅ | 專屬 `best[ext=mp4]/best` | ⚠️ iOS到最近儲存 |
| 12 | **X (Twitter)** | ✅ | ✅ | 通用 yt-dlp | ⚠️ iOS到最近儲存 |
| 13 | 快手 Kuaishou | ❌ 已移除 | ❌ | — | ❌ |

---

## 🏗️ 架構

```
用戶 → aa.v8i8.com → Cloudflare DNS → Worker aa-proxy（單純代理）
       → Railway diedai-ban（FastAPI + yt-dlp + ffmpeg + Deno）
```

| 項目 | 內容 |
|:----|:------|
| **後端框架** | Python FastAPI（uvicorn） |
| **下載引擎** | yt-dlp（不鎖版本）+ ffmpeg |
| **JS Runtime** | Deno（YouTube 解析必要） |
| **Docker 基礎** | python:3.12-slim |
| **CPU / RAM** | 8 vCPU / 2 GB（Railway Starter，已調升） |
| **費用** | Railway $5/月（可能多專案共用 Starter 額度） |
| **域名** | v8i8.com（Cloudflare 購買，$10.44/年） |
| **Worker** | aa-proxy（Cloudflare，$0） |

---

## 🛠️ 各平台技術細節

### 抖音
- **解析**：a_bogus + ttwid 直接調用（不經 asyncio task）
- **API**：`ttwid.bytedance.com` POST → `douyin.com/aweme/v1/web/aweme/detail/`
- **去浮水印**：CDN URL 中 `playwm` → `play`
- **備援**：tikwm API → yt-dlp

### YouTube
- **解析**：yt-dlp Android 客戶端 + 公開 cookies
- **下載**：`bestvideo[ext=mp4][vcodec^=avc1]+bestaudio[ext=m4a]/best[ext=mp4]/best`
- **iOS 限制**：可下載但到「最近儲存」非主相簿

### IG / FB / 微博
- **下載設定**：`best[ext=mp4]/best` + `merge_output_format:mp4`
- **成功關鍵**：越簡單越穩定，不加 H.264 強制

### B站
- **解析**：直打 `api.bilibili.com`（繞過 yt-dlp 地區限制）
- **Cookie**：`buvid3` + `buvid4` 繞過 WAF

---

## 🌐 API

| 端點 | 說明 |
|:----|:------|
| `GET /api/video-info?url=...` | 解析影片資訊 |
| `GET /api/download-progress?url=...` | SSE 下載進度 |
| `GET /api/proxy-video?url=...` | 代理 CDN 影片 |
| `GET /api/debug-douyin?url=...` | 抖音診斷端點 |

---

## 🚀 部署

```bash
git push origin master
# Railway 自動部署到 aa.v8i8.com
```

## ⬅️ 滾回

```bash
git reset --hard d7c52ee
git push origin master --force
# 再觸發 Railway 部署
```

## 🏷️ 版本標籤

```
v1-origin         = 9e4dbbe  原始版
v2-badges-fb-fix  = 7bc765f  +FB/IG徽章+下載
v3-weibo-x-ios    = e0c715c  +微博+X iOS
v4-x-backend      = cbcbe2e  +X後端
v5-x-yt-format    = 7ea94aa  X改YT格式
v6-x-h264         = 23ea59a  X強制H.264
v7-x-ffmpeg       = c42da1c  X ffmpeg
v8-x-simple       = 381cb43  X best格式
v9-revert-front   = e1898ee  還原前端
```

## ⚠️ 已知問題

1. YouTube / Instagram / X(Twitter) iOS 下載到最近儲存（非主相簿）
2. 抖音 `core_dep` 限制（抖音端限制部分影片）
3. 微博部分影片需登入才能看
4. Railway RAM 已調到 2GB，Playwright 可用但非必要
