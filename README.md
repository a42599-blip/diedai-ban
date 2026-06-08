# aa.v8i8.com — 去水印下載工具（迭代開發版）

> **當前版本：`d7c52ee`**（2026-06-08）
>
> 🚫 主站 `v8i8.com` 不動，所有修改先在這裡測試

---

## 支援平台（13個）

| 平台 | 解析 | 下載 | 備註 |
|:----|:----:|:----:|:------|
| 抖音 Douyin | ✅ | ✅ | a_bogus + ttwid |
| TikTok | ✅ | ✅ | tikwm API |
| B站 Bilibili | ✅ | ✅ | 直打 Bilibili API |
| 小紅書 | ✅ | ✅ | 直解 HTML |
| 蝦皮 Shopee | ✅ | ✅ | HTML 解析 |
| **Facebook** | ✅ | ✅ | `best[ext=mp4]/best` |
| **微博 Weibo** | ✅ | ✅ | 專屬解析 + `best[ext=mp4]/best` |
| 今日頭條 | ✅ | ✅ | 通用 yt-dlp |
| 西瓜視頻 | ✅ | ✅ | 通用 yt-dlp |
| 快手 Kuaishou | ❌ 已移除 | ❌ | |
| **YouTube** | ✅ | ✅ | yt-dlp Android 客戶端 ⚠️ iOS下載到最近儲存 |
| **Instagram** | ✅ | ✅ | `best[ext=mp4]/best` ⚠️ iOS下載到最近儲存 |
| **X (Twitter)** | ✅ | ✅ | 通用 yt-dlp ⚠️ iOS下載到最近儲存 |

---

## 部署

```bash
git push origin master
# Railway 自動部署到 aa.v8i8.com
```

## 滾回

```bash
git reset --hard <版本號>
git push origin master --force
# 然後觸發 Railway 部署
```

## 版本標籤

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
