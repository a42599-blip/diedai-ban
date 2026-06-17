# 🚨 v8i8.com YouTube 故障修復 SOP（永久記憶）

> 最後更新：2026-06-18 v2（加入 v1.4 穩定版 + 鎖版本方式修正）
> ⚠️ **YouTube 是唯一會自己壞掉的平台**（即使沒人動任何東西）
> ⚠️ **每次 YouTube 壞掉，先讀這份 SOP，照步驟做**
> **🎯 v1.4 穩定版：** commit `a72d462` / tag `v1.4` / Railway deployment `8f582724`

---

## 一、症狀

YouTube 影片解析失敗，出現：
```
ERROR: [youtube] ...: Sign in to confirm you're not a bot
```
或：
```
HTTP Error 403
```

## 二、真正原因（累積經驗，不是猜的）

### 2026-06-18 這次（最新經驗）
**沒人動任何東西，YouTube 自己壞掉。** 原因不是 cookies 過期：

| # | 問題 | 說明 | 發現日 |
|:-:|:----|:------|:-----:|
| 1 | ❌ yt-dlp 鎖在 requirements.txt 不是 Dockerfile | Railway pip 不吃 requirements.txt 的版本鎖定，部署會失敗 | **6/18** |
| 2 | ❌ `remote_components: ["ejs:github"]` | 讓 yt-dlp 去 GitHub 下載 JS 腳本，下載失敗或限流時卡住 | 6/18 |
| 3 | ❌ 沒有明確指定 Deno JS runtime | yt-dlp 號稱會自動偵測，但 Railway 上不一定抓到 | 6/18 |
| 4 | ❌ 沒有重試機制 | 雲端 IP 打 YouTube 第一次失敗就放棄，不重試 | 6/18 |
| 5 | ❌ TV 客戶端有 DRM | `tv/tv_embedded` 會被 YouTube A/B 測試啟用 DRM | 6/16 |
| 6 | ❌ cookies fallback 被 httpx 蓋掉 | httpx 在 Railway 上永遠成功但回傳不完整 cookies | 6/17 |
| 7 | ❌ 用了私人 cookies | 公共服務不能用，且 cookies 會過期 | 6/18 |

## 三、修復方法（照順序做，不要跳步）

### Step 1：確認 yt-dlp 鎖定方式正確

**重要：yt-dlp 不能鎖在 requirements.txt，必須鎖在 Dockerfile！**

檢查 `Dockerfile`：
```
✅ pip install -r requirements.txt yt-dlp==2026.6.9   ← 正確（鎖在 Dockerfile）
❌ requirements.txt 中有 yt-dlp==xxx                 ← 錯誤，Railway 會部署失敗
```

檢查 `requirements.txt`：
```
✅ 沒有 yt-dlp 這行（yt-dlp 由 Dockerfile 管理）
❌ 有 yt-dlp 或 yt-dlp==xxx                       ← 移除，交給 Dockerfile 鎖
```

### Step 2：確認 `_YT_OPTS_EXTRA` 設定正確

檢查 `server.py` 開頭的 `_YT_OPTS_EXTRA`：

```python
# ✅ 正確的設定
_YT_OPTS_EXTRA = {
    "js_runtimes": {"deno": {}},         # 明確指定 Deno（必要！）
    "retry_sleep": "extractor:exp=1:20", # 失敗時指數退避重試
    "fragment_retries": 10,             # 片段下載重試次數
}

# ❌ 錯誤的設定（裡面有 remote_components）
_YT_OPTS_EXTRA = {"remote_components": ["ejs:github"]}
```

如果缺少任何一項 → 補上。
如果有 `remote_components` → 移除。

### Step 3：確認 `player_client` = `"all"`

檢查 `server.py` 中兩處（解析端 + 下載端）：

```python
# ✅ 正確
"extractor_args": {"youtube": {"player_client": "all"}}

# ❌ 錯誤
"extractor_args": {"youtube": {"player_client": ["ios", "android", "web"]}}
```

### Step 4：確認沒有寫死任何私人 cookies

檢查 YouTube cookies 區塊，應該是：
```python
# ✅ 正確：每次從 Railway httpx 抓匿名 cookies
_yt_cookies = {}
_r = httpx.get("https://www.youtube.com/", ...)
_yt_cookies.update(dict(_r.cookies))

# ❌ 錯誤：有硬編碼的 cookie 字串
_yt_cookies = {"VISITOR_INFO1_LIVE":"xxx", ...}  # ← 這是私人 cookies，不能用！
```

