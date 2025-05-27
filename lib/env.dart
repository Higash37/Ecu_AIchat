// Flutter側でローカル開発環境とRender公開環境を切り替えるための設定クラス

class AppConfig {
  // 開発中はtrueに設定し、公開時にはfalseに変更
  static const bool isLocal = false;

  // APIのベースURL：ローカル開発時とRenderデプロイ時で切り替え
  static String get apiBaseUrl =>
      isLocal
          ? "http://localhost:8000" // ローカル開発環境
          : "https://aiedu-backend.onrender.com"; // Render公開環境（URLは実際のものに変更してください）

  // 環境名（デバッグ用）
  static String get envName => isLocal ? "開発環境" : "公開環境";
}
