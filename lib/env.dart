// Flutter側での環境設定と環境変数管理クラス

class AppConfig {
  // 開発中はtrueに設定し、公開時にはfalseに変更
  static const bool isLocal = false;
  // APIのベースURL：ローカル開発時とFly.ioデプロイ時で切り替え
  static String get apiBaseUrl =>
      isLocal
          ? "http://localhost:8000" // ローカル開発環境
          : "https://ai-edu-api.fly.dev"; // Fly.io公開環境

  // 環境名（デバッグ用）
  static String get envName => isLocal ? "開発環境" : "公開環境";

  // Supabase接続情報
  static final String supabaseUrl = 'https://kppzjurayiusfpstobdn.supabase.co';
  static final String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwcHpqdXJheWl1c2Zwc3RvYmRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcxNzA4NzcsImV4cCI6MjA2Mjc0Njg3N30.VJqAOQtRMhm-JFTPClrI_oA-pY-Ckl9EdMEex5-jFqg';
}
