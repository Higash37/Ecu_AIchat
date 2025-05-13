# ベースイメージ - 最新のセキュリティアップデートを含む
FROM python:3.11-slim-bookworm

# 作業ディレクトリを /app に
WORKDIR /app

# セキュリティアップデートを適用
RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# 依存関係ファイルをコピーしてインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリコードをコピー
COPY . .

# サーバー起動コマンド
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
