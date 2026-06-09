# v8i8.com — 去水印下載工具（正式版）

> **最終穩定版：`c983719`**（2026-06-09）
> **🔄 滾回用版本：`c983719`**
> 🆢 原迭代版 aa.v8i8.com 已於 2026-06-09 升級為正式版 v8i8.com
> **✅ LINE 快取問題已解決（舊 Railway URL 自動跳轉）**
>
> **📦 舊版存放於 aa.v8i8.com（原 production 穩定版）**

---

## 支援平台（13個）

| # | 平台 | 解析 | 下載 | 技術方式 | iOS相簿 |
|:-:|:----|:----:|:----:|:---------|:-------:|
| 1 | **抖音 Douyin** | ✅ | ✅ | a_bogus + ttwid | ✅ |
| 2 | **TikTok** | ✅ | ✅ | tikwm API | ✅ |
| 3 | **B站 Bilibili** | ✅ | ✅ | 直打 Bilibili API | ✅ |
| 4 | **小紅書** | ✅ | ✅ | 直解 HTML | ✅ |
| 5 | **蝦皮 Shopee** | ✅ | ✅ | HTML 解析 | ✅ |
| 6 | **Facebook** | ✅ | ✅ | 專屬 `best[ext=mp4]/best` | ✅ |
| 7 | **微博 Weibo** | ✅ | ✅ | 專屬解析器 + `best[ext=mp4]/best` | ✅ |
| 8 | **今日頭條** | ✅ | ✅ | 通用 yt-dlp | ✅ |
| 9 | **西瓜視頻** | ✅ | ✅ | 通用 yt-dlp | ✅ |
| 10 | **YouTube** | ✅ | ✅ | yt-dlp Android + `[vcodec^=avc1]` H.264 + 公開cookies + Deno | ⚠️ iOS到最近儲存 |
| 11 | **Instagram** | ✅ | ✅ | 專屬 `best[ext=mp4]/best` | ⚠️ iOS到最近儲存 |
| 12 | **X (Twitter)** | ✅ | ✅ | 通用 yt-dlp | ⚠️ iOS到最近儲存 |
| 13 | 快手 Kuaishou | ❌ 已移除 | ❌ | — | ❌ |

---

## 🏗️ 架構

| 項目 | 內容 |
|:----|:------|
| **正式站** | https://v8i8.com → Cloudflare DNS → Railway **diedai-ban** |
| **舊版站** | https://aa.v8i8.com → Cloudflare Worker aa-proxy → Railway **calm-creation** |
| **GitHub** | `a42599-blip/diedai-ban`（master）→ auto-deploy → v8i8.com |
| **後端** | Python FastAPI + yt-dlp + ffmpeg + Deno |
| **Docker** | python:3.12-slim |
| **CPU / RAM** | 8 vCPU / 2 GB（Railway Starter） |
| **費用** | Railway $5/月（可能多專案共用 Starter 額度） |

---

## 🚀 部署

```bash
git push origin master
# Railway 自動部署到 v8i8.com
```

## ⬅️ 滾回

```bash
git reset --hard d7c52ee
git push origin master --force
# 再觸發 Railway 部署
```

## ⚠️ 已知問題

1. YouTube / Instagram / X(Twitter) iOS 下載到最近儲存
2. 抖音 `core_dep` 限制
3. 微博部分影片需登入
