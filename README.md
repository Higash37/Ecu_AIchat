# AI 教材チャットアプリ - README

## 概要

本アプリは、教師が授業中や事前準備時に活用できる、教育特化型の AI チャットアプリです。以下の機能を MVP として実装済みです：

- プロジェクトごとのチャット履歴管理（例：生徒別、講義別）
- Supabase を用いたバックエンドとデータ永続化
- FastAPI による OpenAI GPT-4o との連携（Docker 対応）
- Flutter によるクロスプラットフォーム UI 構築（Web / モバイル）
- Markdown 形式の AI 出力、PDF 生成、カスタマイズ対応

今後、以下のような機能の拡張を想定：

- WordCloud UI ベースの入力体験とタグ自動生成
- AI エージェントによる対話の最適化（LangGraph、RAG 構成）
- 講師によるフィードバックの蓄積・分析
- ワークスペース共有機能、個別学習最適化

## 技術スタック

### フロントエンド（Flutter）

- flutter_chat_ui + flutter_chat_types によるチャット UI
- Supabase Flutter SDK によるリアルタイム DB 接続
- .env による環境変数管理（flutter_dotenv）

### バックエンド（FastAPI）

- OpenAI GPT-4o API 連携（openai ライブラリ）
- CORS 対応（Flutter と連携可能）
- Docker による環境管理

### DB（Supabase）

- projects / chats / messages / tags の 4 テーブル構成
- 生徒別や授業別にチャットやタグを保存
- メッセージ種別（user / ai）による分類

## 環境構築方法

### 1. Supabase の準備

- プロジェクト作成
- `.env` に以下を記述：

  ```env
  SUPABASE_URL=xxxxx
  SUPABASE_ANON_KEY=xxxxx
  ```

- SQL エディタにて以下を実行：

  ```sql
  -- 省略（4テーブル作成済み）
  ```

### 2. FastAPI（バックエンド）

- `ai_edu_api/` 配下で `.env` に OpenAI API キーを追加

  ```env
  OPENAI_API_KEY=sk-xxxxx
  ```

- Docker で起動：

  ```bash
  docker compose up --build
  ```

- エンドポイント：`POST http://localhost:8000/chat`

### 3. Flutter（フロントエンド）

- ルートに `.env` を作成：

  ```env
  SUPABASE_URL=xxxxx
  SUPABASE_ANON_KEY=xxxxx
  ```

- 起動：

  ```bash
  flutter run -d chrome
  ```

## ディレクトリ構成（Flutter）

lib/
├── main.dart
├── models/
│ ├── project.dart
│ ├── chat.dart
│ └── message.dart
├── services/
│ ├── project_service.dart
│ ├── chat_service.dart
│ └── message_service.dart
├── screens/
│ ├── project_list_screen.dart
│ ├── project_detail_screen.dart
│ ├── chat_list_screen.dart
│ └── chat_detail_screen.dart
└── widgets/
└── ...（今後）

## デザインガイドライン

- iOS ネイティブ風：

  - 白背景＋シンプルなマテリアル UI
  - ボックスやリストは角丸 + 陰影
  - 吹き出しスタイルでチャット表示（LINE 風）

- ワードクラウド（将来）：

  - ユーザー入力がカードやタグとしてふわっと画面に浮かぶ
  - 関係線（Mapify 風）を描画し、編集可能

## 今後の TODO

- [ ] message 保存機能（chat_id に紐づけ）
- [ ] タグ追加・表示画面
- [ ] ユーザー入力による WordCloud の視覚化
- [ ] Markdown 出力 + PDF 連携
- [ ] 教師フィードバックの構造化保存

## 開発者向け Tips

- Supabase の UUID は `gen_random_uuid()` により自動生成
- Flutter で null 許容に注意（required 修飾子）
- Docker の FastAPI 起動に失敗したら `--build` オプション推奨

## 共同開発について

このリポジトリは GitHub で共有されており、今後以下のような開発ルールを想定：

- `main` は常に動作する状態を保持
- 各自 `feature/xxx` ブランチを切って PR ベースで反映
- README は機能追加ごとに更新
- Firebase や Vercel への CI/CD 導入も視野に

---

何か質問や要望があれば `/docs` フォルダに追加予定です。
今後の正式リリースに向けて、MVP の改善と UX の洗練に注力していきます。
