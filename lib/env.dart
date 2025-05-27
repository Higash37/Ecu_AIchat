// Flutter側での環境設定と環境変数管理クラス

class AppConfig {
  // 開発中はtrueに設定し、公開時にはfalseに変更
  static const bool isLocal = false;

  // APIのベースURL：ローカル開発時とRenderデプロイ時で切り替え
  static String get apiBaseUrl =>
      isLocal
          ? "http://localhost:8000" // ローカル開発環境
          : "https://aiedu-backend.onrender.com"; // Render公開環境

  // 環境名（デバッグ用）
  static String get envName => isLocal ? "開発環境" : "公開環境";

  // Supabase接続情報
  static final String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-supabase-project.supabase.co',
  );

  static final String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );
}
