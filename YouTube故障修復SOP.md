# 🚨 v8i8.com YouTube 故障修復 SOP（永久記憶）

> 最後更新：2026-06-17 21:00
> ⚠️ **每次 YouTube 壞掉都只做這 2 件事，不要多加東西！**

---

## 一、症狀

YouTube 影片解析失敗，出現錯誤：
```
Sign in to confirm you're not a bot
```
或：
```
HTTP Error 403
```

## 二、根因

**只有一個原因：YouTube 的 cookies 過期了。**

YouTube 會封鎖 Railway 的雲端 IP，yt-dlp 需要有效的 cookies 才能通過驗證。
跟 yt-dlp 版本、JS runtime、Deno、Node.js **完全無關**。

## 三、修復方法（只做這 2 步，不要多做！）

### 步驟 1：確認 `player_client` 是 `"all"`

去 `server.py` 檢查這兩處：

```python
# 第 1483 行（info 解析端）
opts["extractor_args"] = {"youtube": {"player_client": "all"}}

# 第 2337 行（下載端）
"extractor_args":{"youtube":{"player_client":"all"}},
```

如果是 `["ios", "android", ...]` 這種列表，改成 `"all"`。
**不要改成別的，就是 `"all"`。**

### 步驟 2：更新 cookies（這才是真正的修復）

從本機 Windows 執行這行指令，拿到最新的 YouTube cookies：

```bash
curl -sL -c /tmp/yt_cookies.txt "https://www.youtube.com/" \
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
cat /tmp/yt_cookies.txt
```

把輸出的 cookie 值，更新到 `server.py` 中的 `_fallback` 字典：

```python
_fallback = {
    "VISITOR_INFO1_LIVE": "<新值>",
    "YSC": "<新值>",
    "GPS": "1",
    "__Secure-ROLLOUT_TOKEN": "<新值>",
    "VISITOR_PRIVACY_METADATA": "<新值>",
    "__Secure-YNID": "<新值>",
}
```

**注意：** cookies 值是 URL-encoded 的（`%3D` = `=`，`%2F` = `/`），貼到 Python 時要解碼。

### 這 2 步做完 → commit → push → Railway 自動部署

```bash
git add server.py
git commit -m "fix: 更新 YouTube cookies（從本機 youtube.com 即時取得）"
git push origin master
```

等約 1 分鐘讓 Railway 部署完成。

## 四、驗證修復

測試之前會失敗的影片（Me at the zoo，YouTube 第一個影片，常被擋）：

```bash
curl -sL "https://v8i8.com/api/video-info?url=https://www.youtube.com/watch?v=jNQXAC9IVRw"
```

回傳 `title` 和 `formats` 就是修好了，回傳 `error` 就是還沒好。

## 五、進階：環境變數備援（不用改 code）

如果不想每次改 code，可以在 Railway Dashboard 設定環境變數：

```
Key:   YT_COOKIES_JSON
Value: {"VISITOR_INFO1_LIVE":"xxx","YSC":"xxx","__Secure-ROLLOUT_TOKEN":"xxx",...}
```

程式會優先讀環境變數，再補即時抓的，最後才用寫死備援。

## 六、重要警語（每次必讀）

### ❌ 不要做的事（我踩過的坑）

| 不要做 | 為什麼 |
|--------|--------|
| ❌ 不要碰 `js_runtimes` | yt-dlp Python API 預設就是 `{"deno": {}}`，傳 list 反而壞掉 |
| ❌ 不要裝 Deno/Node | 跟 YouTube 修復無關，yt-dlp 不需要也能解 |
| ❌ 不要加 EJS/remote_components | 非必要，加了不會更好 |
| ❌ 不要改 yt-dlp 版本 | 小羅決定不鎖版本，保持最新 |
| ❌ 不要碰 Invidious | 所有實例都死了 |
| ❌ 不要改 Dockerfile | Railway 上本來就能跑 |
| ❌ 不要推錯 repo | `v8i8.com` 正式站是 `a42599-blip/diedai-ban`，不是 `video-downloader` |

### ✅ 唯一要做的事

**只更新 cookies，只改 `server.py` 中的 `_fallback` 字典。**

如果 cookies 更新了還是不行，試試把 Chrome 完全關閉再重開，然後重新 curl。

## 七、專案資訊

| 項目 | 內容 |
|------|------|
| **正式站網址** | https://v8i8.com |
| **GitHub repo** | `a42599-blip/diedai-ban`（master） |
| **Railway 專案** | diedai-ban |
| **本機目錄** | `D:/pi-agent/diedai-ban-work/` |
| **Cloudflare** | v8i8.com → Railway |
| **備援站** | aa.v8i8.com（`video-downloader`，不要動） |

## 八、修復快速指令（複製貼上就完成）

```bash
# 1. 拿新 cookies
curl -sL -c /tmp/yt_cookies.txt "https://www.youtube.com/" -H "User-Agent: Mozilla/5.0"
cat /tmp/yt_cookies.txt

# 2. 更新 server.py 中的 _fallback 字典
# （手動編輯，把上面 cat 出來的值填進去）

# 3. commit & push
cd D:/pi-agent/diedai-ban-work
git add server.py
git commit -m "fix: 更新 YouTube cookies"
git push origin master

# 4. 等 1 分鐘，驗證
curl -sL "https://v8i8.com/api/video-info?url=https://www.youtube.com/watch?v=jNQXAC9IVRw"
```