### Step 5：commit & push 到 Railway

```bash
cd D:/pi-agent/diedai-ban-work
git add server.py requirements.txt
git commit -m "fix: YouTube 修復 - [寫你改了什麼]"
git push origin master
```

等約 2 分鐘讓 Railway 建置 + 部署。

### Step 6：驗證

```bash
curl -sL "https://v8i8.com/api/video-info?url=https://www.youtube.com/watch?v=jNQXAC9IVRw"
```

| 結果 | 意思 |
|:----|:------|
| 回傳 `title` + `formats` | ✅ **修好了** |
| 回傳 `error` | ❌ **還沒好**，回到 Step 1 重新檢查 |

## 四、如果 Step 1~6 都做了還是壞

### 情況 A：可能是 yt-dlp 版本問題
解法：滾回 v1.4 穩定版
```bash
cd D:/pi-agent/diedai-ban-work
git checkout v1.4
git push origin master --force
```

**v1.4 資訊：**
- GitHub commit: `a72d462`
- GitHub tag: `v1.4`
- Railway deployment ID: `8f582724-a6d6-47c4-9829-2abc3e461c82`
- Railway deployment 名稱: `a72d462 - chore: 重新部署測試 YouTube 狀態`
- Image digest: `sha256:11f4333e01be165dc6bc716721eee0a2c1cc3d86a5351b9e0a94b37e060b530b`

### 情況 B：滾回 v1.4 也不行
解法：手動在 Railway Dashboard 找到 deployment `8f582724` 按 Redeploy
這會直接用同一個 Docker image 重啟，不會重新 build。

### 情況 C：手動 Redeploy 也不行
解法：環境變數（Railway base image 更新、Deno 版本變動等）
需要進一步診斷

## 五、進階：環境變數備援

在 Railway Dashboard 可以設定 `YT_COOKIES_JSON` 環境變數：
```
Key:   YT_COOKIES_JSON
Value: {"VISITOR_INFO1_LIVE":"xxx", "YSC":"xxx", ...}
```
**平常不要設**，只有非常時期才用。

## 六、YouTube 為什麼比其他平台脆弱？

| 平台 | 穩定度 | 原因 |
|:----|:------:|:------|
| 抖音/TikTok | 🟢 幾乎不壞 | 用第三方 API 解析，不走 yt-dlp |
| B站 | 🟡 有時壞 | 海外 IP 被封，但有 HTML5 fallback |
| 小紅書/蝦皮/FB/IG | 🟢 幾乎不壞 | 直解 HTML 或 CDN |
| **YouTube** | **🔴 最脆弱** | **yt-dlp 依賴 + 雲端 IP 被封 + A/B 測試頻繁** |

## 七、專案資訊

| 項目 | 內容 |
|------|------|
| **正式站** | https://v8i8.com |
| **GitHub repo** | `a42599-blip/diedai-ban`（master） |
| **Railway 專案** | diedai-ban |
| **Railway 服務 ID** | `361f70f3-4163-4edc-8977-624242ca9974` |
| **本機目錄** | `D:/pi-agent/diedai-ban-work/` |
| **備援站** | aa.v8i8.com（video-downloader，不要動） |

## 八、修復快速指令（複製貼上）

```bash
# 1. 進目錄
cd D:/pi-agent/diedai-ban-work

# 2. 確認 requirements.txt 沒鎖 yt-dlp
cat requirements.txt | grep yt-dlp
# 應該顯示：yt-dlp（沒有 == 版本號）

# 3. 確認 server.py 的 _YT_OPTS_EXTRA 有 js_runtimes
grep -A 5 "_YT_OPTS_EXTRA" server.py
# 應該有：js_runtimes, retry_sleep, fragment_retries

# 4. 確認 player_client=all
grep "player_client" server.py | head -2
# 應該顯示："player_client": "all"

# 5. commit & push
git add server.py requirements.txt
git commit -m "fix: YouTube 修復 - cookies更新/js_runtimes/重試"
git push origin master

# 6. 等 2 分鐘，驗證
curl -sL "https://v8i8.com/api/video-info?url=https://www.youtube.com/watch?v=jNQXAC9IVRw"
```
