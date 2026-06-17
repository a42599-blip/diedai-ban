FROM python:3.12-slim

# 安裝系統依賴（ffmpeg + Playwright Chromium + Deno）
RUN apt-get update && apt-get install -y \
    ffmpeg \
    wget \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 安裝 Deno（JS runtime，yt-dlp 需要它解 YouTube 機器人驗證）
# ⚠️ 鎖定版本 v2.8.3！每次部署抓最新版會導致 Deno 更新後 yt-dlp 不相容
RUN curl -fsSL https://github.com/denoland/deno/releases/download/v2.8.3/deno-x86_64-unknown-linux-gnu.zip \
    -o /tmp/deno.zip && \
    unzip -o /tmp/deno.zip -d /usr/local/bin/ && \
    rm /tmp/deno.zip && \
    chmod +x /usr/local/bin/deno
ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /app

# 安裝 Python 依賴
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt yt-dlp==2026.6.9

# 安裝 Playwright Chromium
RUN playwright install chromium --with-deps

# 複製應用程式
COPY server.py .
COPY index.html .
COPY ads.txt .
COPY crawlers/ ./crawlers/
RUN mkdir -p 下載影片

EXPOSE 7790

CMD ["python", "server.py"]
