@echo off
echo ===== 環境変数を指定してFlutterアプリをビルド =====

echo 1. env.jsonファイルから環境変数を読み込んでビルド
flutter build web --release --dart-define-from-file=env.json --base-href=/Ecu_AIchat/

echo 2. gh-pages-newブランチにビルド結果をコミット
git add build/web
git commit -m "Update web build with environment variables"

echo ===== ビルド完了 =====
echo GitHub Pagesにデプロイするには以下のコマンドを実行:
echo git push origin gh-pages-new
