# Dockerfile — 下载 GGUF 模型到 busybox 镜像的 /data/ 目录
#
# 构建方法:
#   docker build -t qwen2.5-vl-3b-instruct-gguf .
#
# 使用多阶段构建:
#   阶段1 (alpine): 下载 GGUF 模型文件
#   阶段2 (busybox): 仅包含模型 + busybox,镜像最小化

# ============================================================
# 阶段1 — 下载器
# ============================================================
FROM alpine:latest AS downloader

RUN apk add --no-cache wget ca-certificates

# Qwen2.5-VL-3B-Instruct GGUF Q2_K (~1.2GB)
RUN mkdir -p /data && \
    wget -q --show-progress \
        https://huggingface.co/unsloth/Qwen2.5-VL-3B-Instruct-GGUF/resolve/main/Qwen2.5-VL-3B-Instruct-Q2_K.gguf \
        -O /data/Qwen2.5-VL-3B-Instruct-Q2_K.gguf && \
    ls -lh /data/

# ============================================================
# 阶段2 — 最终镜像: busybox + GGUF 模型
# ============================================================
FROM busybox:latest

COPY --from=downloader /data/ /data/

# 验证模型文件存在
RUN ls -lh /data/

CMD ["sh", "-c", "echo 'GGUF model is ready at /data/' && ls -lh /data/"]
