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

# ── YouTube 通行證（PO Token）產生器 bgutil（照轉運站）──────────────────────
# 只有 YouTube 模塊會用（在容器內 127.0.0.1:4416；見 start.sh）。裝不起來也不影響其他平台。
RUN curl -fsSL https://github.com/Brainicism/bgutil-ytdlp-pot-provider/archive/refs/tags/2.0.0.tar.gz \
    | tar -xz -C /opt \
 && mv /opt/bgutil-ytdlp-pot-provider-2.0.0 /opt/bgutil \
 && cd /opt/bgutil/server \
 && deno install --allow-scripts=npm:canvas --frozen

# ── Cloudflare WARP 通道工具（照轉運站）──────────────────────────────────
# wgcf＝申請免費 WARP 帳號；wireproxy＝開通道當 HTTP 代理（只聽 127.0.0.1:40001）
RUN curl -fsSL -o /usr/local/bin/wgcf https://github.com/ViRb3/wgcf/releases/download/v2.3.0/wgcf_2.3.0_linux_amd64 \
 && chmod +x /usr/local/bin/wgcf \
 && curl -fsSL https://github.com/windtf/wireproxy/releases/download/v1.1.3/wireproxy_linux_amd64.tar.gz \
      | tar -xz -C /usr/local/bin wireproxy \
 && chmod +x /usr/local/bin/wireproxy

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
COPY start.sh .
RUN mkdir -p 下載影片

EXPOSE 7790

CMD ["sh", "start.sh"]
